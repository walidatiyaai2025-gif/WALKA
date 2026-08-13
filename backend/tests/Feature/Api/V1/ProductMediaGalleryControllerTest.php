<?php

namespace Tests\Feature\Api\V1;

use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use App\Models\MediaAsset;
use App\Services\MediaLibraryService;
use App\Services\ProductMediaGalleryService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class ProductMediaGalleryControllerTest extends TestCase
{
    use RefreshDatabase;

    private int $counter = 0;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        $this->actor = hash('sha256', 'cms-032-gallery-api-test');
    }

    public function test_public_payload_is_allowlisted_and_variant_fallback_is_deterministic(): void
    {
        $productHero = $this->admittedAsset('Drawer Organizer product hero');
        $variantHero = $this->admittedAsset('Drawer Organizer White hero');
        $galleries = app(ProductMediaGalleryService::class);

        $galleries->replaceProductGallery(
            'drawer-organizer',
            [$productHero->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );
        $galleries->replaceVariantGallery(
            'drawer-organizer:white',
            [$variantHero->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );

        $response = $this->getJson('/api/v1/media/product-galleries')
            ->assertOk()
            ->assertJsonPath('data.schema_version', 1)
            ->assertJsonPath('meta.api_version', 'v1')
            ->assertJsonPath('meta.binary_delivery', 'not_enabled')
            ->assertJsonPath('data.products.0.product_id', 'drawer-organizer')
            ->assertJsonPath('data.products.0.gallery.0.media_id', $productHero->id)
            ->assertJsonPath('data.products.0.gallery.0.semantic_label', 'Drawer Organizer product hero')
            ->assertJsonPath('data.products.0.variants.0.variant_id', 'drawer-organizer:white')
            ->assertJsonPath('data.products.0.variants.0.gallery_source', 'variant')
            ->assertJsonPath('data.products.0.variants.0.gallery.0.media_id', $variantHero->id)
            ->assertJsonPath('data.products.0.variants.1.variant_id', 'drawer-organizer:gray')
            ->assertJsonPath('data.products.0.variants.1.gallery_source', 'product_fallback')
            ->assertJsonPath('data.products.0.variants.1.gallery.0.media_id', $productHero->id);

        $raw = $response->getContent();
        foreach ([
            'storage_disk',
            'storage_path',
            'source_reference',
            'source_storage_disk',
            'source_storage_path',
            'original_filename',
            'original_sha256',
            'created_by_fingerprint',
            'updated_by_fingerprint',
            'asin',
            'pantone',
            'amazon',
            'target_url',
        ] as $forbidden) {
            $this->assertStringNotContainsString($forbidden, $raw);
        }
    }

    public function test_public_payload_contains_complete_catalog_identity_even_with_empty_galleries(): void
    {
        $this->getJson('/api/v1/media/product-galleries')
            ->assertOk()
            ->assertJsonCount(2, 'data.products')
            ->assertJsonCount(2, 'data.products.0.variants')
            ->assertJsonCount(3, 'data.products.1.variants')
            ->assertJsonPath('data.products.0.gallery', [])
            ->assertJsonPath('data.products.1.gallery', [])
            ->assertJsonPath('data.products.1.variants.2.variant_id', 'lunch-box:green')
            ->assertJsonPath('data.products.1.variants.2.gallery_source', 'product_fallback')
            ->assertJsonPath('data.products.1.variants.2.gallery', []);
    }

    public function test_archived_assigned_media_fails_closed_at_delivery_boundary(): void
    {
        $asset = $this->admittedAsset('Lunch Blue production hero');
        $galleries = app(ProductMediaGalleryService::class);
        $galleries->replaceVariantGallery(
            'lunch-box:blue',
            [$asset->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );

        app(MediaLibraryService::class)->archive($asset, $this->actor);

        $this->getJson('/api/v1/media/product-galleries')
            ->assertStatus(503)
            ->assertJsonPath('error.code', 'media_gallery_invalid');
    }

    private function admittedAsset(string $label): MediaAsset
    {
        $this->counter++;
        $counter = $this->counter;
        $library = app(MediaLibraryService::class);
        $asset = $library->registerSource([
            'purpose' => MediaAssetPurpose::Product,
            'source_reference' => "cms-032-api-$counter",
            'original_filename' => "source-$counter.png",
            'original_mime' => 'image/png',
            'original_bytes' => 3000 + $counter,
            'original_width' => 1600,
            'original_height' => 1600,
            'original_sha256' => hash('sha256', "api-source-$counter"),
            'semantic_label' => $label,
        ], $this->actor);
        $library->attachDerivative($asset, [
            'kind' => MediaDerivativeKind::Canonical,
            'storage_disk' => 'private-canonical',
            'storage_path' => "products/private-$counter.png",
            'mime' => 'image/png',
            'bytes' => 2000 + $counter,
            'width' => 1200,
            'height' => 1200,
            'sha256' => hash('sha256', "api-derivative-$counter"),
        ], $this->actor);

        return $library->admit($asset, $this->actor);
    }
}
