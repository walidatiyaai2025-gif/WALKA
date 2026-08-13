<?php

namespace Tests\Feature;

use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use App\Exceptions\MediaGalleryRevisionConflictException;
use App\Models\MediaAsset;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Services\MediaGalleryService;
use App\Services\MediaLibraryService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class MediaGalleryServiceTest extends TestCase
{
    use RefreshDatabase;

    private MediaGalleryService $galleries;

    private MediaLibraryService $media;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        $this->galleries = app(MediaGalleryService::class);
        $this->media = app(MediaLibraryService::class);
        $this->actor = hash('sha256', 'cms-032-gallery-service-test');
    }

    public function test_product_gallery_replace_preserves_order_and_increments_revision(): void
    {
        $first = $this->admittedAsset('a');
        $second = $this->admittedAsset('b');
        $product = Product::query()->findOrFail('drawer-organizer');

        $gallery = $this->galleries->replaceProductGallery(
            $product,
            [$second->id, $first->id],
            0,
            $this->actor,
        );

        $this->assertSame(1, $gallery->revision);
        $this->assertSame(
            [$second->id, $first->id],
            $gallery->items->pluck('media_asset_id')->values()->all(),
        );
        $this->assertSame([0, 1], $gallery->items->pluck('position')->values()->all());

        $reordered = $this->galleries->replaceProductGallery(
            $product,
            [$first->id, $second->id],
            1,
            $this->actor,
        );

        $this->assertSame(2, $reordered->revision);
        $this->assertSame(
            [$first->id, $second->id],
            $reordered->items->pluck('media_asset_id')->values()->all(),
        );
    }

    public function test_variant_gallery_is_separate_and_empty_explicit_gallery_uses_product_fallback(): void
    {
        $productAsset = $this->admittedAsset('c');
        $variantAsset = $this->admittedAsset('d');
        $product = Product::query()->findOrFail('stainless-steel-bento-lunch-box');
        $blue = ProductVariant::query()->findOrFail('lunch-box:blue');
        $green = ProductVariant::query()->findOrFail('lunch-box:green');

        $this->galleries->replaceProductGallery($product, [$productAsset->id], 0, $this->actor);
        $this->galleries->replaceVariantGallery($blue, [$variantAsset->id], 0, $this->actor);
        $this->galleries->replaceVariantGallery($green, [], 0, $this->actor);

        $snapshot = $this->galleries->publicSnapshot();
        $lunch = collect($snapshot['products'])->firstWhere('product_id', $product->id);
        $bluePublic = collect($lunch['variants'])->firstWhere('variant_id', $blue->id);
        $greenPublic = collect($lunch['variants'])->firstWhere('variant_id', $green->id);

        $this->assertSame('variant', $bluePublic['gallery']['source']);
        $this->assertSame($variantAsset->id, $bluePublic['gallery']['items'][0]['media_asset_id']);
        $this->assertSame('product_fallback', $greenPublic['gallery']['source']);
        $this->assertSame($productAsset->id, $greenPublic['gallery']['items'][0]['media_asset_id']);
    }

    public function test_stale_replace_is_rejected_and_leaves_current_gallery_unchanged(): void
    {
        $first = $this->admittedAsset('e');
        $second = $this->admittedAsset('f');
        $product = Product::query()->findOrFail('drawer-organizer');

        $this->galleries->replaceProductGallery($product, [$first->id], 0, $this->actor);

        try {
            $this->galleries->replaceProductGallery($product, [$second->id], 0, $this->actor);
            $this->fail('A stale revision must fail.');
        } catch (MediaGalleryRevisionConflictException) {
            $gallery = $this->galleries->productGallery($product);
            $this->assertSame(1, $gallery->revision);
            $this->assertSame($first->id, $gallery->items->first()->media_asset_id);
        }
    }

    public function test_ineligible_media_is_rejected_before_existing_gallery_mutates(): void
    {
        $valid = $this->admittedAsset('g');
        $draft = $this->draftAsset('h');
        $wrongPurpose = $this->admittedAsset('i', MediaAssetPurpose::Home);
        $missingCanonical = $this->draftAsset('j');
        $this->media->admit($missingCanonical, $this->actor);
        $product = Product::query()->findOrFail('drawer-organizer');

        $this->galleries->replaceProductGallery($product, [$valid->id], 0, $this->actor);

        foreach ([$draft, $wrongPurpose] as $invalid) {
            try {
                $this->galleries->replaceProductGallery($product, [$invalid->id], 1, $this->actor);
                $this->fail('Ineligible media must fail assignment.');
            } catch (ValidationException) {
                $gallery = $this->galleries->productGallery($product);
                $this->assertSame(1, $gallery->revision);
                $this->assertSame($valid->id, $gallery->items->first()->media_asset_id);
            }
        }
    }

    public function test_archived_assigned_asset_fails_closed_at_public_delivery(): void
    {
        $asset = $this->admittedAsset('k');
        $product = Product::query()->findOrFail('drawer-organizer');
        $this->galleries->replaceProductGallery($product, [$asset->id], 0, $this->actor);

        $this->media->archive($asset, $this->actor);

        $this->expectException(ValidationException::class);
        $this->galleries->publicSnapshot();
    }

    public function test_duplicate_and_oversized_gallery_requests_fail_without_mutation(): void
    {
        $baseline = $this->admittedAsset('l');
        $product = Product::query()->findOrFail('drawer-organizer');
        $this->galleries->replaceProductGallery($product, [$baseline->id], 0, $this->actor);

        try {
            $this->galleries->replaceProductGallery(
                $product,
                [$baseline->id, $baseline->id],
                1,
                $this->actor,
            );
            $this->fail('Duplicate media must fail.');
        } catch (ValidationException) {
            $this->assertSame(1, $this->galleries->productGallery($product)->revision);
        }

        $tooMany = [];
        for ($index = 0; $index <= MediaGalleryService::MAX_ITEMS; $index++) {
            $tooMany[] = $this->admittedAsset('m'.$index)->id;
        }

        try {
            $this->galleries->replaceProductGallery($product, $tooMany, 1, $this->actor);
            $this->fail('Oversized galleries must fail.');
        } catch (ValidationException) {
            $gallery = $this->galleries->productGallery($product);
            $this->assertSame(1, $gallery->revision);
            $this->assertSame($baseline->id, $gallery->items->first()->media_asset_id);
        }
    }

    private function admittedAsset(
        string $suffix,
        MediaAssetPurpose $purpose = MediaAssetPurpose::Product,
    ): MediaAsset {
        $asset = $this->draftAsset($suffix, $purpose);
        $this->media->attachDerivative(
            $asset,
            [
                'kind' => MediaDerivativeKind::Canonical->value,
                'storage_disk' => 'private-media',
                'storage_path' => "cms032/$suffix/canonical.png",
                'mime' => 'image/png',
                'bytes' => 200000 + strlen($suffix),
                'width' => 1200,
                'height' => 1200,
                'sha256' => hash('sha256', 'canonical-'.$suffix),
            ],
            $this->actor,
        );

        return $this->media->admit($asset, $this->actor);
    }

    private function draftAsset(
        string $suffix,
        MediaAssetPurpose $purpose = MediaAssetPurpose::Product,
    ): MediaAsset {
        return $this->media->registerSource([
            'purpose' => $purpose->value,
            'source_reference' => 'cms032-source-'.$suffix,
            'original_filename' => 'source-'.$suffix.'.png',
            'original_mime' => 'image/png',
            'original_bytes' => 300000 + strlen($suffix),
            'original_width' => 1600,
            'original_height' => 1600,
            'original_sha256' => hash('sha256', 'source-'.$suffix),
            'semantic_label' => 'CMS-032 production asset '.$suffix,
        ], $this->actor);
    }
}
