<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\ContentRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use App\Services\Content\HomeBannerContentDefinition;
use App\Services\ContentRevisionService;
use Carbon\CarbonImmutable;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

final class AdminHomeBannerController extends Controller
{
    public function __construct(private readonly ContentRevisionService $content) {}

    public function edit(Request $request): View
    {
        $entry = ContentEntry::query()
            ->where('content_key', HomeBannerContentDefinition::KEY)
            ->first();

        if ($entry === null) {
            $entry = $this->content->saveDraft(
                contentKey: HomeBannerContentDefinition::KEY,
                contentType: HomeBannerContentDefinition::TYPE,
                payload: HomeBannerContentDefinition::defaultPayload(),
                expectedRevision: 0,
                actorFingerprint: $this->actorFingerprint($request),
            );
        }

        abort_unless(
            $entry->content_type === HomeBannerContentDefinition::TYPE,
            409,
            'The reserved home.banner content key has an incompatible content type.',
        );

        $entry->load(['revisions' => fn ($query) => $query->orderByDesc('revision')]);
        $draft = HomeBannerContentDefinition::editableFields($entry->draft_payload);
        $published = $entry->published_payload === null
            ? null
            : HomeBannerContentDefinition::editableFields($entry->published_payload);

        return view('admin.content.home-banner', [
            'entry' => $entry,
            'draft' => $draft,
            'published' => $published,
            'draftStartsAtInput' => $this->dateTimeInput($draft['starts_at']),
            'draftEndsAtInput' => $this->dateTimeInput($draft['ends_at']),
            'draftActiveNow' => HomeBannerContentDefinition::isActiveAt($draft),
            'publishedActiveNow' => $published === null
                ? false
                : HomeBannerContentDefinition::isActiveAt($published),
            'actions' => HomeBannerContentDefinition::allowedActions(),
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'enabled' => ['required', 'boolean'],
            'eyebrow' => ['required', 'string', 'max:80'],
            'title' => ['required', 'string', 'max:140'],
            'body' => ['required', 'string', 'max:320'],
            'cta_label' => ['nullable', 'string', 'max:48'],
            'cta_action' => ['required', 'string', 'in:'.implode(',', HomeBannerContentDefinition::allowedActions())],
            'starts_at' => ['nullable', 'date_format:Y-m-d\\TH:i'],
            'ends_at' => ['nullable', 'date_format:Y-m-d\\TH:i'],
        ]);

        $payload = HomeBannerContentDefinition::validateAndNormalize([
            'enabled' => (bool) $validated['enabled'],
            'eyebrow' => $validated['eyebrow'],
            'title' => $validated['title'],
            'body' => $validated['body'],
            'cta_label' => $validated['cta_label'] ?? null,
            'cta_action' => $validated['cta_action'],
            'starts_at' => $this->inputToUtc($validated['starts_at'] ?? null),
            'ends_at' => $this->inputToUtc($validated['ends_at'] ?? null),
        ]);

        try {
            $this->content->saveDraft(
                contentKey: HomeBannerContentDefinition::KEY,
                contentType: HomeBannerContentDefinition::TYPE,
                payload: $payload,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.home.banner.edit')
                ->withErrors([
                    'revision' => 'Home Banner changed in another session. Review the current draft before saving again.',
                ]);
        }

        return redirect()
            ->route('admin.content.home.banner.edit')
            ->with('status', 'Home Banner draft saved. The live app has not changed until Publish is used.');
    }

    public function publish(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
        ]);
        $entry = $this->entry();
        HomeBannerContentDefinition::validateAndNormalize($entry->draft_payload);

        try {
            $this->content->publish(
                contentKey: HomeBannerContentDefinition::KEY,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.home.banner.edit')
                ->withErrors([
                    'revision' => 'Publish blocked because Home Banner changed in another session.',
                ]);
        }

        return redirect()
            ->route('admin.content.home.banner.edit')
            ->with('status', 'Home Banner published. Compatible clients will evaluate its enabled state and UTC schedule automatically.');
    }

    public function restore(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'source_revision' => ['required', 'integer', 'min:1'],
        ]);

        try {
            $this->content->restoreDraftFromRevision(
                contentKey: HomeBannerContentDefinition::KEY,
                revisionToRestore: (int) $validated['source_revision'],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.home.banner.edit')
                ->withErrors([
                    'revision' => 'Restore blocked because Home Banner changed in another session.',
                ]);
        }

        return redirect()
            ->route('admin.content.home.banner.edit')
            ->with('status', 'Historical Home Banner restored into a private draft. Review it before publishing.');
    }

    private function entry(): ContentEntry
    {
        $entry = ContentEntry::query()
            ->where('content_key', HomeBannerContentDefinition::KEY)
            ->firstOrFail();

        if ($entry->content_type !== HomeBannerContentDefinition::TYPE) {
            throw ValidationException::withMessages([
                'content_type' => ['The reserved home.banner key has an incompatible content type.'],
            ]);
        }

        return $entry;
    }

    private function dateTimeInput(?string $timestamp): string
    {
        if ($timestamp === null) {
            return '';
        }

        return CarbonImmutable::parse($timestamp)->utc()->format('Y-m-d\\TH:i');
    }

    private function inputToUtc(?string $timestamp): ?string
    {
        if ($timestamp === null || $timestamp === '') {
            return null;
        }

        return CarbonImmutable::createFromFormat('Y-m-d\\TH:i', $timestamp, 'UTC')
            ->utc()
            ->format('Y-m-d\\TH:i:s\\Z');
    }

    private function actorFingerprint(Request $request): string
    {
        $fingerprint = (string) $request->session()->get('walka_admin_dashboard_actor', '');

        return $fingerprint !== ''
            ? $fingerprint
            : hash('sha256', 'dashboard|'.$request->session()->getId());
    }
}
