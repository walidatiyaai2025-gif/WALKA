<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\ContentRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use App\Services\Content\StorefrontCopyContentDefinition;
use App\Services\ContentRevisionService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

final class AdminStorefrontCopyController extends Controller
{
    public function __construct(private readonly ContentRevisionService $content) {}

    public function edit(Request $request): View
    {
        $entry = ContentEntry::query()
            ->where('content_key', StorefrontCopyContentDefinition::KEY)
            ->first();

        if ($entry === null) {
            $entry = $this->content->saveDraft(
                contentKey: StorefrontCopyContentDefinition::KEY,
                contentType: StorefrontCopyContentDefinition::TYPE,
                payload: StorefrontCopyContentDefinition::defaultPayload(),
                expectedRevision: 0,
                actorFingerprint: $this->actorFingerprint($request),
            );
        }

        abort_unless(
            $entry->content_type === StorefrontCopyContentDefinition::TYPE,
            409,
            'The reserved storefront.copy content key has an incompatible content type.',
        );

        $entry->load(['revisions' => fn ($query) => $query->orderByDesc('revision')]);

        return view('admin.content.storefront-copy', [
            'entry' => $entry,
            'draft' => StorefrontCopyContentDefinition::editableFields($entry->draft_payload),
            'published' => $entry->published_payload === null
                ? null
                : StorefrontCopyContentDefinition::editableFields($entry->published_payload),
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate(array_merge(
            ['revision' => ['required', 'integer', 'min:1']],
            StorefrontCopyContentDefinition::rules(),
        ));
        $payload = StorefrontCopyContentDefinition::validateAndNormalize($validated);

        try {
            $this->content->saveDraft(
                contentKey: StorefrontCopyContentDefinition::KEY,
                contentType: StorefrontCopyContentDefinition::TYPE,
                payload: $payload,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.storefront.copy.edit')
                ->withErrors(['revision' => 'Storefront copy changed in another session. Reload before saving.']);
        }

        return redirect()
            ->route('admin.content.storefront.copy.edit')
            ->with('status', 'Storefront copy draft saved. Live clients remain unchanged until Publish.');
    }

    public function publish(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
        ]);
        $entry = $this->entry();
        StorefrontCopyContentDefinition::validateAndNormalize($entry->draft_payload);

        try {
            $this->content->publish(
                contentKey: StorefrontCopyContentDefinition::KEY,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.storefront.copy.edit')
                ->withErrors(['revision' => 'Publish blocked because Storefront copy changed in another session.']);
        }

        return redirect()
            ->route('admin.content.storefront.copy.edit')
            ->with('status', 'Storefront copy published. Compatible clients can consume it without an app build.');
    }

    public function restore(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'source_revision' => ['required', 'integer', 'min:1'],
        ]);

        try {
            $this->content->restoreDraftFromRevision(
                contentKey: StorefrontCopyContentDefinition::KEY,
                revisionToRestore: (int) $validated['source_revision'],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.storefront.copy.edit')
                ->withErrors(['revision' => 'Restore blocked because Storefront copy changed in another session.']);
        }

        return redirect()
            ->route('admin.content.storefront.copy.edit')
            ->with('status', 'Historical Storefront copy restored into a private draft. Review it before publishing.');
    }

    private function entry(): ContentEntry
    {
        $entry = ContentEntry::query()
            ->where('content_key', StorefrontCopyContentDefinition::KEY)
            ->firstOrFail();
        if ($entry->content_type !== StorefrontCopyContentDefinition::TYPE) {
            throw ValidationException::withMessages([
                'content_type' => ['The reserved storefront.copy key has an incompatible content type.'],
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
