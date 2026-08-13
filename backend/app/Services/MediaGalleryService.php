<?php

namespace App\Services;

use App\Enums\MediaAssetLifecycle;
use App\Enums\MediaAssetPurpose;
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
    public const MAX_ITEMS = 8;

    /**
     * @param  array<int, array{media_asset_id:string, position:int}>  $items
     */
    public function replaceProductGallery(
        Product $product,
        array $items,
        int $expectedRevision,
        string $actorFingerprint,
    ): MediaGallery {
        return $this->replace(
            product: $product,
            variant: null,
            items: $items,
            expectedRevision: $expectedRevision,
            actorFingerprint: $actorFingerprint,
        );
    }

    /**
     * @param  array<int, array{media_asset_id:string, position:int}>  $items
     */
    public function replaceVariantGallery(
        ProductVariant $variant,
        array $items,
        int $expectedRevision,
        string $actorFingerprint,
    ): MediaGallery {
        $variant->loadMissing('product');

        return $this->replace(
            product: null,
            variant: $variant,
            items: $items,
            expectedRevision: $expectedRevision,
            actorFingerprint: $actorFingerprint,
        );
    }

    /**
     * @return array<string, mixed>
     */
    public function publicProductGallery(Product $product): array
    {
        $gallery = MediaGallery::query()
            ->where('product_id', $product->id)
            ->whereNull('product_variant_id')
            ->with($this->publicRelations())
            ->first();

        return $this->publicPayload(
            product: $product,
            variant: null,
            gallery: $gallery,
            fallback: false,
        );
    }

    /**
     * @return array<string, mixed>
     */
    public function publicVariantGallery(ProductVariant $variant): array
    {
        $variant->loadMissing('product');

        $variantGallery = MediaGallery::query()
            ->where('product_variant_id', $variant->id)
            ->with($this->publicRelations())
            ->first();

        if ($variantGallery !== null && $variantGallery->items->isNotEmpty()) {
            return $this->publicPayload(
                product: $variant->product,
                variant: $variant,
                gallery: $variantGallery,
                fallback: false,
            );
        }

        $productGallery = MediaGallery::query()
            ->where('product_id', $variant->product_id)
            ->whereNull('product_variant_id')
            ->with($this->publicRelations())
            ->first();

        return $this->publicPayload(
            product: $variant->product,
            variant: $variant,
            gallery: $productGallery,
            fallback: $productGallery !== null,
        );
    }

    /**
     * @param  array<int, array{media_asset_id:string, position:int}>  $items
     */
    private function replace(
        ?Product $product,
        ?ProductVariant $variant,
        array $items,
        int $expectedRevision,
        string $actorFingerprint,
    ): MediaGallery {
        if (($product === null) === ($variant === null)) {
            throw ValidationException::withMessages([
                'target' => ['Exactly one gallery target is required.'],
            ]);
        }

        $actor = $this->validateFingerprint($actorFingerprint);
        $validatedItems = $this->validateItems($items);
        $assetIds = array_column($validatedItems, 'media_asset_id');
        $assets = $this->eligibleAssets($assetIds);

        return DB::transaction(function () use (
            $product,
            $variant,
            $validatedItems,
            $assets,
            $expectedRevision,
            $actor,
        ): MediaGallery {
            $query = MediaGallery::query()->lockForUpdate();
            if ($product !== null) {
                $query->where('product_id', $product->id)->whereNull('product_variant_id');
            } else {
                $query->where('product_variant_id', $variant->id);
            }

            $gallery = $query->first();
            $currentRevision = $gallery?->revision ?? 0;
            if ($expectedRevision !== $currentRevision) {
                throw ValidationException::withMessages([
                    'revision' => [sprintf(
                        'Gallery changed from revision %d to %d. Reload before saving.',
                        $expectedRevision,
                        $currentRevision,
                    )],
                ]);
            }

            if ($gallery === null) {
                $gallery = MediaGallery::query()->create([
                    'product_id' => $product?->id,
                    'product_variant_id' => $variant?->id,
                    'revision' => 0,
                    'created_by_fingerprint' => $actor,
                    'updated_by_fingerprint' => $actor,
                ]);
            }

            $gallery->items()->delete();
            foreach ($validatedItems as $item) {
                $asset = $assets->get($item['media_asset_id']);
                if (! $asset instanceof MediaAsset) {
                    throw ValidationException::withMessages([
                        'items' => ['One or more media assets are no longer eligible.'],
                    ]);
                }

                $gallery->items()->create([
                    'media_asset_id' => $asset->id,
                    'position' => $item['position'],
                ]);
            }

            $gallery->forceFill([
                'revision' => $currentRevision + 1,
                'updated_by_fingerprint' => $actor,
            ])->save();

            return $gallery->refresh()->load('items.mediaAsset.canonicalDerivative');
        });
    }

    /**
     * @param  array<int, array{media_asset_id:string, position:int}>  $items
     * @return array<int, array{media_asset_id:string, position:int}>
     */
    private function validateItems(array $items): array
    {
        $validated = Validator::make(['items' => $items], [
            'items' => ['array', 'max:'.self::MAX_ITEMS],
            'items.*.media_asset_id' => ['required', 'string', 'max:26'],
            'items.*.position' => ['required', 'integer', 'min:0', 'max:'.(self::MAX_ITEMS - 1)],
        ])->validate()['items'] ?? [];

        $ids = array_column($validated, 'media_asset_id');
        if (count($ids) !== count(array_unique($ids))) {
            throw ValidationException::withMessages([
                'items' => ['A media asset cannot appear twice in the same gallery.'],
            ]);
        }

        $positions = array_column($validated, 'position');
        if (count($positions) !== count(array_unique($positions))) {
            throw ValidationException::withMessages([
                'items' => ['Gallery positions must be unique.'],
            ]);
        }

        sort($positions);
        if ($positions !== range(0, count($positions) - 1) && $positions !== []) {
            throw ValidationException::withMessages([
                'items' => ['Gallery positions must be contiguous from zero.'],
            ]);
        }

        usort($validated, fn (array $left, array $right): int => $left['position'] <=> $right['position']);

        return $validated;
    }

    /**
     * @param  array<int, string>  $assetIds
     * @return EloquentCollection<string, MediaAsset>
     */
    private function eligibleAssets(array $assetIds): EloquentCollection
    {
        if ($assetIds === []) {
            return new EloquentCollection();
        }

        $assets = MediaAsset::query()
            ->whereIn('id', $assetIds)
            ->with('canonicalDerivative')
            ->get()
            ->keyBy('id');

        if ($assets->count() !== count($assetIds)) {
            throw ValidationException::withMessages([
                'items' => ['One or more media assets do not exist.'],
            ]);
        }

        foreach ($assetIds as $assetId) {
            $asset = $assets->get($assetId);
            if (! $asset instanceof MediaAsset
                || $asset->purpose !== MediaAssetPurpose::Product
                || $asset->lifecycle !== MediaAssetLifecycle::Admitted
                || $asset->canonicalDerivative === null
            ) {
                throw ValidationException::withMessages([
                    'items' => [sprintf(
                        'Media %s must be admitted product media with a canonical derivative.',
                        $assetId,
                    )],
                ]);
            }
        }

        return $assets;
    }

    /**
     * @return array<int, string>
     */
    private function publicRelations(): array
    {
        return ['items.mediaAsset.canonicalDerivative'];
    }

    /**
     * @return array<string, mixed>
     */
    private function publicPayload(
        Product $product,
        ?ProductVariant $variant,
        ?MediaGallery $gallery,
        bool $fallback,
    ): array {
        $items = $gallery?->items ?? collect();

        $publicItems = $items
            ->filter(function (MediaGalleryItem $item): bool {
                $asset = $item->mediaAsset;

                return $asset instanceof MediaAsset
                    && $asset->purpose === MediaAssetPurpose::Product
                    && $asset->lifecycle === MediaAssetLifecycle::Admitted
                    && $asset->canonicalDerivative !== null;
            })
            ->map(function (MediaGalleryItem $item): array {
                $asset = $item->mediaAsset;
                $canonical = $asset->canonicalDerivative;

                return [
                    'media_id' => $asset->id,
                    'position' => $item->position,
                    'semantic_label' => $asset->semantic_label,
                    'canonical' => [
                        'mime' => $canonical->mime,
                        'bytes' => $canonical->bytes,
                        'width' => $canonical->width,
                        'height' => $canonical->height,
                        'sha256' => $canonical->sha256,
                    ],
                ];
            })
            ->values()
            ->all();

        return [
            'schema' => 1,
            'product_id' => $product->id,
            'variant_id' => $variant?->id,
            'source' => $fallback ? 'product_fallback' : ($variant === null ? 'product' : 'variant'),
            'revision' => $gallery?->revision ?? 0,
            'items' => $publicItems,
        ];
    }

    private function validateFingerprint(string $actorFingerprint): string
    {
        return Validator::make(
            ['actor' => strtolower(trim($actorFingerprint))],
            ['actor' => ['required', 'string', 'regex:/^[a-f0-9]{64}$/']],
        )->validate()['actor'];
    }
}
