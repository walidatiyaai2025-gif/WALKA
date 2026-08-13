<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\ContentRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use App\Models\Product;
use App\Services\Content\CategoryPresentationCatalogValidator;
use App\Services\Content\CategoryPresentationContentDefinition;
use App\Services\ContentRevisionService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

final class AdminCategoryPresentationController extends Controller
{
    public function __construct(
        private readonly ContentRevisionService $content,
        private readonly CategoryPresentationCatalogValidator $catalogValidator,
    ) {}

    public function edit(Request $request): View
    {
        $entry = ContentEntry::query()
            ->where('content_key', CategoryPresentationContentDefinition::KEY)
            ->first();

        if ($entry === null) {
            $payload = $this->catalogValidator->validate(
                CategoryPresentationContentDefinition::validateAndNormalize(
                    CategoryPresentationContentDefinition::defaultPayload(),
                ),
            );
            $entry = $this->content->saveDraft(
                contentKey: CategoryPresentationContentDefinition::KEY,
                contentType: CategoryPresentationContentDefinition::TYPE,
                payload: $payload,
                expectedRevision: 0,
                actorFingerprint: $this->actorFingerprint($request),
            );
        }

        abort_unless(
            $entry->content_type === CategoryPresentationContentDefinition::TYPE,
            409,
            'The reserved categories.presentation content key has an incompatible content type.',
        );

        $entry->load(['revisions' => fn ($query) => $query->orderByDesc('revision')]);
        $draft = CategoryPresentationContentDefinition::validateAndNormalize($entry->draft_payload);
        $published = $entry->published_payload === null
            ? null
            : CategoryPresentationContentDefinition::validateAndNormalize($entry->published_payload);

        $productCounts = Product::query()
            ->withCount('variants')
            ->orderBy('sort_order')
            ->get()
            ->groupBy('category')
            ->map(fn ($products): int => (int) $products->sum('variants_count'));

        return view('admin.content.categories', [
            'entry' => $entry,
            'draft' => $draft,
            'published' => $published,
            'productCounts' => $productCounts,
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'categories' => ['required', 'array', 'min:1'],
            'categories.*.id' => ['required', 'string', 'max:120', 'distinct'],
            'categories.*.position' => ['required', 'integer', 'min:1', 'distinct'],
            'categories.*.display_name' => ['required', 'string', 'max:80'],
            'categories.*.description' => ['required', 'string', 'max:240'],
            'categories.*.visible' => ['required', 'boolean'],
        ]);

        $categories = collect($validated['categories'])
            ->sortBy(fn (array $category): int => (int) $category['position'])
            ->values()
            ->map(fn (array $category): array => [
                'id' => $category['id'],
                'display_name' => $category['display_name'],
                'description' => $category['description'],
                'visible' => (bool) $category['visible'],
            ])
            ->all();

        $payload = $this->catalogValidator->validate(
            CategoryPresentationContentDefinition::validateAndNormalize([
                'categories' => $categories,
            ]),
        );

        try {
            $this->content->saveDraft(
                contentKey: CategoryPresentationContentDefinition::KEY,
                contentType: CategoryPresentationContentDefinition::TYPE,
                payload: $payload,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.categories.edit')
                ->withErrors([
                    'revision' => 'Category presentation changed in another session. Review the current draft before saving again.',
                ]);
        }

        return redirect()
            ->route('admin.content.categories.edit')
            ->with('status', 'Category presentation draft saved. The live discovery screen has not changed until Publish is used.');
    }

    public function publish(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
        ]);
        $entry = $this->entry();
        $this->catalogValidator->validate(
            CategoryPresentationContentDefinition::validateAndNormalize($entry->draft_payload),
        );

        try {
            $this->content->publish(
                contentKey: CategoryPresentationContentDefinition::KEY,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.categories.edit')
                ->withErrors([
                    'revision' => 'Publish blocked because category presentation changed in another session.',
                ]);
        }

        return redirect()
            ->route('admin.content.categories.edit')
            ->with('status', 'Category presentation published. Compatible clients can use the new names, order and visibility without a new app build.');
    }

    public function restore(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'source_revision' => ['required', 'integer', 'min:1'],
        ]);

        try {
            $this->content->restoreDraftFromRevision(
                contentKey: CategoryPresentationContentDefinition::KEY,
                revisionToRestore: (int) $validated['source_revision'],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.categories.edit')
                ->withErrors([
                    'revision' => 'Restore blocked because category presentation changed in another session.',
                ]);
        }

        return redirect()
            ->route('admin.content.categories.edit')
            ->with('status', 'Historical category presentation restored into a private draft. Review it before publishing.');
    }

    private function entry(): ContentEntry
    {
        $entry = ContentEntry::query()
            ->where('content_key', CategoryPresentationContentDefinition::KEY)
            ->firstOrFail();

        if ($entry->content_type !== CategoryPresentationContentDefinition::TYPE) {
            throw ValidationException::withMessages([
                'content_type' => ['The reserved categories.presentation key has an incompatible content type.'],
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
