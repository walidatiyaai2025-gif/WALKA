<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\ContentRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use App\Models\ProductVariant;
use App\Services\Content\SearchPresentationCatalogValidator;
use App\Services\Content\SearchPresentationContentDefinition;
use App\Services\ContentRevisionService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

final class AdminSearchPresentationController extends Controller
{
    public function __construct(
        private readonly ContentRevisionService $content,
        private readonly SearchPresentationCatalogValidator $catalogValidator,
    ) {}

    public function edit(Request $request): View
    {
        $entry = ContentEntry::query()
            ->where('content_key', SearchPresentationContentDefinition::KEY)
            ->first();

        if ($entry === null) {
            $payload = $this->catalogValidator->validate(
                SearchPresentationContentDefinition::validateAndNormalize(
                    SearchPresentationContentDefinition::defaultPayload(),
                ),
            );
            $entry = $this->content->saveDraft(
                contentKey: SearchPresentationContentDefinition::KEY,
                contentType: SearchPresentationContentDefinition::TYPE,
                payload: $payload,
                expectedRevision: 0,
                actorFingerprint: $this->actorFingerprint($request),
            );
        }

        abort_unless(
            $entry->content_type === SearchPresentationContentDefinition::TYPE,
            409,
            'The reserved search.presentation content key has an incompatible content type.',
        );

        $entry->load(['revisions' => fn ($query) => $query->orderByDesc('revision')]);
        $draft = SearchPresentationContentDefinition::validateAndNormalize($entry->draft_payload);
        $published = $entry->published_payload === null
            ? null
            : SearchPresentationContentDefinition::validateAndNormalize($entry->published_payload);

        $variants = ProductVariant::query()
            ->with('product')
            ->get()
            ->keyBy('id');

        return view('admin.content.search', [
            'entry' => $entry,
            'draft' => $draft,
            'published' => $published,
            'variants' => $variants,
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'heading' => ['required', 'string', 'max:80'],
            'supporting_copy' => ['required', 'string', 'max:240'],
            'placeholder' => ['required', 'string', 'max:100'],
            'empty_title' => ['required', 'string', 'max:100'],
            'empty_body' => ['required', 'string', 'max:240'],
            'variants' => ['required', 'array', 'min:1'],
            'variants.*.id' => ['required', 'string', 'max:160', 'distinct'],
            'variants.*.position' => ['required', 'integer', 'min:1', 'distinct'],
            'filter_labels' => ['required', 'array', 'min:1'],
            'filter_labels.*.id' => ['required', 'string', 'max:120', 'distinct'],
            'filter_labels.*.label' => ['required', 'string', 'max:40'],
        ]);

        $featuredVariantIds = collect($validated['variants'])
            ->sortBy(fn (array $variant): int => (int) $variant['position'])
            ->values()
            ->pluck('id')
            ->all();

        $payload = $this->catalogValidator->validate(
            SearchPresentationContentDefinition::validateAndNormalize([
                'heading' => $validated['heading'],
                'supporting_copy' => $validated['supporting_copy'],
                'placeholder' => $validated['placeholder'],
                'empty_title' => $validated['empty_title'],
                'empty_body' => $validated['empty_body'],
                'featured_variant_ids' => $featuredVariantIds,
                'filter_labels' => collect($validated['filter_labels'])
                    ->map(fn (array $filter): array => [
                        'id' => $filter['id'],
                        'label' => $filter['label'],
                    ])
                    ->all(),
            ]),
        );

        try {
            $this->content->saveDraft(
                contentKey: SearchPresentationContentDefinition::KEY,
                contentType: SearchPresentationContentDefinition::TYPE,
                payload: $payload,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.search.edit')
                ->withErrors([
                    'revision' => 'Search presentation changed in another session. Review the current draft before saving again.',
                ]);
        }

        return redirect()
            ->route('admin.content.search.edit')
            ->with('status', 'Search presentation draft saved. Live Search remains unchanged until Publish is used.');
    }

    public function publish(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
        ]);
        $entry = $this->entry();
        $this->catalogValidator->validate(
            SearchPresentationContentDefinition::validateAndNormalize($entry->draft_payload),
        );

        try {
            $this->content->publish(
                contentKey: SearchPresentationContentDefinition::KEY,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.search.edit')
                ->withErrors([
                    'revision' => 'Publish blocked because Search presentation changed in another session.',
                ]);
        }

        return redirect()
            ->route('admin.content.search.edit')
            ->with('status', 'Search presentation published. Compatible clients can use the new copy and merchandising order without a new app build.');
    }

    public function restore(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'source_revision' => ['required', 'integer', 'min:1'],
        ]);

        try {
            $this->content->restoreDraftFromRevision(
                contentKey: SearchPresentationContentDefinition::KEY,
                revisionToRestore: (int) $validated['source_revision'],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.search.edit')
                ->withErrors([
                    'revision' => 'Restore blocked because Search presentation changed in another session.',
                ]);
        }

        return redirect()
            ->route('admin.content.search.edit')
            ->with('status', 'Historical Search presentation restored into a private draft. Review it before publishing.');
    }

    private function entry(): ContentEntry
    {
        $entry = ContentEntry::query()
            ->where('content_key', SearchPresentationContentDefinition::KEY)
            ->firstOrFail();

        if ($entry->content_type !== SearchPresentationContentDefinition::TYPE) {
            throw ValidationException::withMessages([
                'content_type' => ['The reserved search.presentation key has an incompatible content type.'],
            ]);
        }

        return $entry;
    }

    private function actorFingerprint(Request $request): string
    {
        $fingerprint = (string) $request->session()->get('walka_admin_dashboard_actor', '');

        return $fingerprint !== ''
            ? $fingerprint
            : hash('sha256', 'dashboard|'.$request->session()->getId());
    }
}
