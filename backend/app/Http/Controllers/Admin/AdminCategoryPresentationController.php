<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\ContentRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\CatalogCategory;
use App\Models\ContentEntry;
use App\Models\Product;
use App\Services\Content\CategoryPresentationCatalogValidator;
use App\Services\Content\CategoryPresentationContentDefinition;
use App\Services\ContentRevisionService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
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
                CategoryPresentationContentDefinition::validateAndNormalize([
                    'categories' => $this->editableCategories([]),
                ]),
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

        return view('admin.content.categories', [
            'entry' => $entry,
            'draft' => ['categories' => $this->editableCategories($draft['categories'])],
            'published' => $published,
            'productCounts' => $this->publicProductCounts(),
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
            ->with('status', 'Category presentation draft saved. Live Categories remains unchanged until Publish is used.');
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
                    'revision' => 'Publish blocked because Category presentation changed in another session.',
                ]);
        }

        return redirect()
            ->route('admin.content.categories.edit')
            ->with('status', 'Category presentation published. Compatible clients can use the new order and copy without a new app build.');
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
                    'revision' => 'Restore blocked because Category presentation changed in another session.',
                ]);
        }

        return redirect()
            ->route('admin.content.categories.edit')
            ->with('status', 'Historical Category presentation restored into a private draft. Review it before publishing.');
    }

    /**
     * Merge the optional CMS overlay with the current visible Dashboard catalog.
     * Existing CMS order wins; newly-created categories append in catalog order.
     * Hidden/deleted catalog categories are omitted from the editor so saving the
     * form reconciles stale rows without inventing identities.
     *
     * @param  list<array{id:string,display_name:string,description:string,visible:bool}>  $existing
     * @return list<array{id:string,display_name:string,description:string,visible:bool}>
     */
    private function editableCategories(array $existing): array
    {
        $catalog = CatalogCategory::query()
            ->where('is_visible', true)
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get(['id', 'name'])
            ->keyBy('id');

        if ($catalog->isEmpty()) {
            throw ValidationException::withMessages([
                'categories' => ['Create and show at least one Dashboard catalog category before editing Categories presentation.'],
            ]);
        }

        $existingById = collect($existing)->keyBy('id');
        $orderedIds = collect($existing)
            ->pluck('id')
            ->filter(fn (mixed $id): bool => is_string($id) && $catalog->has($id))
            ->values();

        foreach ($catalog->keys() as $id) {
            if (! $orderedIds->contains($id)) {
                $orderedIds->push($id);
            }
        }

        return $orderedIds
            ->map(function (string $id) use ($catalog, $existingById): array {
                $category = $catalog->get($id);
                $overlay = $existingById->get($id);

                return [
                    'id' => $id,
                    'display_name' => is_array($overlay)
                        ? (string) $overlay['display_name']
                        : (string) $category->name,
                    'description' => is_array($overlay)
                        ? (string) $overlay['description']
                        : (string) $category->name,
                    'visible' => is_array($overlay)
                        ? (bool) $overlay['visible']
                        : true,
                ];
            })
            ->values()
            ->all();
    }

    /**
     * @return Collection<string, int>
     */
    private function publicProductCounts(): Collection
    {
        return Product::query()
            ->where('is_visible', true)
            ->whereHas('variants', fn ($query) => $query->where('is_visible', true))
            ->get(['id', 'category_id'])
            ->groupBy('category_id')
            ->map(fn (Collection $products): int => $products->count());
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
