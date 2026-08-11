<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\ContentRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use App\Services\Content\HomeLayoutContentDefinition;
use App\Services\ContentRevisionService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

final class AdminHomeLayoutController extends Controller
{
    public function __construct(private readonly ContentRevisionService $content) {}

    public function edit(Request $request): View
    {
        $entry = ContentEntry::query()
            ->where('content_key', HomeLayoutContentDefinition::KEY)
            ->first();

        if ($entry === null) {
            $entry = $this->content->saveDraft(
                contentKey: HomeLayoutContentDefinition::KEY,
                contentType: HomeLayoutContentDefinition::TYPE,
                payload: HomeLayoutContentDefinition::defaultPayload(),
                expectedRevision: 0,
                actorFingerprint: $this->actorFingerprint($request),
            );
        }

        if ($entry->content_type !== HomeLayoutContentDefinition::TYPE) {
            abort(409, 'The reserved home.layout content key has an incompatible content type.');
        }

        $entry->load(['revisions' => fn ($query) => $query->orderByDesc('revision')]);

        return view('admin.content.home-layout', [
            'entry' => $entry,
            'draft' => HomeLayoutContentDefinition::editablePayload($entry->draft_payload),
            'published' => $entry->published_payload === null
                ? null
                : HomeLayoutContentDefinition::editablePayload($entry->published_payload),
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'order' => ['required', 'array'],
            'order.*' => ['required', 'integer', 'min:1', 'max:5'],
            'visible' => ['required', 'array'],
            'collection_eyebrow' => ['required', 'string', 'max:80'],
            'collection_title' => ['required', 'string', 'max:120'],
            'small_changes_title' => ['required', 'string', 'max:120'],
            'small_changes_body' => ['required', 'string', 'max:300'],
        ]);

        $payload = $this->payloadFromRequest($request, $validated);

        try {
            $this->content->saveDraft(
                contentKey: HomeLayoutContentDefinition::KEY,
                contentType: HomeLayoutContentDefinition::TYPE,
                payload: $payload,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.home.layout.edit')
                ->withErrors([
                    'revision' => 'Home layout changed in another session. Current values were reloaded; review before saving again.',
                ]);
        }

        return redirect()
            ->route('admin.content.home.layout.edit')
            ->with('status', 'Home layout draft saved. The live Home order and visibility have not changed until Publish is used.');
    }

    public function publish(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
        ]);

        $entry = $this->entry();
        HomeLayoutContentDefinition::validateAndNormalize($entry->draft_payload);

        try {
            $this->content->publish(
                contentKey: HomeLayoutContentDefinition::KEY,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.home.layout.edit')
                ->withErrors([
                    'revision' => 'Publish blocked because Home layout changed in another session. Review the latest draft first.',
                ]);
        }

        return redirect()
            ->route('admin.content.home.layout.edit')
            ->with('status', 'Home layout published. Compatible clients can apply the new approved section order and visibility without a new app build.');
    }

    public function restore(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'source_revision' => ['required', 'integer', 'min:1'],
        ]);

        try {
            $this->content->restoreDraftFromRevision(
                contentKey: HomeLayoutContentDefinition::KEY,
                revisionToRestore: (int) $validated['source_revision'],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.home.layout.edit')
                ->withErrors([
                    'revision' => 'Restore blocked because Home layout changed in another session. Reload and review the latest revision.',
                ]);
        }

        return redirect()
            ->route('admin.content.home.layout.edit')
            ->with('status', 'Historical Home layout restored into a new private draft. Review it before publishing.');
    }

    /**
     * @param  array<string, mixed>  $validated
     * @return array<string, mixed>
     */
    private function payloadFromRequest(Request $request, array $validated): array
    {
        $orders = $validated['order'];
        $expectedIds = HomeLayoutContentDefinition::sectionIds();

        if (array_diff($expectedIds, array_keys($orders)) !== [] ||
            array_diff(array_keys($orders), $expectedIds) !== []) {
            throw ValidationException::withMessages([
                'order' => ['Every supported Home section must have exactly one order value.'],
            ]);
        }

        $positions = array_map('intval', array_values($orders));
        sort($positions);
        if ($positions !== range(1, count($expectedIds))) {
            throw ValidationException::withMessages([
                'order' => ['Section order values must be unique and use every position from 1 through 5.'],
            ]);
        }

        $sectionsById = [];
        foreach ($expectedIds as $id) {
            $visible = $request->boolean("visible.$id");
            if (in_array($id, [HomeLayoutContentDefinition::HERO, HomeLayoutContentDefinition::COLLECTION], true) && ! $visible) {
                throw ValidationException::withMessages([
                    "visible.$id" => [sprintf('The %s section is required and cannot be hidden.', $id)],
                ]);
            }

            $section = ['id' => $id, 'visible' => $visible];
            if ($id === HomeLayoutContentDefinition::COLLECTION) {
                $section['eyebrow'] = (string) $validated['collection_eyebrow'];
                $section['title'] = (string) $validated['collection_title'];
            } elseif ($id === HomeLayoutContentDefinition::SMALL_CHANGES) {
                $section['title'] = (string) $validated['small_changes_title'];
                $section['body'] = (string) $validated['small_changes_body'];
            }

            $sectionsById[$id] = $section;
        }

        uasort(
            $sectionsById,
            fn (array $left, array $right): int => ((int) $orders[$left['id']]) <=> ((int) $orders[$right['id']]),
        );

        return HomeLayoutContentDefinition::validateAndNormalize([
            'sections' => array_values($sectionsById),
        ]);
    }

    private function entry(): ContentEntry
    {
        $entry = ContentEntry::query()
            ->where('content_key', HomeLayoutContentDefinition::KEY)
            ->firstOrFail();

        if ($entry->content_type !== HomeLayoutContentDefinition::TYPE) {
            throw ValidationException::withMessages([
                'content_type' => ['The reserved home.layout key has an incompatible content type.'],
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
