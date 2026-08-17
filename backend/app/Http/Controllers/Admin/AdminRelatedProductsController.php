<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\ContentRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use App\Models\Product;
use App\Services\Content\RelatedProductsCatalogValidator;
use App\Services\Content\RelatedProductsContentDefinition;
use App\Services\ContentRevisionService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

final class AdminRelatedProductsController extends Controller
{
    public function __construct(
        private readonly ContentRevisionService $content,
        private readonly RelatedProductsCatalogValidator $catalogValidator,
    ) {}

    public function edit(Request $request): View
    {
        $entry = ContentEntry::query()
            ->where('content_key', RelatedProductsContentDefinition::KEY)
            ->first();

        if ($entry === null) {
            $entry = $this->content->saveDraft(
                contentKey: RelatedProductsContentDefinition::KEY,
                contentType: RelatedProductsContentDefinition::TYPE,
                payload: RelatedProductsContentDefinition::defaultPayload(),
                expectedRevision: 0,
                actorFingerprint: $this->actorFingerprint($request),
            );
        }

        if ($entry->content_type !== RelatedProductsContentDefinition::TYPE) {
            abort(409, 'The reserved pdp.related_products content key has an incompatible content type.');
        }

        $entry->load(['revisions' => fn ($query) => $query->orderByDesc('revision')]);

        return view('admin.content.related-products', [
            'entry' => $entry,
            'draft' => RelatedProductsContentDefinition::editablePayload($entry->draft_payload),
            'published' => $entry->published_payload === null
                ? null
                : RelatedProductsContentDefinition::editablePayload($entry->published_payload),
            'products' => $this->visibleProducts(),
            'maxRelated' => RelatedProductsContentDefinition::MAX_RELATED,
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'related' => ['sometimes', 'array'],
            'order' => ['sometimes', 'array'],
        ]);

        $payload = $this->catalogValidator->validate(
            RelatedProductsContentDefinition::validateAndNormalize(
                $this->payloadFromRequest($request),
            ),
        );

        try {
            $this->content->saveDraft(
                contentKey: RelatedProductsContentDefinition::KEY,
                contentType: RelatedProductsContentDefinition::TYPE,
                payload: $payload,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.pdp.related-products.edit')
                ->withErrors([
                    'revision' => 'Related products changed in another session. Review the current draft before saving again.',
                ]);
        }

        return redirect()
            ->route('admin.content.pdp.related-products.edit')
            ->with('status', 'Related-product draft saved. Live PDPs remain unchanged until Publish is used.');
    }

    public function publish(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
        ]);
        $entry = $this->entry();

        $this->catalogValidator->validate(
            RelatedProductsContentDefinition::validateAndNormalize($entry->draft_payload),
        );

        try {
            $this->content->publish(
                contentKey: RelatedProductsContentDefinition::KEY,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.pdp.related-products.edit')
                ->withErrors([
                    'revision' => 'Publish blocked because related products changed in another session.',
                ]);
        }

        return redirect()
            ->route('admin.content.pdp.related-products.edit')
            ->with('status', 'Related products published for compatible dynamic PDPs.');
    }

