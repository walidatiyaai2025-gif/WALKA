<?php

namespace App\Http\Controllers\Admin;

use App\Enums\MediaAssetPurpose;
use App\Http\Controllers\Controller;
use App\Models\MediaAsset;
use App\Services\MediaUploadService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

final class AdminMediaController extends Controller
{
    public function __construct(private readonly MediaUploadService $uploads) {}

    public function index(): View
    {
        return view('admin.media.index', [
            'assets' => MediaAsset::query()
                ->withCount('derivatives')
                ->latest()
                ->limit(100)
                ->get(),
            'purposes' => MediaAssetPurpose::cases(),
            'maxBytes' => MediaUploadService::MAX_BYTES,
            'minDimension' => MediaUploadService::MIN_DIMENSION,
            'maxDimension' => MediaUploadService::MAX_DIMENSION,
            'maxPixels' => MediaUploadService::MAX_PIXELS,
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'purpose' => ['required', Rule::enum(MediaAssetPurpose::class)],
            'source_reference' => ['required', 'string', 'max:255'],
            'semantic_label' => ['required', 'string', 'max:160'],
            'file' => [
                'required',
                'file',
                'max:'.intdiv(MediaUploadService::MAX_BYTES, 1024),
            ],
        ]);

        $asset = $this->uploads->upload(
            file: $request->file('file'),
            metadata: [
                'purpose' => $validated['purpose'],
                'source_reference' => $validated['source_reference'],
                'semantic_label' => $validated['semantic_label'],
            ],
            actorFingerprint: $this->actorFingerprint($request),
        );

        return redirect()
            ->route('admin.media.index')
            ->with(
                'status',
                sprintf(
                    'Media %s validated and quarantined as Draft. It is not admitted or public.',
                    $asset->id,
                ),
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
