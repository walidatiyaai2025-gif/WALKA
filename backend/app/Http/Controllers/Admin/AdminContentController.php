<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\ContentRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use App\Services\ContentRevisionService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;
use JsonException;

final class AdminContentController extends Controller
{
    public function __construct(private readonly ContentRevisionService $content) {}

    public function index(): View
    {
        return view('admin.content.index', [
            'entries' => ContentEntry::query()
                ->withCount('revisions')
                ->orderBy('content_type')
                ->orderBy('content_key')
                ->get(),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'content_key' => ['required', 'string', 'max:160', 'regex:/^[a-z0-9][a-z0-9._:-]*$/'],
            'content_type' => ['required', 'string', 'max:64', 'regex:/^[a-z][a-z0-9._-]*$/'],
            'payload_json' => ['required', 'string', 'max:70000'],
        ]);

        if (ContentEntry::query()->where('content_key', $validated['content_key'])->exists()) {
            throw ValidationException::withMessages([
                'content_key' => ['That content key already exists. Open the existing entry instead.'],
            ]);
        }

        $entry = $this->content->saveDraft(
            contentKey: (string) $validated['content_key'],
            contentType: (string) $validated['content_type'],
            payload: $this->decodePayload((string) $validated['payload_json']),
            expectedRevision: 0,
            actorFingerprint: $this->actorFingerprint($request),
        );

        return redirect()
            ->route('admin.content.show', ['content' => $entry->id])
            ->with('status', 'Draft created. Nothing is public until you explicitly publish it.');
    }

    public function show(ContentEntry $content): View
    {
        $content->load(['revisions' => fn ($query) => $query->orderByDesc('revision')]);

        return view('admin.content.show', [
            'entry' => $content,
            'draftJson' => $this->prettyJson($content->draft_payload),
            'publishedJson' => $content->published_payload === null
                ? null
                : $this->prettyJson($content->published_payload),
        ]);
    }

    public function updateDraft(Request $request, ContentEntry $content): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'payload_json' => ['required', 'string', 'max:70000'],
        ]);

        try {
            $this->content->saveDraft(
                contentKey: $content->content_key,
                contentType: $content->content_type,
                payload: $this->decodePayload((string) $validated['payload_json']),
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.show', ['content' => $content->id])
                ->withErrors(['revision' => 'This content changed in another session. Current values were reloaded; review before saving again.']);
        }

        return redirect()
            ->route('admin.content.show', ['content' => $content->id])
            ->with('status', 'Draft saved. Published mobile content has not changed.');
    }

    public function publish(Request $request, ContentEntry $content): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
        ]);

        try {
            $this->content->publish(
                contentKey: $content->content_key,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.show', ['content' => $content->id])
                ->withErrors(['revision' => 'Publish blocked because this content changed in another session. Review the current draft first.']);
        }

        return redirect()
            ->route('admin.content.show', ['content' => $content->id])
            ->with('status', 'Content published as an immutable revision snapshot.');
    }

    public function restore(Request $request, ContentEntry $content): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'source_revision' => ['required', 'integer', 'min:1'],
        ]);

        try {
            $this->content->restoreDraftFromRevision(
                contentKey: $content->content_key,
                revisionToRestore: (int) $validated['source_revision'],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.show', ['content' => $content->id])
                ->withErrors(['revision' => 'Restore blocked because this content changed in another session. Reload and review the latest revision.']);
        }

        return redirect()
            ->route('admin.content.show', ['content' => $content->id])
            ->with('status', 'Historical snapshot restored into a new draft. Review it before publishing.');
    }

    private function decodePayload(string $json): array
    {
        try {
            $decoded = json_decode($json, true, 64, JSON_THROW_ON_ERROR);
        } catch (JsonException $exception) {
            throw ValidationException::withMessages([
                'payload_json' => ['Invalid JSON: '.$exception->getMessage()],
            ]);
        }

        if (! is_array($decoded)) {
            throw ValidationException::withMessages([
                'payload_json' => ['Content payload must be a JSON object or array, not a scalar value.'],
            ]);
        }

        return $decoded;
    }

    private function prettyJson(array $payload): string
    {
        return json_encode(
            $payload,
            JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR,
        );
    }

    private function actorFingerprint(Request $request): string
    {
        $fingerprint = (string) $request->session()->get('walka_admin_dashboard_actor', '');

        return $fingerprint !== ''
            ? $fingerprint
            : hash('sha256', 'dashboard|'.$request->session()->getId());
    }
}