    public function restore(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'source_revision' => ['required', 'integer', 'min:1'],
        ]);

        try {
            $this->content->restoreDraftFromRevision(
                contentKey: RelatedProductsContentDefinition::KEY,
                revisionToRestore: (int) $validated['source_revision'],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.pdp.related-products.edit')
                ->withErrors([
                    'revision' => 'Restore blocked because related products changed in another session.',
                ]);
        }

        return redirect()
            ->route('admin.content.pdp.related-products.edit')
            ->with('status', 'Historical relationships restored into a new private draft.');
    }

    /** @return array{relationships: list<array{product_id: string, related_product_ids: list<string>}>} */
    private function payloadFromRequest(Request $request): array
    {
        $productIds = $this->visibleProducts()
            ->pluck('id')
            ->map(static fn ($id): string => (string) $id)
            ->all();
        $known = array_fill_keys($productIds, true);

        $rawRelated = $request->input('related', []);
        $rawOrder = $request->input('order', []);
        if (! is_array($rawRelated) || ! is_array($rawOrder)) {
            throw ValidationException::withMessages([
                'related' => ['Related-product controls must be structured arrays.'],
            ]);
        }

        foreach (array_keys($rawRelated) as $sourceId) {
            if (! is_string($sourceId) || ! isset($known[$sourceId])) {
                throw ValidationException::withMessages([
                    'related' => ['Unknown or hidden source product ID was submitted.'],
                ]);
            }
            if (! is_array($rawRelated[$sourceId])) {
                throw ValidationException::withMessages([
                    "related.$sourceId" => ['Related-product selection must be an object.'],
                ]);
            }
            foreach (array_keys($rawRelated[$sourceId]) as $candidateId) {
                if (! is_string($candidateId) || ! isset($known[$candidateId]) || $candidateId === $sourceId) {
                    throw ValidationException::withMessages([
                        "related.$sourceId" => ['Unknown, hidden or self-referencing related product was submitted.'],
                    ]);
                }
            }
        }

        $relationships = [];
        foreach ($productIds as $sourceId) {
            $selected = [];
            foreach ($productIds as $candidateId) {
                if ($candidateId === $sourceId || ! $request->boolean("related.$sourceId.$candidateId")) {
                    continue;
                }

                $position = data_get($rawOrder, "$sourceId.$candidateId");
                if (filter_var($position, FILTER_VALIDATE_INT) === false || (int) $position < 1 || (int) $position > RelatedProductsContentDefinition::MAX_RELATED) {
                    throw ValidationException::withMessages([
                        "order.$sourceId.$candidateId" => [
                            sprintf('Selected related products need an order from 1 to %d.', RelatedProductsContentDefinition::MAX_RELATED),
                        ],
                    ]);
                }
                $selected[] = ['id' => $candidateId, 'position' => (int) $position];
            }

            if (count($selected) > RelatedProductsContentDefinition::MAX_RELATED) {
                throw ValidationException::withMessages([
                    "related.$sourceId" => [
                        sprintf('Choose at most %d related products.', RelatedProductsContentDefinition::MAX_RELATED),
                    ],
                ]);
            }

            $positions = array_column($selected, 'position');
            if (count($positions) !== count(array_unique($positions))) {
                throw ValidationException::withMessages([
                    "order.$sourceId" => ['Selected related products must use unique order positions.'],
                ]);
            }

            usort(
                $selected,
                static fn (array $left, array $right): int => ($left['position'] <=> $right['position']) ?: ($left['id'] <=> $right['id']),
            );

            $relationships[] = [
                'product_id' => $sourceId,
                'related_product_ids' => array_column($selected, 'id'),
            ];
        }

        return ['relationships' => $relationships];
    }

    private function entry(): ContentEntry
    {
        $entry = ContentEntry::query()
            ->where('content_key', RelatedProductsContentDefinition::KEY)
            ->firstOrFail();

        if ($entry->content_type !== RelatedProductsContentDefinition::TYPE) {
            throw ValidationException::withMessages([
                'content_type' => ['The reserved pdp.related_products key has an incompatible content type.'],
            ]);
        }

        return $entry;
    }

    private function visibleProducts()
    {
        return Product::query()
            ->where('is_visible', true)
            ->whereHas('categoryEntity', fn ($query) => $query->where('is_visible', true))
            ->whereHas('variants', fn ($query) => $query->where('is_visible', true))
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get(['id', 'name', 'is_visible']);
    }

    private function actorFingerprint(Request $request): string
    {
        $fingerprint = (string) $request->session()->get('walka_admin_dashboard_actor', '');

        return $fingerprint !== ''
            ? $fingerprint
            : hash('sha256', 'dashboard|'.$request->session()->getId());
    }
}
