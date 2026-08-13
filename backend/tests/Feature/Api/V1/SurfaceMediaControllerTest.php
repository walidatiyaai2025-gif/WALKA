<?php

namespace Tests\Feature\Api\V1;

use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use App\Models\MediaAsset;
use App\Models\SurfaceMediaItem;
use App\Services\MediaLibraryService;
use App\Services\SurfaceMediaService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class SurfaceMediaControllerTest extends TestCase
{
    use RefreshDatabase;

    private SurfaceMediaService $surfaceMedia;

    private MediaLibraryService $media;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        $this->surfaceMedia = app(SurfaceMediaService::class);
        $this->media = app(MediaLibraryService::class);
        $this->actor = hash('sha256', 'cms-033-surface-api-test');
    }

    public function test_public_contract_is_complete_allowlisted_cacheable_and_path_free(): void
    {
        $home = $this->admittedAsset('home-api', MediaAssetPurpose::Home);
        $category = $this->admittedAsset('category-api', MediaAssetPurpose::Category);

        $this->surfaceMedia->replace(
            'home.hero',
            [$home->id],
            SurfaceMediaService::fingerprint([]),
            $this->actor,
        );
        $this->surfaceMedia->replace(
            'category:lunch',
            [$category->id],
            SurfaceMediaService::fingerprint([]),
            $this->actor,
        );

        $response = $this->getJson('/api/v1/media/surfaces')
            ->assertOk()
            ->assertJsonPath('data.schema_version', 1)
            ->assertJsonPath('meta.api_version', 'v1')
            ->assertJsonPath('meta.binary_delivery', 'not_available_until_cms_035');

        $slots = collect($response->json('data.slots'));
        $this->assertSame([
            'home.hero',
            'home.editorial.small_changes',
            'category:drawer-organization',
            'category:lunch',
        ], $slots->pluck('slot_key')->all());

        $homeSlot = $slots->firstWhere('slot_key', 'home.hero');
        $categorySlot = $slots->firstWhere('slot_key', 'category:lunch');
        $this->assertSame('home', $homeSlot['purpose']);
        $this->assertNull($homeSlot['category_id']);
        $this->assertSame($home->id, $homeSlot['items'][0]['media_id']);
        $this->assertSame('image/png', $homeSlot['items'][0]['canonical']['mime']);
        $this->assertSame(1400, $homeSlot['items'][0]['canonical']['width']);
        $this->assertSame(1000, $homeSlot['items'][0]['canonical']['height']);
        $this->assertSame('category', $categorySlot['purpose']);
        $this->assertSame('lunch', $categorySlot['category_id']);
        $this->assertSame($category->id, $categorySlot['items'][0]['media_id']);

        $raw = $response->getContent();
        $this->assertStringNotContainsString('storage_disk', $raw);
        $this->assertStringNotContainsString('storage_path', $raw);
        $this->assertStringNotContainsString('private-media', $raw);
        $this->assertStringNotContainsString('cms033/api/', $raw);
        $this->assertStringNotContainsString('source_reference', $raw);
        $this->assertStringNotContainsString('original_filename', $raw);
        $this->assertStringNotContainsString('supplier-private', $raw);

        $etag = $response->headers->get('ETag');
        $this->assertNotNull($etag);
        $this->withHeader('If-None-Match', $etag)
            ->get('/api/v1/media/surfaces')
            ->assertStatus(304)
            ->assertHeader('ETag', $etag);
    }

    public function test_empty_contract_still_delivers_the_complete_compiled_slot_set(): void
    {
        $response = $this->getJson('/api/v1/media/surfaces')
            ->assertOk()
            ->assertJsonPath('data.schema_version', 1);

        $slots = $response->json('data.slots');
        $this->assertCount(4, $slots);
        foreach ($slots as $slot) {
            $this->assertSame([], $slot['items']);
        }
    }

    public function test_archived_assigned_media_fails_closed_at_public_boundary(): void
    {
        $home = $this->admittedAsset('home-archive-api', MediaAssetPurpose::Home);
        $this->surfaceMedia->replace(
            'home.hero',
            [$home->id],
            SurfaceMediaService::fingerprint([]),
            $this->actor,
        );
        $this->media->archive($home, $this->actor);

        $this->getJson('/api/v1/media/surfaces')
            ->assertStatus(503)
            ->assertJsonPath('error.code', 'surface_media_invalid');
    }

    public function test_unknown_persisted_slot_fails_closed_instead_of_being_silently_ignored(): void
    {
        $home = $this->admittedAsset('unknown-slot-api', MediaAssetPurpose::Home);
        SurfaceMediaItem::query()->create([
            'slot_key' => 'home.remote-widget-from-database',
            'media_asset_id' => $home->id,
            'position' => 1,
            'created_by_fingerprint' => $this->actor,
        ]);

        $this->getJson('/api/v1/media/surfaces')
            ->assertStatus(503)
            ->assertJsonPath('error.code', 'surface_media_invalid');
    }

    private function admittedAsset(string $suffix, MediaAssetPurpose $purpose): MediaAsset
    {
        $asset = $this->media->registerSource([
            'purpose' => $purpose->value,
            'source_reference' => 'supplier-private-'.$suffix,
            'original_filename' => 'private-surface-'.$suffix.'.png',
            'original_mime' => 'image/png',
            'original_bytes' => 440000 + strlen($suffix),
            'original_width' => 1800,
            'original_height' => 1400,
            'original_sha256' => hash('sha256', 'cms033-api-source-'.$suffix),
            'semantic_label' => 'CMS-033 public surface '.$suffix,
        ], $this->actor);
        $this->media->attachDerivative($asset, [
            'kind' => MediaDerivativeKind::Canonical->value,
            'storage_disk' => 'private-media',
            'storage_path' => "cms033/api/$suffix/canonical.png",
            'mime' => 'image/png',
            'bytes' => 240000 + strlen($suffix),
            'width' => 1400,
            'height' => 1000,
            'sha256' => hash('sha256', 'cms033-api-canonical-'.$suffix),
        ], $this->actor);

        return $this->media->admit($asset, $this->actor);
    }
}
