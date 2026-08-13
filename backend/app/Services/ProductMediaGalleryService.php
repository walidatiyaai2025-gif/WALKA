<?php

namespace App\Services;

use App\Enums\MediaAssetLifecycle;
use App\Enums\MediaAssetPurpose;
use App\Models\MediaAsset;
use App\Models\Product;
use App\Models\ProductMediaGalleryItem;
use App\Models\ProductVariant;
use App\Models\VariantMediaGalleryItem;
use Illuminate\Database\Eloquent\Collection as EloquentCollection;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

final class ProductMediaGalleryService
{
    public const MAX_ITEMS = 8;

    /**
     * @param  list<string>  $mediaAssetIds
     */
    public function replaceProductGallery(
        string $productId,
        array $mediaAssetIds,
        string $expectedFingerprint,
        string $actorFingerprint,
    ): void {
        $this->assertActorFingerprint($actorFingerprint);
        $this->assertGalleryFingerprint($expectedFingerprint);
        $mediaAssetIds = $this->normalizeMediaIds($mediaAssetIds);

        DB::transaction(function () use (
            $actorFingerprint,
            $expectedFingerprint,
            $mediaAssetIds,
            $productId,
        ): void {
            $product = Product::query()->lockForUpdate()->find($productId);
            if ($product === null) {
                throw ValidationException::withMessages([
                    'product_id' => ['The requested WALKA product does not exist.'],
                ]);
            }

            $currentIds = ProductMediaGalleryItem::query()
                ->where('product_id', $product->id)
                ->orderBy('position')
                ->lockForUpdate()
                ->pluck('media_asset_id')
                ->all();
            if (! hash_equals($expectedFingerprint, self::fingerprint($currentIds))) {
                throw ValidationException::withMessages([
                    'gallery' => ['This product gallery changed in another session. Reload before saving.'],
                ]);
            }

            $this->validatedAssignableAssets($mediaAssetIds);

            ProductMediaGalleryItem::query()->where('product_id', $product->id)->delete();
            foreach ($mediaAssetIds as $index => $mediaAssetId) {
                ProductMediaGalleryItem::query()->create([
                    'product_id' => $product->id,
                    'media_asset_id' => $mediaAssetId,
                    'position' => $index + 1,
                    'created_by_fingerprint' => strtolower($actorFingerprint),
                ]);
            }
        });
    }

