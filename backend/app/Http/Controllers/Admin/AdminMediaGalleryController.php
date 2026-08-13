<?php

namespace App\Http\Controllers\Admin;

use App\Enums\MediaAssetLifecycle;
use App\Enums\MediaAssetPurpose;
use App\Http\Controllers\Controller;
use App\Models\MediaAsset;
use App\Models\MediaGallery;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Services\MediaGalleryService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

final class AdminMediaGalleryController extends Controller
{
    public function __construct(private readonly MediaGalleryService $galleries) {}

    public function index(): View
    {
        $products = Product::query()
            ->with('variants')
            ->orderBy('sort_order')
            ->get();

        $assets = MediaAsset::query()
            ->where('purpose', MediaAssetPurpose::Product->value)
            ->where('lifecycle', MediaAssetLifecycle::Admitted->value)
            ->whereHas('canonicalDerivative')
            ->with('canonicalDerivative')
            ->orderBy('semantic_label')
            ->get();

        $galleryRows = MediaGallery::query()
            ->with('items')
            ->get();

        return view('admin.media.galleries', [
            'products' => $products,
            'assets' => $assets,
            'productGalleries' => $galleryRows
                ->whereNotNull('product_id')
                ->whereNull('product_variant_id')
                ->keyBy('product_id'),
            'variantGalleries' => $galleryRows
                ->whereNotNull('product_variant_id')
                ->keyBy('product_variant_id'),
            'maxItems' => MediaGalleryService::MAX_ITEMS,
        ]);
    }

    public function updateProduct(Request $request, Product $product): RedirectResponse
    {
        $validated = $this->validateRequest($request);
        $gallery = $this->galleries->replaceProductGallery(
            product: $product,
            items: $this->items($validated['media_asset_ids'] ?? []),
            expectedRevision: (int) $validated['expected_revision'],
            actorFingerprint: $this->actorFingerprint($request),
        );

        return redirect()
            ->route('admin.media.galleries.index')
            ->with('status', sprintf(
                'Product gallery %s saved at revision %d.',
                $product->id,
                $gallery->revision,
            ));
    }

    public function updateVariant(Request $request, ProductVariant $variant): RedirectResponse
    {
        $validated = $this->validateRequest($request);
        $gallery = $this->galleries->replaceVariantGallery(
            variant: $variant,
            items: $this->items($validated['media_asset_ids'] ?? []),
            expectedRevision: (int) $validated['expected_revision'],
            actorFingerprint: $this->actorFingerprint($request),
        );

        return redirect()
            ->route('admin.media.galleries.index')
            ->with('status', sprintf(
                'Variant gallery %s saved at revision %d.',
                $variant->id,
                $gallery->revision,
            ));
    }

    /**
     * @return array<string, mixed>
     */
    private function validateRequest(Request $request): array
    {
        return $request->validate([
            'expected_revision' => ['required', 'integer', 'min:0'],
            'media_asset_ids' => ['nullable', 'array', 'max:'.MediaGalleryService::MAX_ITEMS],
            'media_asset_ids.*' => ['nullable', 'string', 'max:26'],
        ]);
    }

    /**
     * @param  array<int, string|null>  $assetIds
     * @return array<int, array{media_asset_id:string, position:int}>
     */
    private function items(array $assetIds): array
    {
        $ids = array_values(array_filter(
            array_map(fn (?string $id): string => trim((string) $id), $assetIds),
            fn (string $id): bool => $id !== '',
        ));

        return array_map(
            fn (string $id, int $position): array => [
                'media_asset_id' => $id,
                'position' => $position,
            ],
            $ids,
            array_keys($ids),
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
