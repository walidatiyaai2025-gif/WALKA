<?php

namespace App\Services;

use App\Enums\MediaAssetLifecycle;
use App\Enums\MediaAssetPurpose;
use App\Exceptions\MediaGalleryRevisionConflictException;
use App\Models\MediaAsset;
use App\Models\MediaGallery;
use App\Models\MediaGalleryItem;
use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Database\Eloquent\Collection as EloquentCollection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

final class MediaGalleryService
{
    public const MAX_ITEMS = 12;

    public const SCHEMA_VERSION = 1;

    /**
     * @return EloquentCollection<int, MediaAsset>
     */
    public function eligibleAssets(): EloquentCollection
    {
        return MediaAsset::query()
            ->where('purpose', MediaAssetPurpose::Product->value)
            ->where('lifecycle', MediaAssetLifecycle::Admitted->value)
            ->whereHas('canonicalDerivative')
            ->with('canonicalDerivative')
            ->orderBy('semantic_label')
            ->orderBy('id')
            ->get();
    }

    /**
     * @param  list<string|null>  $mediaAssetIds
     */
    public function replaceProductGallery(
        Product $product,
        array $mediaAssetIds,
        int $expectedRevision,
        string $actorFingerprint,
    ): MediaGallery {
        return $this->replaceGallery(
            targetType: 'product',
            targetId: $product->id,
            mediaAssetIds: $mediaAssetIds,
            expectedRevision: $expectedRevision,
            actorFingerprint: $actorFingerprint,
        );
    }

    /**
     * @param  list<string|null>  $mediaAssetIds
     */
    public function replaceVariantGallery(
        ProductVariant $variant,
        array $mediaAssetIds,
        int $expectedRevision,
        string $actorFingerprint,
    ): MediaGallery {
        return $this->replaceGallery(
            targetType: 'variant',
            targetId: $variant->id,
            mediaAssetIds: $mediaAssetIds,
            expectedRevision: $expectedRevision,
            actorFingerprint: $actorFingerprint,
        );
    }

    public function productGallery(Product|string $product): ?MediaGallery
    {
        $productId = $product instanceof Product ? $product->id : $product;

        return MediaGallery::query()
            ->where('product_id', $productId)
            ->whereNull('product_variant_id')
            ->with('items.asset.canonicalDerivative')
            ->first();
    }

    public function variantGallery(ProductVariant|string $variant): ?MediaGallery
    {
        $variantId = $variant instanceof ProductVariant ? $variant->id : $variant;

        return MediaGallery::query()
            ->whereNull('product_id')
            ->where('product_variant_id', $variantId)
            ->with('items.asset.canonicalDerivative')
            ->first();
    }

    /**
     * Return a public-safe metadata snapshot. Storage disks/paths, source
     * filenames and provenance never cross this boundary.
     *
     * @return array{schema_version:int,revision_token:string,products:list<array<string,mixed>>}
     */
    public function publicSnapshot(): array
    {
        $products = Product::query()
            ->with(['variants' => fn ($query) => $query->orderBy('sort_order')])
            ->orderBy('sort_order')
            ->get();
        $galleries = MediaGallery::query()
            ->with('items.asset.canonicalDerivative')
            ->get();

        $productGalleries = [];
        $variantGalleries = [];

        foreach ($galleries as $gallery) {
            if ($gallery->isProductGallery()) {
                $productGalleries[$gallery->product_id] = $gallery;

                continue;
            }
            if ($gallery->isVariantGallery()) {
                $variantGalleries[$gallery->product_variant_id] = $gallery;

                continue;
            }

            throw ValidationException::withMessages([
                'media_gallery' => ['A media gallery has an invalid target relationship.'],
            ]);
        }

        $publicProducts = [];
        foreach ($products as $product) {
            $productGallery = $productGalleries[$product->id] ?? null;
            $resolvedProduct = $this->resolvePublicGallery(
                explicit: $productGallery,
                fallback: null,
                explicitSource: 'product',
            );

            $variants = [];
            foreach ($product->variants as $variant) {
                $variants[] = [
                    'variant_id' => $variant->id,
                    'gallery' => $this->resolvePublicGallery(
                        explicit: $variantGalleries[$variant->id] ?? null,
                        fallback: $productGallery,
                        explicitSource: 'variant',
                    ),
                ];
            }

            $publicProducts[] = [
                'product_id' => $product->id,
                'gallery' => $resolvedProduct,
                'variants' => $variants,
            ];
        }

        $revisionToken = hash(
            'sha256',
            json_encode($publicProducts, JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES),
        );

        return [
            'schema_version' => self::SCHEMA_VERSION,
            'revision_token' => $revisionToken,
            'products' => $publicProducts,
        ];
    }

