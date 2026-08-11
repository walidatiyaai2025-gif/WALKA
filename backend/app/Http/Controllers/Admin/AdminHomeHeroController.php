<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\ContentRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use App\Services\Content\HomeHeroContentDefinition;
use App\Services\ContentRevisionService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

final class AdminHomeHeroController extends Controller
{
    public function __construct(private readonly ContentRevisionService $content) {}

    public function edit(Request $request): View
    {
        $entry = ContentEntry::query()
            ->where('content_key', HomeHeroContentDefinition::KEY)
            ->first();

        if ($entry === null) {
            $entry = $this->content->saveDraft(
                contentKey: HomeHeroContentDefinition::KEY,
                contentType: HomeHeroContentDefinition::TYPE,
                payload: HomeHeroContentDefinition::defaultPayload(),
                expectedRevision: 0,
                actorFingerprint: $this->actorFingerprint($request),
            );
        }

        if ($entry->content_type !== HomeHeroContentDefinition::TYPE) {
            abort(409, 'The reserved home.hero content key has an incompatible content type.');
        }

        $entry->load(['revisions' => fn ($query) => $query->orderByDesc('revision')]);

        return view('admin.content.home-hero', [
            'entry' => $entry,
            'draft' => HomeHeroContentDefinition::editableFields($entry->draft_payload),
            'published' => $entry->published_payload === null
                ? null
                : HomeHeroContentDefinition::editableFields($entry->published_payload),
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate(array_merge(
            ['revision' => ['required', 'integer', 'min:1']],
            HomeHeroContentDefinition::rules(),
        ));

        $payload = HomeHeroContentDefinition::validateAndNormalize($validated);

        try {
            $this->content->saveDraft(
                contentKey: HomeHeroContentDefinition::KEY,
                contentType: HomeHeroContentDefinition::TYPE,
                payload: $payload,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.home.hero.edit')
                ->withErrors([
                    'revision' => 'Home Hero changed in another session. Current values were reloaded; review them before saving again.',
                ]);
        }

        return redirect()
            ->route('admin.content.home.hero.edit')
            ->with('status', 'Home Hero draft saved. The live mobile Home has not changed until Publish is used.');
    }

    public function publish(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
        ]);

        $entry = $this->entry();
        HomeHeroContentDefinition::validateAndNormalize($entry->draft_payload);

        try {
            $this->content->publish(
                contentKey: HomeHeroContentDefinition::KEY,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.home.hero.edit')
                ->withErrors([
                    'revision' => 'Publish blocked because Home Hero changed in another session. Review the latest draft first.',
                ]);
        }

        return redirect()
            ->route('admin.content.home.hero.edit')
            ->with('status', 'Home Hero published. Compatible mobile clients can consume the new published revision without a new app build.');
    }

    public function restore(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'source_revision' => ['required', 'integer', 'min:1'],
        ]);

        try {
            $this->content->restoreDraftFromRevision(
                contentKey: HomeHeroContentDefinition::KEY,
                revisionToRestore: (int) $validated['source_revision'],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.home.hero.edit')
                ->withErrors([
                    'revision' => 'Restore blocked because Home Hero changed in another session. Reload and review the latest revision.',
                ]);
        }

        return redirect()
            ->route('admin.content.home.hero.edit')
            ->with('status', 'Historical Home Hero snapshot restored into a new draft. Review it before publishing.');
    }

    private function entry(): ContentEntry
    {
        $entry = ContentEntry::query()
            ->where('content_key', HomeHeroContentDefinition::KEY)
            ->firstOrFail();

        if ($entry->content_type !== HomeHeroContentDefinition::TYPE) {
            throw ValidationException::withMessages([
                'content_type' => ['The reserved home.hero key has an incompatible content type.'],
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
