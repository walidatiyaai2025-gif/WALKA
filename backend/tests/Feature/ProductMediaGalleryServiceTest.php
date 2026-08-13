<?php

namespace Tests\Feature;

use App\Enums\MediaAssetLifecycle;
use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use App\Models\MediaAsset;
use App\Models\ProductMediaGalleryItem;
use App\Models\VariantMediaGalleryItem;
use App\Services\MediaLibraryService;
use App\Services\ProductMediaGalleryService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class ProductMediaGalleryServiceTest extends TestCase
{
    use RefreshDatabase;

    private int $assetCounter = 0;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        $this->actor = hash('sha256', 'cms-032-gallery-test');
    }

    public function test_product_gallery_is_atomically_ordered_and_reorderable(): void
    {
        $first = $this->admittedAsset('Drawer white front');
        $second = $this->admittedAsset('Drawer white detail');
        $service = app(ProductMediaGalleryService::class);

        $service->replaceProductGallery(
            'drawer-organizer',
            [$first->id, $second->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );

        $this->assertSame(
            [$first->id, $second->id],
            ProductMediaGalleryItem::query()
                ->where('product_id', 'drawer-organizer')
                ->orderBy('position')
                ->pluck('media_asset_id')
                ->all(),
        );
        $this->assertSame([1, 2], ProductMediaGalleryItem::query()
            ->where('product_id', 'drawer-organizer')
            ->orderBy('position')
            ->pluck('position')
            ->all());

        $service->replaceProductGallery(
            'drawer-organizer',
            [$second->id, $first->id],
            ProductMediaGalleryService::fingerprint([$first->id, $second->id]),
            $this->actor,
        );

        $this->assertSame(
            [$second->id, $first->id],
            ProductMediaGalleryItem::query()
                ->where('product_id', 'drawer-organizer')
                ->orderBy('position')
                ->pluck('media_asset_id')
                ->all(),
        );
    }

    public function test_variant_gallery_is_independent_and_can_be_cleared_to_product_fallback(): void
    {
        $asset = $this->admittedAsset('Blue lunch hero');
        $service = app(ProductMediaGalleryService::class);

        $service->replaceVariantGallery(
            'lunch-box:blue',
            [$asset->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );
        $this->assertSame(
            [$asset->id],
            VariantMediaGalleryItem::query()
                ->where('product_variant_id', 'lunch-box:blue')
                ->orderBy('position')
                ->pluck('media_asset_id')
                ->all(),
        );

        $service->replaceVariantGallery(
            'lunch-box:blue',
            [],
            ProductMediaGalleryService::fingerprint([$asset->id]),
            $this->actor,
        );
        $this->assertSame(0, VariantMediaGalleryItem::query()
            ->where('product_variant_id', 'lunch-box:blue')
            ->count());
    }

    public function test_only_admitted_product_media_with_canonical_derivative_is_assignable(): void
    {
        $service = app(ProductMediaGalleryService::class);
        $draft = $this->assetWithCanonical('Draft product source', MediaAssetPurpose::Product, false);
        $wrongPurpose = $this->admittedAsset('Home hero image', MediaAssetPurpose::Home);
        $missingCanonical = $this->rawSource('Missing canonical');
        $missingCanonical->forceFill([
            'lifecycle' => MediaAssetLifecycle::Admitted,
            'admitted_at' => now(),
        ])->save();
        $archived = $this->admittedAsset('Archived product source');
        app(MediaLibraryService::class)->archive($archived, $this->actor);

        foreach ([$draft, $wrongPurpose, $missingCanonical, $archived] as $asset) {
            try {
                $service->replaceProductGallery(
                    'drawer-organizer',
                    [$asset->id],
                    ProductMediaGalleryService::fingerprint([]),
                    $this->actor,
                );
                $this->fail('Invalid media should not be assignable.');
            } catch (ValidationException) {
                $this->assertSame(0, ProductMediaGalleryItem::query()->count());
            }
        }
    }

    public function test_duplicate_and_oversized_gallery_lists_are_rejected_before_mutation(): void
    {
        $service = app(ProductMediaGalleryService::class);
        $asset = $this->admittedAsset('Duplicate source');

        try {
            $service->replaceProductGallery(
                'drawer-organizer',
                [$asset->id, $asset->id],
                ProductMediaGalleryService::fingerprint([]),
                $this->actor,
            );
            $this->fail('Duplicate gallery media should fail.');
        } catch (ValidationException) {
            $this->assertSame(0, ProductMediaGalleryItem::query()->count());
        }

        $ids = [];
        for ($index = 0; $index < ProductMediaGalleryService::MAX_ITEMS + 1; $index++) {
            $ids[] = $this->admittedAsset('Oversized '.$index)->id;
        }

        try {
            $service->replaceProductGallery(
                'drawer-organizer',
                $ids,
                ProductMediaGalleryService::fingerprint([]),
                $this->actor,
            );
            $this->fail('Oversized gallery should fail.');
        } catch (ValidationException) {
            $this->assertSame(0, ProductMediaGalleryItem::query()->count());
        }
    }

    public function test_stale_fingerprint_and_unknown_identity_fail_without_replacing_current_gallery(): void
    {
        $service = app(ProductMediaGalleryService::class);
        $first = $this->admittedAsset('Current product image');
        $second = $this->admittedAsset('Replacement product image');
        $emptyFingerprint = ProductMediaGalleryService::fingerprint([]);

        $service->replaceProductGallery(
            'drawer-organizer',
            [$first->id],
            $emptyFingerprint,
            $this->actor,
        );

        try {
            $service->replaceProductGallery(
                'drawer-organizer',
                [$second->id],
                $emptyFingerprint,
                $this->actor,
            );
            $this->fail('Stale gallery write should fail.');
        } catch (ValidationException) {
            $this->assertSame(
                [$first->id],
                ProductMediaGalleryItem::query()->orderBy('position')->pluck('media_asset_id')->all(),
            );
        }

        foreach (
            [
                fn () => $service->replaceProductGallery(
                    'missing-product',
                    [$second->id],
                    $emptyFingerprint,
                    $this->actor,
                ),
                fn () => $service->replaceVariantGallery(
                    'missing-variant',
                    [$second->id],
                    $emptyFingerprint,
                    $this->actor,
                ),
                fn () => $service->replaceVariantGallery(
                    'lunch-box:green',
                    ['01H00000000000000000000000'],
                    $emptyFingerprint,
                    $this->actor,
                ),
            ] as $operation
        ) {
            try {
                $operation();
                $this->fail('Unknown identity should fail closed.');
            } catch (ValidationException) {
                $this->assertSame(0, VariantMediaGalleryItem::query()->count());
            }
        }
    }

    private function admittedAsset(
        string $label,
        MediaAssetPurpose $purpose = MediaAssetPurpose::Product,
    ): MediaAsset {
        return $this->assetWithCanonical($label, $purpose, true);
    }

    private function assetWithCanonical(
        string $label,
        MediaAssetPurpose $purpose,
        bool $admit,
    ): MediaAsset {
        $asset = $this->rawSource($label, $purpose);
        $counter = $this->assetCounter;
        app(MediaLibraryService::class)->attachDerivative(
            $asset,
            [
                'kind' => MediaDerivativeKind::Canonical,
                'storage_disk' => 'media-test',
                'storage_path' => "canonical/$counter.png",
                'mime' => 'image/png',
                'bytes' => 2000 + $counter,
                'width' => 1200,
                'height' => 1200,
                'sha256' => hash('sha256', "derivative-$counter"),
            ],
            $this->actor,
        );

        if ($admit) {
            return app(MediaLibraryService::class)->admit($asset, $this->actor);
        }

        return $asset->refresh();
    }

    private function rawSource(
        string $label,
        MediaAssetPurpose $purpose = MediaAssetPurpose::Product,
    ): MediaAsset {
        $this->assetCounter++;
        $counter = $this->assetCounter;

        return app(MediaLibraryService::class)->registerSource([
            'purpose' => $purpose,
            'source_reference' => "cms-032-test-$counter",
            'original_filename' => "source-$counter.png",
            'original_mime' => 'image/png',
            'original_bytes' => 3000 + $counter,
            'original_width' => 1600,
            'original_height' => 1600,
            'original_sha256' => hash('sha256', "source-$counter"),
            'semantic_label' => $label,
        ], $this->actor);
    }
}
