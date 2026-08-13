<?php

namespace Tests\Feature;

use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use App\Models\MediaAsset;
use App\Models\MediaGallery;
use App\Services\MediaLibraryService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AdminMediaGalleryControllerTest extends TestCase
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
        $this->actor = hash('sha256', 'cms-032-admin-gallery-test');
        $this->session = [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_actor' => $this->actor,
        ];
        $this->media = app(MediaLibraryService::class);
    }

    public function test_gallery_workspace_and_mutations_are_protected(): void
    {
        $this->get('/admin/media/galleries')->assertRedirect(route('admin.login'));
        $this->patch('/admin/media/galleries/products/drawer-organizer')
            ->assertRedirect(route('admin.login'));
        $this->patch('/admin/media/galleries/variants/lunch-box:blue')
            ->assertRedirect(route('admin.login'));
    }

    public function test_owner_can_atomically_assign_and_reorder_product_gallery(): void
    {
        $first = $this->admittedAsset('a');
        $second = $this->admittedAsset('b');

        $this->withSession($this->session)
            ->get(route('admin.media.galleries.index'))
            ->assertOk()
            ->assertSeeText('Product & variant galleries')
            ->assertSee($first->semantic_label)
            ->assertSee('drawer-organizer')
            ->assertSee('lunch-box:blue');

        $this->withSession($this->session)
            ->patch(route('admin.media.galleries.products.update', ['product' => 'drawer-organizer']), [
                'expected_revision' => 0,
                'media_ids' => [$second->id, $first->id],
            ])
            ->assertRedirect(route('admin.media.galleries.index'))
            ->assertSessionHas('status');

        $gallery = MediaGallery::query()
            ->where('product_id', 'drawer-organizer')
            ->firstOrFail()
            ->load('items');
        $this->assertSame(1, $gallery->revision);
        $this->assertSame(
            [$second->id, $first->id],
            $gallery->items->pluck('media_asset_id')->values()->all(),
        );

        $this->withSession($this->session)
            ->patch(route('admin.media.galleries.products.update', ['product' => 'drawer-organizer']), [
                'expected_revision' => 1,
                'media_ids' => [$first->id, $second->id],
            ])
            ->assertRedirect(route('admin.media.galleries.index'));

        $gallery = $gallery->refresh()->load('items');
        $this->assertSame(2, $gallery->revision);
        $this->assertSame(
            [$first->id, $second->id],
            $gallery->items->pluck('media_asset_id')->values()->all(),
        );
    }

    public function test_stale_and_invalid_requests_leave_existing_gallery_unchanged(): void
    {
        $first = $this->admittedAsset('c');
        $second = $this->admittedAsset('d');

        $this->withSession($this->session)
            ->patch(route('admin.media.galleries.products.update', ['product' => 'drawer-organizer']), [
                'expected_revision' => 0,
                'media_ids' => [$first->id],
            ]);

        $this->withSession($this->session)
            ->patch(route('admin.media.galleries.products.update', ['product' => 'drawer-organizer']), [
                'expected_revision' => 0,
                'media_ids' => [$second->id],
            ])
            ->assertRedirect(route('admin.media.galleries.index'))
            ->assertSessionHasErrors('revision');

        $gallery = MediaGallery::query()
            ->where('product_id', 'drawer-organizer')
            ->firstOrFail()
            ->load('items');
        $this->assertSame(1, $gallery->revision);
        $this->assertSame($first->id, $gallery->items->first()->media_asset_id);

        $this->withSession($this->session)
            ->from(route('admin.media.galleries.index'))
            ->patch(route('admin.media.galleries.products.update', ['product' => 'drawer-organizer']), [
                'expected_revision' => 1,
                'media_ids' => ['01INVALIDMEDIAASSET00000000'],
            ])
            ->assertRedirect(route('admin.media.galleries.index'))
            ->assertSessionHasErrors('media_ids');

        $gallery = $gallery->refresh()->load('items');
        $this->assertSame(1, $gallery->revision);
        $this->assertSame($first->id, $gallery->items->first()->media_asset_id);
    }

    public function test_variant_target_uses_stable_route_binding_and_unknown_targets_404(): void
    {
        $asset = $this->admittedAsset('e');

        $this->withSession($this->session)
            ->patch(route('admin.media.galleries.variants.update', ['variant' => 'lunch-box:blue']), [
                'expected_revision' => 0,
                'media_ids' => [$asset->id],
            ])
            ->assertRedirect(route('admin.media.galleries.index'));

        $this->assertDatabaseHas('media_galleries', [
            'product_id' => null,
            'product_variant_id' => 'lunch-box:blue',
            'revision' => 1,
        ]);

        $this->withSession($this->session)
            ->patch('/admin/media/galleries/products/missing-product', [
                'expected_revision' => 0,
                'media_ids' => [$asset->id],
            ])
            ->assertNotFound();
        $this->withSession($this->session)
            ->patch('/admin/media/galleries/variants/missing:variant', [
                'expected_revision' => 0,
                'media_ids' => [$asset->id],
            ])
            ->assertNotFound();
    }

    private function admittedAsset(string $suffix): MediaAsset
    {
        $asset = $this->media->registerSource([
            'purpose' => MediaAssetPurpose::Product->value,
            'source_reference' => 'cms032-admin-source-'.$suffix,
            'original_filename' => 'admin-'.$suffix.'.png',
            'original_mime' => 'image/png',
            'original_bytes' => 400000 + strlen($suffix),
            'original_width' => 1600,
            'original_height' => 1600,
            'original_sha256' => hash('sha256', 'cms032-admin-source-'.$suffix),
            'semantic_label' => 'CMS-032 admin asset '.$suffix,
        ], $this->actor);
        $this->media->attachDerivative($asset, [
            'kind' => MediaDerivativeKind::Canonical->value,
            'storage_disk' => 'private-media',
            'storage_path' => "cms032/admin/$suffix/canonical.png",
            'mime' => 'image/png',
            'bytes' => 200000 + strlen($suffix),
            'width' => 1200,
            'height' => 1200,
            'sha256' => hash('sha256', 'cms032-admin-canonical-'.$suffix),
        ], $this->actor);

        return $this->media->admit($asset, $this->actor);
    }
}
