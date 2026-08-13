<?php

namespace Tests\Feature\Api\V1;

use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use App\Models\MediaAsset;
use App\Services\MediaLibraryService;
use App\Services\MediaReplacementService;
use App\Services\ProductMediaGalleryService;
use App\Services\SurfaceMediaService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class MediaReplacementAuditNonDisclosureTest extends TestCase
{
    use RefreshDatabase;

    private MediaLibraryService $media;

    private ProductMediaGalleryService $galleries;

    private SurfaceMediaService $surfaces;

    private MediaReplacementService $replacements;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        $this->media = app(MediaLibraryService::class);
        $this->galleries = app(ProductMediaGalleryService::class);
        $this->surfaces = app(SurfaceMediaService::class);
        $this->replacements = app(MediaReplacementService::class);
        $this->actor = hash('sha256', 'cms-034-public-nondisclosure-test');
    }

    public function test_public_media_contracts_show_current_references_but_never_replacement_audit_metadata(): void
    {
        $productSource = $this->admittedAsset('public-product-source', MediaAssetPurpose::Product);
        $productReplacement = $this->admittedAsset('public-product-replacement', MediaAssetPurpose::Product);
        $homeSource = $this->admittedAsset('public-home-source', MediaAssetPurpose::Home);
        $homeReplacement = $this->admittedAsset('public-home-replacement', MediaAssetPurpose::Home);

        $this->galleries->replaceProductGallery(
            'drawer-organizer',
            [$productSource->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );
        $this->surfaces->replace(
            'home.hero',
            [$homeSource->id],
            SurfaceMediaService::fingerprint([]),
            $this->actor,
        );

        $productEvent = $this->replacements->replace(
            $productSource,
            $productReplacement,
            $this->replacements->assignmentFingerprint($productSource),
            $this->actor,
        );
        $homeEvent = $this->replacements->replace(
            $homeSource,
            $homeReplacement,
            $this->replacements->assignmentFingerprint($homeSource),
            $this->actor,
        );

        $productResponse = $this->getJson('/api/v1/media/product-galleries')->assertOk();
        $surfaceResponse = $this->getJson('/api/v1/media/surfaces')->assertOk();
        $productRaw = $productResponse->getContent();
        $surfaceRaw = $surfaceResponse->getContent();
        $combined = $productRaw.$surfaceRaw;

        $this->assertStringContainsString($productReplacement->id, $productRaw);
        $this->assertStringNotContainsString($productSource->id, $productRaw);
        $this->assertStringContainsString($homeReplacement->id, $surfaceRaw);
        $this->assertStringNotContainsString($homeSource->id, $surfaceRaw);

        foreach ([
            $productEvent->id,
            $homeEvent->id,
            $productEvent->before_fingerprint,
            $productEvent->after_fingerprint,
            $homeEvent->before_fingerprint,
            $homeEvent->after_fingerprint,
            $this->actor,
            'media_replacement_events',
            'rollback_of_event_id',
            'actor_fingerprint',
            'before_assignments',
            'after_assignments',
        ] as $privateValue) {
            $this->assertStringNotContainsString($privateValue, $combined);
        }
    }

    private function admittedAsset(string $suffix, MediaAssetPurpose $purpose): MediaAsset
    {
        $asset = $this->media->registerSource([
            'purpose' => $purpose->value,
            'source_reference' => 'cms034-private-provenance-'.$suffix,
            'original_filename' => 'private-replacement-'.$suffix.'.png',
            'original_mime' => 'image/png',
            'original_bytes' => 490000 + strlen($suffix),
            'original_width' => 1800,
            'original_height' => 1500,
            'original_sha256' => hash('sha256', 'cms034-public-source-'.$suffix),
            'semantic_label' => 'CMS-034 public media '.$suffix,
        ], $this->actor);
        $this->media->attachDerivative($asset, [
            'kind' => MediaDerivativeKind::Canonical->value,
            'storage_disk' => 'private-media',
            'storage_path' => "cms034/public/$suffix/canonical.png",
            'mime' => 'image/png',
            'bytes' => 270000 + strlen($suffix),
            'width' => 1400,
            'height' => 1200,
            'sha256' => hash('sha256', 'cms034-public-canonical-'.$suffix),
        ], $this->actor);

        return $this->media->admit($asset, $this->actor);
    }
}
