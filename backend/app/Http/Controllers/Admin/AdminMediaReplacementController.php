<?php

namespace App\Http\Controllers\Admin;

use App\Enums\MediaAssetLifecycle;
use App\Http\Controllers\Controller;
use App\Models\MediaAsset;
use App\Models\MediaReplacementEvent;
use App\Services\MediaReplacementService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

final class AdminMediaReplacementController extends Controller
{
    public function __construct(private readonly MediaReplacementService $replacements) {}

    public function index(): View
    {
        $eligibleAssets = MediaAsset::query()
            ->where('lifecycle', MediaAssetLifecycle::Admitted->value)
            ->whereHas('canonicalDerivative')
            ->with('canonicalDerivative')
            ->orderBy('purpose')
            ->orderBy('semantic_label')
            ->orderBy('id')
            ->get();

        $sources = $eligibleAssets
            ->map(function (MediaAsset $asset) use ($eligibleAssets): ?array {
                $assignments = $this->replacements->assignmentsFor($asset);
                if ($assignments === []) {
                    return null;
                }

                return [
                    'asset' => $asset,
                    'assignments' => $assignments,
                    'fingerprint' => MediaReplacementService::fingerprint($assignments),
                    'candidates' => $eligibleAssets
                        ->filter(fn (MediaAsset $candidate): bool => $candidate->purpose === $asset->purpose)
                        ->values(),
                ];
            })
            ->filter()
            ->values();

        return view('admin.media.replacements', [
            'sources' => $sources,
            'events' => MediaReplacementEvent::query()
                ->with(['sourceAsset', 'replacementAsset', 'rollbackEvent'])
                ->latest('created_at')
                ->limit(100)
                ->get(),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'source_media_asset_id' => ['required', 'string', 'exists:media_assets,id'],
            'replacement_media_asset_id' => ['required', 'string', 'exists:media_assets,id'],
            'expected_fingerprint' => ['required', 'string', 'size:64', 'regex:/^[a-f0-9]+$/i'],
            'reason' => ['nullable', 'string', 'min:3', 'max:500'],
        ]);

        $source = MediaAsset::query()->findOrFail($validated['source_media_asset_id']);
        $replacement = MediaAsset::query()->findOrFail($validated['replacement_media_asset_id']);
        $event = $this->replacements->replace(
            source: $source,
            replacement: $replacement,
            expectedFingerprint: strtolower($validated['expected_fingerprint']),
            actorFingerprint: $this->actorFingerprint($request),
            reason: $validated['reason'] ?? null,
        );

        if ($event === null) {
            return redirect()
                ->route('admin.media.replacements.index')
                ->with('status', 'Selected media is already current. No assignment or audit event was changed.');
        }

        return redirect()
            ->route('admin.media.replacements.index')
            ->with('status', sprintf(
                'Media replacement recorded as %s across %d assignment(s).',
                $event->id,
                count($event->after_assignments ?? []),
            ));
    }

    public function rollback(
        Request $request,
        string $event,
    ): RedirectResponse {
        $validated = $request->validate([
            'expected_after_fingerprint' => ['required', 'string', 'size:64', 'regex:/^[a-f0-9]+$/i'],
            'reason' => ['required', 'string', 'min:3', 'max:500'],
        ]);
        $replacementEvent = MediaReplacementEvent::query()->findOrFail($event);

        $rollback = $this->replacements->rollback(
            replacementEvent: $replacementEvent,
            expectedAfterFingerprint: strtolower($validated['expected_after_fingerprint']),
            actorFingerprint: $this->actorFingerprint($request),
            reason: $validated['reason'],
        );

        return redirect()
            ->route('admin.media.replacements.index')
            ->with('status', sprintf(
                'Replacement %s rolled back by immutable event %s.',
                $replacementEvent->id,
                $rollback->id,
            ));
    }

    private function actorFingerprint(Request $request): string
    {
        $fingerprint = (string) $request->session()->get('walka_admin_dashboard_actor', '');

        return $fingerprint !== ''
            ? $fingerprint
            : hash('sha256', 'dashboard|'.$request->session()->getId());
    }
}
