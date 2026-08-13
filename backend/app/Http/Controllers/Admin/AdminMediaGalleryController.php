<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Services\ProductMediaGalleryService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

final class AdminMediaGalleryController extends Controller
{
    public function __construct(private readonly ProductMediaGalleryService $galleries) {}

    public function index(): View
    {
        $products = Product::query()
            ->with([
                'variants',
                'mediaGalleryItems.mediaAsset.canonicalDerivative',
                'variants.mediaGalleryItems.mediaAsset.canonicalDerivative',
            ])
            ->orderBy('sort_order')
            ->get();

        $productFingerprints = [];
        $variantFingerprints = [];
        foreach ($products as $product) {
            $productFingerprints[$product->id] = ProductMediaGalleryService::fingerprint(
                $product->mediaGalleryItems->pluck('media_asset_id')->all(),
            );
            foreach ($product->variants as $variant) {
                $variantFingerprints[$variant->id] = ProductMediaGalleryService::fingerprint(
                    $variant->mediaGalleryItems->pluck('media_asset_id')->all(),
                );
            }
        }

        return view('admin.media.galleries', [
            'products' => $products,
            'eligibleAssets' => $this->galleries->eligibleAssets(),
            'productFingerprints' => $productFingerprints,
            'variantFingerprints' => $variantFingerprints,
            'maxItems' => ProductMediaGalleryService::MAX_ITEMS,
        ]);
    }

    public function updateProduct(Request $request, string $product): RedirectResponse
    {
        $validated = $request->validate([
            'expected_fingerprint' => ['required', 'string', 'regex:/^[a-f0-9]{64}$/i'],
            'media_ids' => ['sometimes', 'array', 'max:'.ProductMediaGalleryService::MAX_ITEMS],
            'media_ids.*' => ['nullable', 'string', 'max:64'],
        ]);

        $this->galleries->replaceProductGallery(
            productId: $product,
            mediaAssetIds: $this->selectedMediaIds($validated['media_ids'] ?? []),
            expectedFingerprint: $validated['expected_fingerprint'],
            actorFingerprint: $this->actorFingerprint($request),
        );

        return redirect()
            ->route('admin.media.galleries.index')
            ->with('status', 'Product gallery saved. Only admitted product media is eligible.');
    }

    public function updateVariant(Request $request, string $variant): RedirectResponse
    {
        $validated = $request->validate([
            'expected_fingerprint' => ['required', 'string', 'regex:/^[a-f0-9]{64}$/i'],
            'media_ids' => ['sometimes', 'array', 'max:'.ProductMediaGalleryService::MAX_ITEMS],
            'media_ids.*' => ['nullable', 'string', 'max:64'],
        ]);

        $this->galleries->replaceVariantGallery(
            variantId: $variant,
            mediaAssetIds: $this->selectedMediaIds($validated['media_ids'] ?? []),
            expectedFingerprint: $validated['expected_fingerprint'],
            actorFingerprint: $this->actorFingerprint($request),
        );

        return redirect()
            ->route('admin.media.galleries.index')
            ->with('status', 'Variant gallery saved. Empty variant galleries inherit product gallery metadata.');
    }

    /**
     * @param  array<int, mixed>  $ids
     * @return list<string>
     */
    private function selectedMediaIds(array $ids): array
    {
        return collect($ids)
            ->filter(fn (mixed $id): bool => is_string($id) && trim($id) !== '')
            ->map(fn (string $id): string => trim($id))
            ->values()
            ->all();
    }

    private function actorFingerprint(Request $request): string
    {
        $fingerprint = (string) $request->session()->get('walka_admin_dashboard_actor', '');

        return $fingerprint !== ''
            ? $fingerprint
            : hash('sha256', 'dashboard|'.$request->session()->getId());
    }
}
