<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\SurfaceMediaItem;
use App\Services\SurfaceMediaService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

final class AdminSurfaceMediaController extends Controller
{
    public function __construct(private readonly SurfaceMediaService $surfaceMedia) {}

    public function index(): View
    {
        $definitions = SurfaceMediaService::slotDefinitions();
        $itemsBySlot = SurfaceMediaItem::query()
            ->with('mediaAsset.canonicalDerivative')
            ->orderBy('position')
            ->get()
            ->groupBy('slot_key');
        $eligibleBySlot = [];
        foreach (array_keys($definitions) as $slotKey) {
            $eligibleBySlot[$slotKey] = $this->surfaceMedia->eligibleAssets($slotKey);
        }

        return view('admin.media.surfaces', [
            'definitions' => $definitions,
            'itemsBySlot' => $itemsBySlot,
            'eligibleBySlot' => $eligibleBySlot,
        ]);
    }

    public function update(Request $request, string $slot): RedirectResponse
    {
        $definition = $this->surfaceMedia->definition($slot);
        $validated = $request->validate([
            'expected_fingerprint' => ['required', 'string', 'size:64', 'regex:/^[a-f0-9]+$/i'],
            'media_ids' => ['nullable', 'array', 'max:'.$definition['max_items']],
            'media_ids.*' => ['nullable', 'string', 'max:64'],
        ]);

        $mediaIds = array_values(array_filter(
            $validated['media_ids'] ?? [],
            fn (mixed $id): bool => is_string($id) && trim($id) !== '',
        ));

        $this->surfaceMedia->replace(
            slotKey: $slot,
            mediaAssetIds: $mediaIds,
            expectedFingerprint: strtolower($validated['expected_fingerprint']),
            actorFingerprint: $this->actorFingerprint($request),
        );

        return redirect()
            ->route('admin.media.surfaces.index')
            ->with('status', "Media assignment saved for $slot.");
    }

    private function actorFingerprint(Request $request): string
    {
        $fingerprint = (string) $request->session()->get('walka_admin_dashboard_actor', '');

        return $fingerprint !== ''
            ? $fingerprint
            : hash('sha256', 'dashboard|'.$request->session()->getId());
    }
}
