<?php

namespace Tests\Feature\Api\V1;

use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use App\Models\MediaAsset;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Services\MediaGalleryService;
use App\Services\MediaLibraryService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class MediaGalleryApiTest extends TestCase
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
        $this->actor = hash('sha256', 'cms-032-gallery-api-test');
    }

    public function test_public_gallery_metadata_is_allowlisted_ordered_and_supports_product_fallback(): void
    {
        $productAsset = $this->admittedAsset('a');
        $variantAsset = $this->admittedAsset('b');
        $product = Product::query()->findOrFail('stainless-steel-bento-lunch-box');
        $blue = ProductVariant::query()->findOrFail('lunch-box:blue');

        $this->galleries->replaceProductGallery($product, [$productAsset->id], 0, $this->actor);
        $this->galleries->replaceVariantGallery($blue, [$variantAsset->id], 0, $this->actor);

        $response = $this->getJson('/api/v1/media/galleries')
            ->assertOk()
            ->assertJsonPath('data.schema_version', 1)
            ->assertJsonPath('meta.api_version', 'v1');

        $products = collect($response->json('data.products'));
        $lunch = $products->firstWhere('product_id', $product->id);
        $bluePublic = collect($lunch['variants'])->firstWhere('variant_id', 'lunch-box:blue');
        $pinkPublic = collect($lunch['variants'])->firstWhere('variant_id', 'lunch-box:pink');

        $this->assertSame('variant', $bluePublic['gallery']['source']);
        $this->assertSame($variantAsset->id, $bluePublic['gallery']['items'][0]['media_asset_id']);
        $this->assertSame('product_fallback', $pinkPublic['gallery']['source']);
        $this->assertSame($productAsset->id, $pinkPublic['gallery']['items'][0]['media_asset_id']);
        $this->assertSame(0, $pinkPublic['gallery']['items'][0]['position']);
        $this->assertSame('image/png', $pinkPublic['gallery']['items'][0]['canonical']['mime']);
        $this->assertSame(1200, $pinkPublic['gallery']['items'][0]['canonical']['width']);
        $this->assertSame(1200, $pinkPublic['gallery']['items'][0]['canonical']['height']);

        $raw = $response->getContent();
        $this->assertStringNotContainsString('storage_disk', $raw);
        $this->assertStringNotContainsString('storage_path', $raw);
        $this->assertStringNotContainsString('private-media', $raw);
        $this->assertStringNotContainsString('cms032/api/', $raw);
        $this->assertStringNotContainsString('source_reference', $raw);
        $this->assertStringNotContainsString('original_filename', $raw);
        $this->assertStringNotContainsString('supplier-secret', $raw);
        $this->assertStringNotContainsString('.png', $raw);

        $etag = $response->headers->get('ETag');
        $this->assertNotNull($etag);
        $this->withHeader('If-None-Match', $etag)
            ->get('/api/v1/media/galleries')
            ->assertStatus(304)
            ->assertHeader('ETag', $etag);
    }

    public function test_empty_gallery_contract_is_stable_before_any_assignment(): void
    {
        $response = $this->getJson('/api/v1/media/galleries')
            ->assertOk()
            ->assertJsonPath('data.schema_version', 1);

        $this->assertCount(2, $response->json('data.products'));
        foreach ($response->json('data.products') as $product) {
            $this->assertSame('empty', $product['gallery']['source']);
            $this->assertSame([], $product['gallery']['items']);
            foreach ($product['variants'] as $variant) {
                $this->assertSame('empty', $variant['gallery']['source']);
                $this->assertSame([], $variant['gallery']['items']);
            }
        }
    }

    public function test_archived_assignment_makes_public_delivery_fail_closed(): void
    {
        $asset = $this->admittedAsset('c');
        $product = Product::query()->findOrFail('drawer-organizer');
        $this->galleries->replaceProductGallery($product, [$asset->id], 0, $this->actor);
        $this->media->archive($asset, $this->actor);

        $this->getJson('/api/v1/media/galleries')
            ->assertStatus(503)
            ->assertJsonPath('error.code', 'media_gallery_invalid');
    }

    private function admittedAsset(string $suffix): MediaAsset
    {
        $asset = $this->media->registerSource([
            'purpose' => MediaAssetPurpose::Product->value,
            'source_reference' => 'supplier-secret-'.$suffix,
            'original_filename' => 'private-source-'.$suffix.'.png',
            'original_mime' => 'image/png',
            'original_bytes' => 500000 + strlen($suffix),
            'original_width' => 1800,
            'original_height' => 1800,
            'original_sha256' => hash('sha256', 'cms032-api-source-'.$suffix),
            'semantic_label' => 'CMS-032 public asset '.$suffix,
        ], $this->actor);
        $this->media->attachDerivative($asset, [
            'kind' => MediaDerivativeKind::Canonical->value,
            'storage_disk' => 'private-media',
            'storage_path' => "cms032/api/$suffix/canonical.png",
            'mime' => 'image/png',
            'bytes' => 210000 + strlen($suffix),
            'width' => 1200,
            'height' => 1200,
            'sha256' => hash('sha256', 'cms032-api-canonical-'.$suffix),
        ], $this->actor);

        return $this->media->admit($asset, $this->actor);
    }
}
