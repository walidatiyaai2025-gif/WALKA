<?php

namespace Tests\Feature;

use App\Models\CatalogCategory;
use App\Models\Product;
use App\Models\ProductVariant;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class DynamicCatalogDashboardTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        config()->set('walka.dashboard_username', 'admin');
        config()->set('walka.dashboard_password', 'Walka-Admin-Test-Password-2026');
        $this->seed(WalkaCatalogSeeder::class);
    }

    public function test_dashboard_created_category_product_and_color_flow_to_public_api(): void
    {
        $session = [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_actor' => hash('sha256', 'dynamic-catalog-test'),
        ];

        $this->withSession($session)
            ->post(route('admin.catalog.categories.store'), [
                'id' => 'travel-gear',
                'name' => 'Travel Gear',
                'sort_order' => 7,
                'is_visible' => '1',
            ])
            ->assertRedirect(route('admin.catalog'));

        $this->withSession($session)
            ->post(route('admin.catalog.products.store'), [
                'id' => 'travel-mug',
                'name' => 'WALKA Travel Mug',
                'category_id' => 'travel-gear',
                'features_text' => "Dashboard created\nInsulated",
                'facts_json' => '{"capacity_ml":500}',
                'sort_order' => 3,
                'is_visible' => '1',
            ])
            ->assertRedirect(route('admin.catalog'));

        $this->withSession($session)
            ->post(route('admin.catalog.variants.store', ['product' => 'travel-mug']), [
                'variant_key' => 'sand',
                'color' => 'Sand',
                'swatch_hex' => '#C9B79C',
                'pantone' => 'PANTONE DYNAMIC U',
                'asin' => 'B012345670',
                'sort_order' => 0,
                'is_visible' => '1',
            ])
            ->assertRedirect(route('admin.catalog'));

        $this->assertDatabaseHas('catalog_categories', [
            'id' => 'travel-gear',
            'name' => 'Travel Gear',
            'is_visible' => true,
        ]);
        $this->assertDatabaseHas('products', [
            'id' => 'travel-mug',
            'category_id' => 'travel-gear',
            'is_visible' => true,
        ]);
        $this->assertDatabaseHas('product_variants', [
            'id' => 'travel-mug:sand',
            'color' => 'Sand',
            'swatch_hex' => '#C9B79C',
            'asin' => 'B012345670',
            'is_visible' => true,
        ]);

        $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonFragment([
                'id' => 'travel-gear',
                'name' => 'Travel Gear',
                'sort_order' => 7,
            ])
            ->assertJsonFragment([
                'id' => 'travel-mug',
                'name' => 'WALKA Travel Mug',
                'category' => 'travel-gear',
            ])
            ->assertJsonFragment([
                'id' => 'travel-mug:sand',
                'color' => 'Sand',
                'swatch_hex' => '#C9B79C',
                'pantone' => 'PANTONE DYNAMIC U',
                'asin' => 'B012345670',
                'purchase_url' => 'https://www.amazon.com/dp/B012345670',
            ]);
    }

    public function test_hiding_or_deleting_dashboard_entities_cannot_be_resurrected_by_public_api(): void
    {
        $this->createDynamicProduct();
        $session = ['walka_admin_dashboard_authenticated' => true];

        $variant = ProductVariant::query()->findOrFail('travel-mug:sand');
        $this->withSession($session)
            ->patch(route('admin.catalog.variants.update', ['variant' => $variant->id]), [
                'revision' => $variant->revision,
                'color' => $variant->color,
                'swatch_hex' => $variant->swatch_hex,
                'pantone' => $variant->pantone,
                'asin' => $variant->asin,
                'sort_order' => $variant->sort_order,
            ])
            ->assertRedirect(route('admin.catalog'));

        $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonMissing(['id' => 'travel-mug'])
            ->assertJsonMissing(['id' => 'travel-mug:sand']);

        $variant->refresh();
        $this->withSession($session)
            ->patch(route('admin.catalog.variants.update', ['variant' => $variant->id]), [
                'revision' => $variant->revision,
                'color' => $variant->color,
                'swatch_hex' => $variant->swatch_hex,
                'pantone' => $variant->pantone,
                'asin' => $variant->asin,
                'sort_order' => $variant->sort_order,
                'is_visible' => '1',
            ])
            ->assertRedirect(route('admin.catalog'));

        $category = CatalogCategory::query()->findOrFail('travel-gear');
        $this->withSession($session)
            ->patch(route('admin.catalog.categories.update', ['category' => $category->id]), [
                'revision' => $category->revision,
                'name' => 'Travel Gear Renamed',
                'sort_order' => $category->sort_order,
            ])
            ->assertRedirect(route('admin.catalog'));

        $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonMissing(['id' => 'travel-mug'])
            ->assertJsonMissing(['id' => 'travel-gear']);
    }

    public function test_bootstrap_seeder_does_not_overwrite_or_delete_dashboard_catalog_changes(): void
    {
        $this->createDynamicProduct();

        $drawer = Product::query()->findOrFail('drawer-organizer');
        $drawer->name = 'Dashboard Renamed Drawer';
        $drawer->save();

        $this->seed(WalkaCatalogSeeder::class);

        $this->assertDatabaseHas('products', [
            'id' => 'drawer-organizer',
            'name' => 'Dashboard Renamed Drawer',
        ]);
        $this->assertDatabaseHas('products', [
            'id' => 'travel-mug',
            'name' => 'WALKA Travel Mug',
        ]);
        $this->assertDatabaseHas('product_variants', [
            'id' => 'travel-mug:sand',
            'asin' => 'B012345670',
        ]);
    }

    public function test_dashboard_can_delete_dynamic_variant_product_and_empty_category(): void
    {
        $this->createDynamicProduct();
        $session = ['walka_admin_dashboard_authenticated' => true];

        $variant = ProductVariant::query()->findOrFail('travel-mug:sand');
        $this->withSession($session)
            ->delete(route('admin.catalog.variants.destroy', ['variant' => $variant->id]), [
                'revision' => $variant->revision,
            ])
            ->assertRedirect(route('admin.catalog'));

        $product = Product::query()->findOrFail('travel-mug');
        $this->withSession($session)
            ->delete(route('admin.catalog.products.destroy', ['product' => $product->id]), [
                'revision' => $product->revision,
            ])
            ->assertRedirect(route('admin.catalog'));

        $category = CatalogCategory::query()->findOrFail('travel-gear');
        $this->withSession($session)
            ->delete(route('admin.catalog.categories.destroy', ['category' => $category->id]), [
                'revision' => $category->revision,
            ])
            ->assertRedirect(route('admin.catalog'));

        $this->assertDatabaseMissing('product_variants', ['id' => 'travel-mug:sand']);
        $this->assertDatabaseMissing('products', ['id' => 'travel-mug']);
        $this->assertDatabaseMissing('catalog_categories', ['id' => 'travel-gear']);
    }

    private function createDynamicProduct(): void
    {
        CatalogCategory::query()->create([
            'id' => 'travel-gear',
            'name' => 'Travel Gear',
            'is_visible' => true,
            'sort_order' => 7,
            'revision' => 1,
        ]);
        Product::query()->create([
            'id' => 'travel-mug',
            'name' => 'WALKA Travel Mug',
            'category' => 'travel-gear',
            'category_id' => 'travel-gear',
            'features' => ['Dashboard created'],
            'facts' => ['capacity_ml' => 500],
            'sort_order' => 3,
            'is_visible' => true,
            'revision' => 1,
        ]);
        ProductVariant::query()->create([
            'id' => 'travel-mug:sand',
            'product_id' => 'travel-mug',
            'color' => 'Sand',
            'swatch_hex' => '#C9B79C',
            'pantone' => 'PANTONE DYNAMIC U',
            'asin' => 'B012345670',
            'sort_order' => 0,
            'is_visible' => true,
            'revision' => 1,
        ]);
    }
}
