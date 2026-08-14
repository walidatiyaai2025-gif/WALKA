<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\ContentRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use App\Services\Content\AppConfigContentDefinition;
use App\Services\Content\MaintenanceNoticeContentDefinition;
use App\Services\ContentRevisionService;
use Carbon\CarbonImmutable;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

final class AdminOperationalSettingsController extends Controller
{
    public function __construct(private readonly ContentRevisionService $content) {}

    public function noticeEdit(Request $request): View
    {
        $entry = $this->ensureEntry(
            $request,
            MaintenanceNoticeContentDefinition::KEY,
            MaintenanceNoticeContentDefinition::TYPE,
            MaintenanceNoticeContentDefinition::defaultPayload(),
        );
        $entry->load(['revisions' => fn ($query) => $query->orderByDesc('revision')]);

        return view('admin.content.maintenance-notice', [
            'entry' => $entry,
            'draft' => MaintenanceNoticeContentDefinition::validateAndNormalize($entry->draft_payload),
            'published' => $entry->published_payload === null
                ? null
                : MaintenanceNoticeContentDefinition::validateAndNormalize($entry->published_payload),
        ]);
    }

    public function noticeUpdate(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'severity' => ['required', 'in:info,warning,maintenance'],
            'title' => ['required', 'string', 'max:140'],
            'body' => ['required', 'string', 'max:700'],
            'starts_at' => ['nullable', 'date'],
            'ends_at' => ['nullable', 'date'],
        ]);

        $payload = MaintenanceNoticeContentDefinition::validateAndNormalize([
            'enabled' => $request->boolean('enabled'),
            'severity' => $validated['severity'],
            'title' => $validated['title'],
            'body' => $validated['body'],
            'starts_at' => $this->utcInput($validated['starts_at'] ?? null),
            'ends_at' => $this->utcInput($validated['ends_at'] ?? null),
        ]);

        return $this->saveTyped(
            request: $request,
            key: MaintenanceNoticeContentDefinition::KEY,
            type: MaintenanceNoticeContentDefinition::TYPE,
            payload: $payload,
            expectedRevision: (int) $validated['revision'],
            route: 'admin.content.maintenance.edit',
            status: 'Maintenance notice draft saved. Nothing is public until Publish is used.',
        );
    }

    public function noticePublish(Request $request): RedirectResponse
    {
        return $this->publishTyped(
            request: $request,
            key: MaintenanceNoticeContentDefinition::KEY,
            type: MaintenanceNoticeContentDefinition::TYPE,
            route: 'admin.content.maintenance.edit',
            validate: MaintenanceNoticeContentDefinition::validateAndNormalize(...),
        );
    }

    public function noticeRestore(Request $request): RedirectResponse
    {
        return $this->restoreTyped($request, MaintenanceNoticeContentDefinition::KEY, 'admin.content.maintenance.edit');
    }

    public function appConfigEdit(Request $request): View
    {
        $entry = $this->ensureEntry(
            $request,
            AppConfigContentDefinition::KEY,
            AppConfigContentDefinition::TYPE,
            AppConfigContentDefinition::defaultPayload(),
        );
        $entry->load(['revisions' => fn ($query) => $query->orderByDesc('revision')]);

        return view('admin.app-config', [
            'entry' => $entry,
            'draft' => AppConfigContentDefinition::validateAndNormalize($entry->draft_payload),
            'published' => $entry->published_payload === null
                ? null
                : AppConfigContentDefinition::validateAndNormalize($entry->published_payload),
            'flagIds' => AppConfigContentDefinition::flagIds(),
        ]);
    }

    public function appConfigUpdate(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
        ]);

        $flags = [];
        foreach (AppConfigContentDefinition::flagIds() as $id) {
            $flags[$id] = $request->boolean('flags.'.$id);
        }
        $payload = AppConfigContentDefinition::validateAndNormalize(['flags' => $flags]);

        return $this->saveTyped(
            request: $request,
            key: AppConfigContentDefinition::KEY,
            type: AppConfigContentDefinition::TYPE,
            payload: $payload,
            expectedRevision: (int) $validated['revision'],
            route: 'admin.app-config.edit',
            status: 'App Config draft saved. Security, commerce and executable behavior remain compiled.',
        );
    }

    public function appConfigPublish(Request $request): RedirectResponse
    {
        return $this->publishTyped(
            request: $request,
            key: AppConfigContentDefinition::KEY,
            type: AppConfigContentDefinition::TYPE,
            route: 'admin.app-config.edit',
            validate: AppConfigContentDefinition::validateAndNormalize(...),
        );
    }

    public function appConfigRestore(Request $request): RedirectResponse
    {
        return $this->restoreTyped($request, AppConfigContentDefinition::KEY, 'admin.app-config.edit');
    }

    /** @param array<string, mixed> $defaults */
    private function ensureEntry(Request $request, string $key, string $type, array $defaults): ContentEntry
    {
        $entry = ContentEntry::query()->where('content_key', $key)->first();
        if ($entry === null) {
            return $this->content->saveDraft(
                contentKey: $key,
                contentType: $type,
                payload: $defaults,
                expectedRevision: 0,
                actorFingerprint: $this->actorFingerprint($request),
            );
        }

        abort_unless($entry->content_type === $type, 409, 'Reserved operational content key has an incompatible type.');

        return $entry;
    }

    /** @param array<string, mixed> $payload */
    private function saveTyped(
        Request $request,
        string $key,
        string $type,
        array $payload,
        int $expectedRevision,
        string $route,
        string $status,
    ): RedirectResponse {
        try {
            $this->content->saveDraft(
                contentKey: $key,
                contentType: $type,
                payload: $payload,
                expectedRevision: $expectedRevision,
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()->route($route)->withErrors([
                'revision' => 'This operational content changed in another session. Review the current draft before saving again.',
            ]);
        }

        return redirect()->route($route)->with('status', $status);
    }

    /** @param callable(array<string, mixed>): array<string, mixed> $validate */
    private function publishTyped(
        Request $request,
        string $key,
        string $type,
        string $route,
        callable $validate,
    ): RedirectResponse {
        $validated = $request->validate(['revision' => ['required', 'integer', 'min:1']]);
        $entry = ContentEntry::query()->where('content_key', $key)->firstOrFail();
        if ($entry->content_type !== $type) {
            throw ValidationException::withMessages(['content_type' => ['Reserved operational content type mismatch.']]);
        }
        $validate($entry->draft_payload);

        try {
            $this->content->publish(
                contentKey: $key,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()->route($route)->withErrors([
                'revision' => 'Publish blocked because the draft changed in another session.',
            ]);
        }

        return redirect()->route($route)->with('status', 'Published as an immutable validated snapshot.');
    }

    private function restoreTyped(Request $request, string $key, string $route): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'source_revision' => ['required', 'integer', 'min:1'],
        ]);

        try {
            $this->content->restoreDraftFromRevision(
                contentKey: $key,
                revisionToRestore: (int) $validated['source_revision'],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()->route($route)->withErrors([
                'revision' => 'Restore blocked because the content changed in another session.',
            ]);
        }

        return redirect()->route($route)->with('status', 'Historical snapshot restored into a new private draft.');
    }

    private function utcInput(mixed $value): ?string
    {
        if ($value === null || trim((string) $value) === '') {
            return null;
        }

        return CarbonImmutable::parse((string) $value, 'UTC')->utc()->toIso8601ZuluString();
    }

    private function actorFingerprint(Request $request): string
    {
        $fingerprint = (string) $request->session()->get('walka_admin_dashboard_actor', '');

        return $fingerprint !== ''
            ? $fingerprint
            : hash('sha256', 'dashboard|'.$request->session()->getId());
    }
}
