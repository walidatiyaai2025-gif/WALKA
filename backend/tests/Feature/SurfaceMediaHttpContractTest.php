<?php

namespace Tests\Feature;

use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use App\Models\MediaAsset;
use App\Services\MediaLibraryService;
use App\Services\SurfaceMediaService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class SurfaceMediaHttpContractTest extends TestCase
{
    use RefreshDatabase;

    private MediaLibraryService $media;

    private SurfaceMediaService $surfaceMedia;

    private string $actor;

    private array $session;

    private int $counter = 0;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        $this->media = app(MediaLibraryService::class);
        $this->surfaceMedia = app(SurfaceMediaService::class);
        $this->actor = hash('sha256', 'cms-033-http-contract-test');
        $this->session = [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_actor' => $this->actor,
        ];
    }

    public function test_admin_surface_workspace_and_mutation_are_protected(): void
    {
        $this->get('/admin/media/surfaces')
            ->assertRedirect(route('admin.login'));
        $this->patch('/admin/media/surfaces/home.hero')
            ->assertRedirect(route('admin.login'));
    }

    public function test_admin_workspace_exposes_only_purpose_correct_eligible_media_for_each_slot(): void
    {
        $home = $this->admittedAsset('Home hero eligible', MediaAssetPurpose::Home);
        $category = $this->admittedAsset('Category eligible', MediaAssetPurpose::Category);
        $editorial = $this->admittedAsset('Editorial eligible', MediaAssetPurpose::Editorial);
        $product = $this->admittedAsset('Product must stay excluded', MediaAssetPurpose::Product);

        $response = $this->withSession($this->session)
            ->get(route('admin.media.surfaces.index'))
            ->assertOk()
            ->assertSee('Home Hero')
            ->assertSee('Home · Small Changes editorial')
            ->assertSee('Category · Drawer Organization')
            ->assertSee('Category · Lunch');

        $response->assertSee($home->id)
            ->assertSee($category->id)
            ->assertSee($editorial->id)
            ->assertDontSee($product->id);
    }

    public function test_public_endpoint_is_allowlisted_revisioned_and_supports_etag_revalidation(): void
    {
        $home = $this->admittedAsset('Home hero published metadata', MediaAssetPurpose::Home);
        $this->surfaceMedia->replace(
            'home.hero',
            [$home->id],
            SurfaceMediaService::fingerprint([]),
            $this->actor,
        );

        $response = $this->getJson('/api/v1/media/surfaces')
            ->assertOk()
            ->assertJsonPath('data.schema_version', 1)
            ->assertJsonPath('meta.api_version', 'v1')
            ->assertJsonPath('meta.binary_delivery', 'not_available_until_cms_035')
            ->assertJsonCount(4, 'data.slots')
            ->assertJsonPath('data.slots.0.slot_key', 'home.hero')
            ->assertJsonPath('data.slots.0.purpose', 'home')
            ->assertJsonPath('data.slots.0.items.0.media_id', $home->id)
            ->assertJsonPath('data.slots.0.items.0.semantic_label', 'Home hero published metadata')
            ->assertJsonPath('data.slots.0.items.0.canonical.mime', 'image/png')
            ->assertJsonPath('data.slots.0.items.0.canonical.width', 1400)
            ->assertJsonPath('data.slots.0.items.0.canonical.height', 1000);

        $payload = $response->json();
        $this->assertArrayHasKey('revision_token', $payload['data']);
        $this->assertMatchesRegularExpression('/^[a-f0-9]{64}$/', $payload['data']['revision_token']);

        $json = json_encode($payload, JSON_THROW_ON_ERROR);
        foreach (
            [
                'storage_disk',
                'storage_path',
                'source_reference',
                'original_filename',
                'created_by_fingerprint',
                'updated_by_fingerprint',
                'asin',
                'pantone',
                'amazon',
                'http://',
                'https://',
            ] as $forbidden
        ) {
            $this->assertStringNotContainsString($forbidden, strtolower($json));
        }

        $etag = $response->headers->get('ETag');
        $this->assertNotNull($etag);
        $this->withHeader('If-None-Match', $etag)
            ->get('/api/v1/media/surfaces')
            ->assertStatus(304)
            ->assertHeader('ETag', $etag);
    }

    public function test_admin_can_assign_and_clear_allowlisted_slot_with_optimistic_fingerprint(): void
    {
        $home = $this->admittedAsset('Assignable Home hero', MediaAssetPurpose::Home);
        $empty = SurfaceMediaService::fingerprint([]);

        $this->withSession($this->session)
            ->patch(route('admin.media.surfaces.update', ['slot' => 'home.hero']), [
                'expected_fingerprint' => $empty,
                'media_ids' => [$home->id],
            ])
            ->assertRedirect(route('admin.media.surfaces.index'))
            ->assertSessionHas('status');

        $this->assertDatabaseHas('surface_media_items', [
            'slot_key' => 'home.hero',
            'media_asset_id' => $home->id,
            'position' => 1,
        ]);

        $this->withSession($this->session)
            ->patch(route('admin.media.surfaces.update', ['slot' => 'home.hero']), [
                'expected_fingerprint' => SurfaceMediaService::fingerprint([$home->id]),
                'media_ids' => [],
            ])
            ->assertRedirect(route('admin.media.surfaces.index'));

        $this->assertDatabaseMissing('surface_media_items', [
            'slot_key' => 'home.hero',
        ]);
    }

    public function test_archived_assigned_media_makes_public_delivery_fail_closed(): void
    {
        $home = $this->admittedAsset('Archive after assignment', MediaAssetPurpose::Home);
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

    private function admittedAsset(string $label, MediaAssetPurpose $purpose): MediaAsset
    {
        $this->counter++;
        $counter = $this->counter;
        $asset = $this->media->registerSource([
            'purpose' => $purpose->value,
            'source_reference' => "cms033-http-source-$counter",
            'original_filename' => "cms033-http-source-$counter.png",
            'original_mime' => 'image/png',
            'original_bytes' => 500000 + $counter,
            'original_width' => 1800,
            'original_height' => 1400,
            'original_sha256' => hash('sha256', "cms033-http-source-$counter"),
            'semantic_label' => $label,
        ], $this->actor);
        $this->media->attachDerivative($asset, [
            'kind' => MediaDerivativeKind::Canonical->value,
            'storage_disk' => 'private-media',
            'storage_path' => "cms033/http/$counter/canonical.png",
            'mime' => 'image/png',
            'bytes' => 240000 + $counter,
            'width' => 1400,
            'height' => 1000,
            'sha256' => hash('sha256', "cms033-http-canonical-$counter"),
        ], $this->actor);

        return $this->media->admit($asset, $this->actor);
    }
}