    /**
     * @param  list<string|null>  $mediaAssetIds
     */
    private function replaceGallery(
        string $targetType,
        string $targetId,
        array $mediaAssetIds,
        int $expectedRevision,
        string $actorFingerprint,
    ): MediaGallery {
        $actor = $this->validateFingerprint($actorFingerprint);
        $normalizedIds = $this->validateMediaAssetIds($mediaAssetIds);

        Validator::make(
            [
                'target_type' => $targetType,
                'target_id' => $targetId,
                'expected_revision' => $expectedRevision,
            ],
            [
                'target_type' => ['required', 'in:product,variant'],
                'target_id' => ['required', 'string', 'max:255'],
                'expected_revision' => ['required', 'integer', 'min:0'],
            ],
        )->validate();

        if ($targetType === 'product' && ! Product::query()->whereKey($targetId)->exists()) {
            throw ValidationException::withMessages([
                'target_id' => ['The product gallery target does not exist.'],
            ]);
        }
        if ($targetType === 'variant' && ! ProductVariant::query()->whereKey($targetId)->exists()) {
            throw ValidationException::withMessages([
                'target_id' => ['The variant gallery target does not exist.'],
            ]);
        }

        return DB::transaction(function () use (
            $targetType,
            $targetId,
            $normalizedIds,
            $expectedRevision,
            $actor,
        ): MediaGallery {
            $query = MediaGallery::query()->lockForUpdate();
            if ($targetType === 'product') {
                $query->where('product_id', $targetId)->whereNull('product_variant_id');
            } else {
                $query->whereNull('product_id')->where('product_variant_id', $targetId);
            }

            $gallery = $query->first();
            $currentRevision = $gallery?->revision ?? 0;
            if ($currentRevision !== $expectedRevision) {
                throw new MediaGalleryRevisionConflictException(
                    $targetType,
                    $targetId,
                    $expectedRevision,
                    $currentRevision,
                );
            }

            if ($gallery === null) {
                $gallery = MediaGallery::query()->create([
                    'product_id' => $targetType === 'product' ? $targetId : null,
                    'product_variant_id' => $targetType === 'variant' ? $targetId : null,
                    'revision' => 0,
                    'created_by_fingerprint' => $actor,
                    'updated_by_fingerprint' => $actor,
                ]);
            }

            $gallery->items()->delete();
            foreach ($normalizedIds as $position => $mediaAssetId) {
                $gallery->items()->create([
                    'media_asset_id' => $mediaAssetId,
                    'position' => $position,
                    'created_by_fingerprint' => $actor,
                ]);
            }

            $gallery->forceFill([
                'revision' => $currentRevision + 1,
                'updated_by_fingerprint' => $actor,
            ])->save();

            return $gallery->refresh()->load('items.asset.canonicalDerivative');
        });
    }

    /**
     * @param  list<string|null>  $mediaAssetIds
     * @return list<string>
     */
    private function validateMediaAssetIds(array $mediaAssetIds): array
    {
        $ids = [];
        foreach ($mediaAssetIds as $value) {
            if ($value === null || (is_string($value) && trim($value) === '')) {
                continue;
            }
            if (! is_string($value)) {
                throw ValidationException::withMessages([
                    'media_ids' => ['Every gallery slot must contain a valid media asset ID or be blank.'],
                ]);
            }
            $ids[] = trim($value);
        }

        if (count($ids) > self::MAX_ITEMS) {
            throw ValidationException::withMessages([
                'media_ids' => ['A gallery may contain at most '.self::MAX_ITEMS.' assets.'],
            ]);
        }
        if (count($ids) !== count(array_unique($ids))) {
            throw ValidationException::withMessages([
                'media_ids' => ['The same media asset cannot appear twice in one gallery.'],
            ]);
        }
        if ($ids === []) {
            return [];
        }

        $eligibleIds = MediaAsset::query()
            ->whereIn('id', $ids)
            ->where('purpose', MediaAssetPurpose::Product->value)
            ->where('lifecycle', MediaAssetLifecycle::Admitted->value)
            ->whereHas('canonicalDerivative')
            ->pluck('id')
            ->all();

        $invalid = array_values(array_diff($ids, $eligibleIds));
        if ($invalid !== []) {
            throw ValidationException::withMessages([
                'media_ids' => [
                    'Only admitted product media with a canonical derivative may be assigned. Invalid IDs: '.implode(', ', $invalid),
                ],
            ]);
        }

        return $ids;
    }

    /**
     * @return array{source:string,revision:int,items:list<array<string,mixed>>}
     */
    private function resolvePublicGallery(
        ?MediaGallery $explicit,
        ?MediaGallery $fallback,
        string $explicitSource,
    ): array {
        if ($explicit !== null && $explicit->items->isNotEmpty()) {
            return [
                'source' => $explicitSource,
                'revision' => $explicit->revision,
                'items' => $this->publicItems($explicit),
            ];
        }

        if ($fallback !== null && $fallback->items->isNotEmpty()) {
            return [
                'source' => 'product_fallback',
                'revision' => $fallback->revision,
                'items' => $this->publicItems($fallback),
            ];
        }

        return [
            'source' => 'empty',
            'revision' => $explicit?->revision ?? 0,
            'items' => [],
        ];
    }

    /**
     * @return list<array<string,mixed>>
     */
    private function publicItems(MediaGallery $gallery): array
    {
        $items = [];
        foreach ($gallery->items as $item) {
            if (! $item instanceof MediaGalleryItem) {
                continue;
            }

            $asset = $item->asset;
            $canonical = $asset?->canonicalDerivative;
            if (
                $asset === null
                || $asset->purpose !== MediaAssetPurpose::Product
                || $asset->lifecycle !== MediaAssetLifecycle::Admitted
                || $canonical === null
            ) {
                throw ValidationException::withMessages([
                    'media_gallery' => [
                        'An assigned media asset is no longer eligible for public gallery delivery.',
                    ],
                ]);
            }

            $items[] = [
                'position' => $item->position,
                'media_asset_id' => $asset->id,
                'semantic_label' => $asset->semantic_label,
                'canonical' => [
                    'mime' => $canonical->mime,
                    'width' => $canonical->width,
                    'height' => $canonical->height,
                    'sha256' => $canonical->sha256,
                ],
            ];
        }

        return $items;
    }

    private function validateFingerprint(string $actorFingerprint): string
    {
        $validated = Validator::make(
            ['actor' => strtolower(trim($actorFingerprint))],
            ['actor' => ['required', 'string', 'regex:/^[a-f0-9]{64}$/']],
        )->validate();

        return $validated['actor'];
    }
}
