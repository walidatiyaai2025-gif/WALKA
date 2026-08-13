<?php

namespace Tests\Feature;

use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use App\Models\MediaAsset;
use App\Models\ProductMediaGalleryItem;
use App\Models\VariantMediaGalleryItem;
use App\Services\MediaLibraryService;
use App\Services\ProductMediaGalleryService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AdminMediaGalleryControllerTest extends TestCase
{
    use RefreshDatabase;

    private array $session;

    private int $counter = 0;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        config()->set('walka.dashboard_username', 'admin');
        config()->set('walka.dashboard_password', 'Walka-Admin-Test-Password-2026');
        $this->actor = hash('sha256', 'cms-032-gallery-admin-test');
        $this->session = [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_actor' => $this->actor,
        ];
    }

    public function test_gallery_workspace_and_mutations_are_protected(): void
    {
        $this->get('/admin/media/galleries')->assertRedirect(route('admin.login'));
        $this->put('/admin/media/galleries/products/drawer-organizer')
            ->assertRedirect(route('admin.login'));
        $this->put('/admin/media/galleries/variants/lunch-box:blue')
            ->assertRedirect(route('admin.login'));
    }

    public function test_workspace_lists_only_admitted_product_media_with_canonical_derivative(): void
    {
        $eligible = $this->admittedAsset('Eligible Drawer White image');
        $draft = $this->draftAssetWithCanonical('Draft media must stay hidden');
        $wrongPurpose = $this->admittedAsset('Home media must stay hidden', MediaAssetPurpose::Home);

        $this->withSession($this->session)
            ->get(route('admin.media.galleries.index'))
            ->assertOk()
            ->assertSee('Product & variant galleries')
            ->assertSee($eligible->id)
            ->assertSee('Eligible Drawer White image')
            ->assertDontSee($draft->id)
            ->assertDontSee('Draft media must stay hidden')
            ->assertDontSee($wrongPurpose->id)
            ->assertDontSee('Home media must stay hidden');
    }

    public function test_owner_can_save_product_and_variant_order_and_clear_variant_to_fallback(): void
    {
        $first = $this->admittedAsset('Drawer product hero');
        $second = $this->admittedAsset('Drawer product detail');
        $variant = $this->admittedAsset('Drawer Gray hero');
        $empty = ProductMediaGalleryService::fingerprint([]);

        $this->withSession($this->session)
            ->put(route('admin.media.galleries.products.update', ['product' => 'drawer-organizer']), [
                'expected_fingerprint' => $empty,
                'media_ids' => [$second->id, $first->id, ''],
            ])
            ->assertRedirect(route('admin.media.galleries.index'))
            ->assertSessionHas('status');

        $this->assertSame(
            [$second->id, $first->id],
            ProductMediaGalleryItem::query()
                ->where('product_id', 'drawer-organizer')
                ->orderBy('position')
                ->pluck('media_asset_id')
                ->all(),
        );

        $this->withSession($this->session)
            ->put(route('admin.media.galleries.variants.update', ['variant' => 'drawer-organizer:gray']), [
                'expected_fingerprint' => $empty,
                'media_ids' => [$variant->id],
            ])
            ->assertRedirect(route('admin.media.galleries.index'));
        $this->assertSame(
            [$variant->id],
            VariantMediaGalleryItem::query()
                ->where('product_variant_id', 'drawer-organizer:gray')
                ->orderBy('position')
                ->pluck('media_asset_id')
                ->all(),
        );

        $this->withSession($this->session)
            ->put(route('admin.media.galleries.variants.update', ['variant' => 'drawer-organizer:gray']), [
                'expected_fingerprint' => ProductMediaGalleryService::fingerprint([$variant->id]),
                'media_ids' => ['', ''],
            ])
            ->assertRedirect(route('admin.media.galleries.index'));
        $this->assertSame(0, VariantMediaGalleryItem::query()
            ->where('product_variant_id', 'drawer-organizer:gray')
            ->count());
    }

    public function test_stale_or_non_admitted_admin_write_is_rejected_without_mutation(): void
    {
        $current = $this->admittedAsset('Current Drawer hero');
        $replacement = $this->admittedAsset('Replacement Drawer hero');
        $draft = $this->draftAssetWithCanonical('Draft must never assign');
        $empty = ProductMediaGalleryService::fingerprint([]);

        $this->withSession($this->session)
            ->put(route('admin.media.galleries.products.update', ['product' => 'drawer-organizer']), [
                'expected_fingerprint' => $empty,
                'media_ids' => [$current->id],
            ])
            ->assertRedirect(route('admin.media.galleries.index'));

        $this->withSession($this->session)
            ->from(route('admin.media.galleries.index'))
            ->put(route('admin.media.galleries.products.update', ['product' => 'drawer-organizer']), [
                'expected_fingerprint' => $empty,
                'media_ids' => [$replacement->id],
            ])
            ->assertRedirect(route('admin.media.galleries.index'))
            ->assertSessionHasErrors('gallery');

        $this->assertSame(
            [$current->id],
            ProductMediaGalleryItem::query()
                ->where('product_id', 'drawer-organizer')
                ->orderBy('position')
                ->pluck('media_asset_id')
                ->all(),
        );

        $this->withSession($this->session)
            ->from(route('admin.media.galleries.index'))
            ->put(route('admin.media.galleries.variants.update', ['variant' => 'lunch-box:green']), [
                'expected_fingerprint' => $empty,
                'media_ids' => [$draft->id],
            ])
            ->assertRedirect(route('admin.media.galleries.index'))
            ->assertSessionHasErrors('media_ids');
        $this->assertSame(0, VariantMediaGalleryItem::query()->count());
    }

    private function admittedAsset(
        string $label,
        MediaAssetPurpose $purpose = MediaAssetPurpose::Product,
    ): MediaAsset {
        $asset = $this->draftAssetWithCanonical($label, $purpose);

        return app(MediaLibraryService::class)->admit($asset, $this->actor);
    }

    private function draftAssetWithCanonical(
        string $label,
        MediaAssetPurpose $purpose = MediaAssetPurpose::Product,
    ): MediaAsset {
        $this->counter++;
        $counter = $this->counter;
        $library = app(MediaLibraryService::class);
        $asset = $library->registerSource([
            'purpose' => $purpose,
            'source_reference' => "cms-032-admin-$counter",
            'original_filename' => "admin-source-$counter.png",
            'original_mime' => 'image/png',
            'original_bytes' => 3000 + $counter,
            'original_width' => 1600,
            'original_height' => 1600,
            'original_sha256' => hash('sha256', "admin-source-$counter"),
            'semantic_label' => $label,
        ], $this->actor);
        $library->attachDerivative($asset, [
            'kind' => MediaDerivativeKind::Canonical,
            'storage_disk' => 'media-test',
            'storage_path' => "admin-canonical/$counter.png",
            'mime' => 'image/png',
            'bytes' => 2000 + $counter,
            'width' => 1200,
            'height' => 1200,
            'sha256' => hash('sha256', "admin-derivative-$counter"),
        ], $this->actor);

        return $asset->refresh();
    }
}
