<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\ContentRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Services\Content\HomeFeaturedCatalogValidator;
use App\Services\Content\HomeFeaturedContentDefinition;
use App\Services\ContentRevisionService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

final class AdminHomeFeaturedController extends Controller
{
    public function __construct(
        private readonly ContentRevisionService $content,
        private readonly HomeFeaturedCatalogValidator $catalogValidator,
    ) {}

    public function edit(Request $request): View
    {
        $entry = ContentEntry::query()
            ->where('content_key', HomeFeaturedContentDefinition::KEY)
            ->first();

        if ($entry === null) {
            $payload = $this->catalogValidator->validate(
                HomeFeaturedContentDefinition::validateAndNormalize(
                    $this->dashboardBootstrapPayload(),
                ),
            );
            $entry = $this->content->saveDraft(
                contentKey: HomeFeaturedContentDefinition::KEY,
                contentType: HomeFeaturedContentDefinition::TYPE,
                payload: $payload,
                expectedRevision: 0,
                actorFingerprint: $this->actorFingerprint($request),
            );
        }

        abort_unless(
            $entry->content_type === HomeFeaturedContentDefinition::TYPE,
            409,
            'The reserved home.featured content key has an incompatible content type.',
        );

        $entry->load(['revisions' => fn ($query) => $query->orderByDesc('revision')]);

        return view('admin.content.home-featured', [
            'entry' => $entry,
            'draft' => HomeFeaturedContentDefinition::validateAndNormalize($entry->draft_payload),
            'published' => $entry->published_payload === null
                ? null
                : HomeFeaturedContentDefinition::validateAndNormalize($entry->published_payload),
            'variants' => $this->visibleVariants(),
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'collection_variant_ids' => ['required', 'array', 'size:2'],
            'collection_variant_ids.*' => ['required', 'string', 'max:160'],
            'editorial_variant_id' => ['required', 'string', 'max:160'],
        ]);

        $payload = $this->catalogValidator->validate(
            HomeFeaturedContentDefinition::validateAndNormalize($validated),
        );

        try {
            $this->content->saveDraft(
                contentKey: HomeFeaturedContentDefinition::KEY,
                contentType: HomeFeaturedContentDefinition::TYPE,
                payload: $payload,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.home.featured.edit')
                ->withErrors([
                    'revision' => 'Featured merchandising changed in another session. Review the current draft before saving again.',
                ]);
        }

        return redirect()
            ->route('admin.content.home.featured.edit')
            ->with('status', 'Featured merchandising draft saved. Live Home membership has not changed until Publish is used.');
    }

    public function publish(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
        ]);
        $entry = $this->entry();
        $this->catalogValidator->validate(
            HomeFeaturedContentDefinition::validateAndNormalize($entry->draft_payload),
        );

        try {
            $this->content->publish(
                contentKey: HomeFeaturedContentDefinition::KEY,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.home.featured.edit')
                ->withErrors([
                    'revision' => 'Publish blocked because featured merchandising changed in another session.',
                ]);
        }

        return redirect()
            ->route('admin.content.home.featured.edit')
            ->with('status', 'Featured merchandising published. Compatible clients can use the new Dashboard-selected variants without a new app build.');
    }

    public function restore(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'source_revision' => ['required', 'integer', 'min:1'],
        ]);

        try {
            $this->content->restoreDraftFromRevision(
                contentKey: HomeFeaturedContentDefinition::KEY,
                revisionToRestore: (int) $validated['source_revision'],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.home.featured.edit')
                ->withErrors([
                    'revision' => 'Restore blocked because featured merchandising changed in another session.',
                ]);
        }

        return redirect()
            ->route('admin.content.home.featured.edit')
            ->with('status', 'Historical featured membership restored into a new private draft. Review it before publishing.');
    }

    /**
     * Choose an initial owner-editable Home selection from current Dashboard
     * truth only: the first visible variant from the first two visible product
     * families, with the first selected variant as the editorial default.
     *
     * @return array{collection_variant_ids:list<string>,editorial_variant_id:string}
     */
    private function dashboardBootstrapPayload(): array
    {
        $products = $this->visibleProducts();
        if ($products->count() < 2) {
            throw ValidationException::withMessages([
                'collection_variant_ids' => [
                    'Home Featured requires at least two visible Dashboard product families with visible variants.',
                ],
            ]);
        }

        $collection = $products
            ->take(2)
            ->map(fn (Product $product): string => (string) $product->variants->firstOrFail()->id)
            ->values()
            ->all();

        return [
            'collection_variant_ids' => $collection,
            'editorial_variant_id' => $collection[0],
        ];
    }

    /** @return Collection<int, Product> */
    private function visibleProducts(): Collection
    {
        return Product::query()
            ->where('is_visible', true)
            ->whereHas('categoryEntity', fn ($query) => $query->where('is_visible', true))
            ->whereHas('variants', fn ($query) => $query->where('is_visible', true))
            ->with(['variants' => fn ($query) => $query
                ->where('is_visible', true)
                ->orderBy('sort_order')
                ->orderBy('id')])
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();
    }

    /** @return Collection<int, ProductVariant> */
    private function visibleVariants(): Collection
    {
        return $this->visibleProducts()
            ->flatMap(fn (Product $product): Collection => $product->variants)
            ->values();
    }

    private function entry(): ContentEntry
    {
        return ContentEntry::query()
            ->where('content_key', HomeFeaturedContentDefinition::KEY)
            ->where('content_type', HomeFeaturedContentDefinition::TYPE)
            ->firstOrFail();
    }

    private function actorFingerprint(Request $request): string
    {
        $fingerprint = (string) $request->session()->get('walka_admin_dashboard_actor', '');

        return $fingerprint !== ''
            ? $fingerprint
            : hash('sha256', 'dashboard|'.$request->session()->getId());
    }
}
