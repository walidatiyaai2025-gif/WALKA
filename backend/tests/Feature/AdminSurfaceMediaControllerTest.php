<?php

namespace Tests\Feature;

use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use App\Models\MediaAsset;
use App\Models\SurfaceMediaItem;
use App\Services\MediaLibraryService;
use App\Services\SurfaceMediaService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AdminSurfaceMediaControllerTest extends TestCase
{
    use RefreshDatabase;

    private array $session;

    private MediaLibraryService $media;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        config()->set('walka.dashboard_username', 'admin');
        config()->set('walka.dashboard_password', 'Walka-Admin-Test-Password-2026');
        $this->actor = hash('sha256', 'cms-033-admin-surface-test');
        $this->session = [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_actor' => $this->actor,
        ];
        $this->media = app(MediaLibraryService::class);
    }

    public function test_surface_media_workspace_and_mutations_are_protected(): void
    {
        $this->get('/admin/media/surfaces')->assertRedirect(route('admin.login'));
        $this->patch('/admin/media/surfaces/home.hero')->assertRedirect(route('admin.login'));
    }

    public function test_workspace_shows_only_compiled_slots_and_purpose_eligible_assets(): void
    {
        $home = $this->admittedAsset('home-visible', MediaAssetPurpose::Home);
        $category = $this->admittedAsset('category-hidden-from-home', MediaAssetPurpose::Category);

        $response = $this->withSession($this->session)
            ->get(route('admin.media.surfaces.index'))
            ->assertOk()
            ->assertSeeText('Home, category & editorial media')
            ->assertSee('home.hero')
            ->assertSee('home.editorial.small_changes')
            ->assertSee('category:drawer-organization')
            ->assertSee('category:lunch')
            ->assertSee($home->semantic_label)
            ->assertSee($category->semantic_label);

        $this->assertStringNotContainsString('home.remote-widget-from-server', $response->getContent());
    }

    public function test_owner_can_assign_and_explicitly_clear_a_home_slot(): void
    {
        $asset = $this->admittedAsset('home-assign', MediaAssetPurpose::Home);
        $emptyFingerprint = SurfaceMediaService::fingerprint([]);

        $this->withSession($this->session)
            ->patch(route('admin.media.surfaces.update', ['slot' => 'home.hero']), [
                'expected_fingerprint' => $emptyFingerprint,
                'media_ids' => [$asset->id],
            ])
            ->assertRedirect(route('admin.media.surfaces.index'))
            ->assertSessionHas('status');

        $this->assertDatabaseHas('surface_media_items', [
            'slot_key' => 'home.hero',
            'media_asset_id' => $asset->id,
            'position' => 1,
        ]);

        $this->withSession($this->session)
            ->patch(route('admin.media.surfaces.update', ['slot' => 'home.hero']), [
                'expected_fingerprint' => SurfaceMediaService::fingerprint([$asset->id]),
                'media_ids' => [''],
            ])
            ->assertRedirect(route('admin.media.surfaces.index'))
            ->assertSessionHas('status');

        $this->assertDatabaseMissing('surface_media_items', [
            'slot_key' => 'home.hero',
        ]);
    }

    public function test_stale_and_wrong_purpose_requests_leave_current_assignment_unchanged(): void
    {
        $home = $this->admittedAsset('home-current', MediaAssetPurpose::Home);
        $replacement = $this->admittedAsset('home-replacement', MediaAssetPurpose::Home);
        $category = $this->admittedAsset('category-invalid', MediaAssetPurpose::Category);

        $this->withSession($this->session)
            ->patch(route('admin.media.surfaces.update', ['slot' => 'home.hero']), [
                'expected_fingerprint' => SurfaceMediaService::fingerprint([]),
                'media_ids' => [$home->id],
            ]);

        $this->withSession($this->session)
            ->from(route('admin.media.surfaces.index'))
            ->patch(route('admin.media.surfaces.update', ['slot' => 'home.hero']), [
                'expected_fingerprint' => SurfaceMediaService::fingerprint([]),
                'media_ids' => [$replacement->id],
            ])
            ->assertRedirect(route('admin.media.surfaces.index'))
            ->assertSessionHasErrors('gallery');

        $this->withSession($this->session)
            ->from(route('admin.media.surfaces.index'))
            ->patch(route('admin.media.surfaces.update', ['slot' => 'home.hero']), [
                'expected_fingerprint' => SurfaceMediaService::fingerprint([$home->id]),
                'media_ids' => [$category->id],
            ])
            ->assertRedirect(route('admin.media.surfaces.index'))
            ->assertSessionHasErrors('media_ids');

        $this->assertSame(
            [$home->id],
            SurfaceMediaItem::query()
                ->where('slot_key', 'home.hero')
                ->orderBy('position')
                ->pluck('media_asset_id')
                ->all(),
        );
    }

    public function test_unknown_slot_is_rejected_without_creating_assignment(): void
    {
        $asset = $this->admittedAsset('home-unknown-slot', MediaAssetPurpose::Home);

        $this->withSession($this->session)
            ->from(route('admin.media.surfaces.index'))
            ->patch('/admin/media/surfaces/home.remote-widget-from-server', [
                'expected_fingerprint' => SurfaceMediaService::fingerprint([]),
                'media_ids' => [$asset->id],
            ])
            ->assertRedirect(route('admin.media.surfaces.index'))
            ->assertSessionHasErrors('slot_key');

        $this->assertDatabaseMissing('surface_media_items', [
            'slot_key' => 'home.remote-widget-from-server',
        ]);
    }

    private function admittedAsset(string $suffix, MediaAssetPurpose $purpose): MediaAsset
    {
        $asset = $this->media->registerSource([
            'purpose' => $purpose->value,
            'source_reference' => 'cms033-admin-source-'.$suffix,
            'original_filename' => 'admin-surface-'.$suffix.'.png',
            'original_mime' => 'image/png',
            'original_bytes' => 430000 + strlen($suffix),
            'original_width' => 1800,
            'original_height' => 1400,
            'original_sha256' => hash('sha256', 'cms033-admin-source-'.$suffix),
            'semantic_label' => 'CMS-033 admin surface '.$suffix,
        ], $this->actor);
        $this->media->attachDerivative($asset, [
            'kind' => MediaDerivativeKind::Canonical->value,
            'storage_disk' => 'private-media',
            'storage_path' => "cms033/admin/$suffix/canonical.png",
            'mime' => 'image/png',
            'bytes' => 230000 + strlen($suffix),
            'width' => 1400,
            'height' => 1000,
            'sha256' => hash('sha256', 'cms033-admin-canonical-'.$suffix),
        ], $this->actor);

        return $this->media->admit($asset, $this->actor);
    }
}
