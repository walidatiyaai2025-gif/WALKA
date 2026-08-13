<?php

namespace Tests\Feature;

use App\Models\CatalogAudit;
use App\Models\ProductVariant;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AdminVariantPresentationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        config()->set('walka_dashboard.role', 'owner');
    }

    /** @return array<string, mixed> */
    private function dashboardSession(): array
    {
        return [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_username' => 'admin',
            'walka_admin_dashboard_actor' => hash('sha256', 'cms-011-dashboard-test'),
        ];
    }

    public function test_catalog_page_exposes_variant_visibility_order_and_locked_identity(): void
    {
        $this->withSession($this->dashboardSession())
            ->get('/admin/catalog')
            ->assertOk()
            ->assertSee('Customer-facing variant presentation')
            ->assertSee('Presentation order')
            ->assertSee('Internal order')
            ->assertSee('Locked Pantone')
            ->assertSee('Locked ASIN')
            ->assertSee('Save presentation');
    }

    public function test_owner_can_hide_variant_and_public_catalog_stops_exposing_it(): void
    {
        $variant = ProductVariant::query()->findOrFail('lunch-box:pink');
        $protectedAsin = $variant->asin;
        $protectedPantone = $variant->pantone;
        $protectedProduct = $variant->product_id;
        $protectedSort = $variant->sort_order;

        $this->withSession($this->dashboardSession())
            ->patch('/admin/catalog/variants/lunch-box:pink', [
                'revision' => $variant->revision,
                'color' => $variant->color,
                'presentation_controls' => '1',
                'presentation_order' => '12',
            ])
            ->assertRedirect(route('admin.catalog'));

        $variant->refresh();
        $this->assertFalse((bool) $variant->getAttribute('is_visible'));
        $this->assertSame(12, (int) $variant->getAttribute('presentation_order'));
        $this->assertSame($protectedAsin, $variant->asin);
        $this->assertSame($protectedPantone, $variant->pantone);
        $this->assertSame($protectedProduct, $variant->product_id);
        $this->assertSame($protectedSort, $variant->sort_order);
        $this->assertSame(2, $variant->revision);
        $this->assertSame(1, CatalogAudit::query()->count());

        $response = $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonCount(2, 'data.1.variants');

        $this->assertNotContains(
            'lunch-box:pink',
            collect($response->json('data.1.variants'))->pluck('id')->all(),
        );
    }

    public function test_dashboard_rejects_hiding_final_visible_variant(): void
    {
        ProductVariant::query()
            ->whereKey('drawer-organizer:gray')
            ->update(['is_visible' => false]);
        $white = ProductVariant::query()->findOrFail('drawer-organizer:white');

        $this->withSession($this->dashboardSession())
            ->patch('/admin/catalog/variants/drawer-organizer:white', [
                'revision' => $white->revision,
                'color' => $white->color,
                'presentation_controls' => '1',
                'presentation_order' => '0',
            ])
            ->assertRedirect(route('admin.catalog'))
            ->assertSessionHasErrors('is_visible');

        $white->refresh();
        $this->assertTrue((bool) $white->getAttribute('is_visible'));
        $this->assertSame(1, $white->revision);
        $this->assertDatabaseCount('catalog_audits', 0);
    }
}