    /**
     * @param  list<string>  $mediaAssetIds
     */
    public function replaceVariantGallery(
        string $variantId,
        array $mediaAssetIds,
        string $expectedFingerprint,
        string $actorFingerprint,
    ): void {
        $this->assertActorFingerprint($actorFingerprint);
        $this->assertGalleryFingerprint($expectedFingerprint);
        $mediaAssetIds = $this->normalizeMediaIds($mediaAssetIds);

        DB::transaction(function () use (
            $actorFingerprint,
            $expectedFingerprint,
            $mediaAssetIds,
            $variantId,
        ): void {
            $variant = ProductVariant::query()->lockForUpdate()->find($variantId);
            if ($variant === null) {
                throw ValidationException::withMessages([
                    'variant_id' => ['The requested WALKA product variant does not exist.'],
                ]);
            }

            $currentIds = VariantMediaGalleryItem::query()
                ->where('product_variant_id', $variant->id)
                ->orderBy('position')
                ->lockForUpdate()
                ->pluck('media_asset_id')
                ->all();
            if (! hash_equals($expectedFingerprint, self::fingerprint($currentIds))) {
                throw ValidationException::withMessages([
                    'gallery' => ['This variant gallery changed in another session. Reload before saving.'],
                ]);
            }

            $this->validatedAssignableAssets($mediaAssetIds);

            VariantMediaGalleryItem::query()->where('product_variant_id', $variant->id)->delete();
            foreach ($mediaAssetIds as $index => $mediaAssetId) {
                VariantMediaGalleryItem::query()->create([
                    'product_variant_id' => $variant->id,
                    'media_asset_id' => $mediaAssetId,
                    'position' => $index + 1,
                    'created_by_fingerprint' => strtolower($actorFingerprint),
                ]);
            }
        });
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function publicPayload(): array
    {
        $products = Product::query()
            ->with([
                'variants',
                'mediaGalleryItems.mediaAsset.canonicalDerivative',
                'variants.mediaGalleryItems.mediaAsset.canonicalDerivative',
            ])
            ->orderBy('sort_order')
            ->get();

        return $products->map(function (Product $product): array {
            $productGallery = $this->serializeGallery($product->mediaGalleryItems);

            return [
                'product_id' => $product->id,
                'gallery' => $productGallery,
                'variants' => $product->variants->map(function (ProductVariant $variant) use ($productGallery): array {
                    $explicit = $this->serializeGallery($variant->mediaGalleryItems);

                    return [
                        'variant_id' => $variant->id,
                        'gallery_source' => $explicit === [] ? 'product_fallback' : 'variant',
                        'gallery' => $explicit === [] ? $productGallery : $explicit,
                    ];
                })->values()->all(),
            ];
        })->values()->all();
    }

    /**
     * @return EloquentCollection<int, MediaAsset>
     */
    public function eligibleAssets(): EloquentCollection
    {
        return MediaAsset::query()
            ->with('canonicalDerivative')
            ->where('purpose', MediaAssetPurpose::Product->value)
            ->where('lifecycle', MediaAssetLifecycle::Admitted->value)
            ->whereHas('canonicalDerivative')
            ->orderBy('created_at')
            ->get();
    }

    /**
     * @param  list<string>  $ids
     */
    public static function fingerprint(array $ids): string
    {
        return hash('sha256', json_encode(array_values($ids), JSON_THROW_ON_ERROR));
    }

    /**
     * @param  array<int, mixed>  $ids
     * @return list<string>
     */
    private function normalizeMediaIds(array $ids): array
    {
        if (! array_is_list($ids)) {
            throw ValidationException::withMessages([
                'media_ids' => ['Gallery media IDs must be an ordered list.'],
            ]);
        }
        if (count($ids) > self::MAX_ITEMS) {
            throw ValidationException::withMessages([
                'media_ids' => [sprintf('A WALKA gallery may contain at most %d media items.', self::MAX_ITEMS)],
            ]);
        }

        $normalized = [];
        foreach ($ids as $index => $id) {
            if (! is_string($id) || trim($id) === '') {
                throw ValidationException::withMessages([
                    "media_ids.$index" => ['Gallery media ID must be a non-empty string.'],
                ]);
            }
            $normalized[] = trim($id);
        }
        if (count(array_unique($normalized)) !== count($normalized)) {
            throw ValidationException::withMessages([
                'media_ids' => ['A media asset may appear only once in the same gallery.'],
            ]);
        }

        return $normalized;
    }

    /**
     * @param  list<string>  $ids
     * @return EloquentCollection<int, MediaAsset>
     */
    private function validatedAssignableAssets(array $ids): EloquentCollection
    {
        if ($ids === []) {
            return new EloquentCollection;
        }

        $assets = MediaAsset::query()
            ->with('canonicalDerivative')
            ->whereIn('id', $ids)
            ->lockForUpdate()
            ->get()
            ->keyBy('id');

        foreach ($ids as $id) {
            $asset = $assets->get($id);
            if ($asset instanceof MediaAsset === false) {
                throw ValidationException::withMessages([
                    'media_ids' => ["Media asset $id does not exist."],
                ]);
            }
            $this->assertAssignable($asset);
        }

        return $assets->values();
    }

    private function assertAssignable(MediaAsset $asset): void
    {
        if ($asset->purpose !== MediaAssetPurpose::Product) {
            throw ValidationException::withMessages([
                'media_ids' => ["Media asset {$asset->id} is not approved for product galleries."],
            ]);
        }
        if ($asset->lifecycle !== MediaAssetLifecycle::Admitted) {
            throw ValidationException::withMessages([
                'media_ids' => ["Media asset {$asset->id} is not admitted."],
            ]);
        }
        if ($asset->canonicalDerivative === null) {
            throw ValidationException::withMessages([
                'media_ids' => ["Media asset {$asset->id} has no canonical derivative."],
            ]);
        }
    }

    /**
     * @param  iterable<ProductMediaGalleryItem|VariantMediaGalleryItem>  $items
     * @return list<array<string, mixed>>
     */
    private function serializeGallery(iterable $items): array
    {
        $result = [];
        foreach ($items as $item) {
            $asset = $item->mediaAsset;
            if ($asset instanceof MediaAsset === false) {
                throw ValidationException::withMessages([
                    'gallery' => ['Published gallery references a missing media asset.'],
                ]);
            }
            $this->assertAssignable($asset);
            $derivative = $asset->canonicalDerivative;

            $result[] = [
                'media_id' => $asset->id,
                'semantic_label' => $asset->semantic_label,
                'canonical' => [
                    'mime' => $derivative->mime,
                    'width' => $derivative->width,
                    'height' => $derivative->height,
                    'sha256' => $derivative->sha256,
                ],
            ];
        }

        return $result;
    }

    private function assertActorFingerprint(string $fingerprint): void
    {
        if (! preg_match('/^[a-f0-9]{64}$/i', $fingerprint)) {
            throw ValidationException::withMessages([
                'actor' => ['A valid actor fingerprint is required.'],
            ]);
        }
    }

    private function assertGalleryFingerprint(string $fingerprint): void
    {
        if (! preg_match('/^[a-f0-9]{64}$/i', $fingerprint)) {
            throw ValidationException::withMessages([
                'expected_fingerprint' => ['A valid gallery fingerprint is required.'],
            ]);
        }
    }
}
