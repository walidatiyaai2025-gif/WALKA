<?php

namespace Tests\Feature\Api\V1;

use App\Models\CatalogCategory;
use App\Models\Product;
use App\Models\ProductVariant;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class CatalogPersistenceTest extends TestCase
{
    use RefreshDatabase;

    public function test_bootstrap_seeder_is_idempotent_without_overwriting_database_catalog(): void
    {
        $this->seed(WalkaCatalogSeeder::class);

        Product::query()->whereKey('drawer-organizer')->update([
            'name' => 'Dashboard Drawer Name',
        ]);
        ProductVariant::query()->whereKey('lunch-box:green')->update([
            'color' => 'Dashboard Green',
        ]);

        $this->seed(WalkaCatalogSeeder::class);

        $this->assertSame(2, Product::query()->count());
        $this->assertSame(5, ProductVariant::query()->count());
        $this->assertSame('Dashboard Drawer Name', Product::query()->findOrFail('drawer-organizer')->name);
        $this->assertSame('Dashboard Green', ProductVariant::query()->findOrFail('lunch-box:green')->color);
    }

    public function test_unseeded_catalog_fails_safely_and_observably(): void
    {
        $this->getJson('/api/v1/catalog')
            ->assertStatus(503)
            ->assertExactJson([
                'error' => [
                    'code' => 'catalog_unavailable',
                    'message' => 'No visible WALKA catalog is currently available.',
                ],
            ]);
    }

    public function test_catalog_runtime_reads_database_not_seed_blueprint(): void
    {
        $this->seed(WalkaCatalogSeeder::class);

        Product::query()->whereKey('drawer-organizer')->update([
            'name' => 'Database-backed Drawer Organizer',
        ]);

        $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonFragment([
                'id' => 'drawer-organizer',
                'name' => 'Database-backed Drawer Organizer',
            ]);
    }

    public function test_new_database_entities_are_served_without_any_seed_blueprint_entry(): void
    {
        $this->seed(WalkaCatalogSeeder::class);

        CatalogCategory::query()->create([
            'id' => 'dashboard-only',
            'name' => 'Dashboard Only',
            'is_visible' => true,
            'sort_order' => 50,
            'revision' => 1,
        ]);
        Product::query()->create([
            'id' => 'dashboard-only-product',
            'name' => 'Dashboard Only Product',
            'category' => 'dashboard-only',
            'category_id' => 'dashboard-only',
            'features' => ['Not present in seed blueprint'],
            'facts' => ['dynamic' => true],
            'sort_order' => 0,
            'is_visible' => true,
            'revision' => 1,
        ]);
        ProductVariant::query()->create([
            'id' => 'dashboard-only-product:violet',
            'product_id' => 'dashboard-only-product',
            'color' => 'Violet',
            'swatch_hex' => '#7755AA',
            'pantone' => null,
            'asin' => 'B012345674',
            'sort_order' => 0,
            'is_visible' => true,
            'revision' => 1,
        ]);

        $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonFragment([
                'id' => 'dashboard-only',
                'name' => 'Dashboard Only',
                'sort_order' => 50,
            ])
            ->assertJsonFragment([
                'id' => 'dashboard-only-product',
                'name' => 'Dashboard Only Product',
                'category' => 'dashboard-only',
            ])
            ->assertJsonFragment([
                'id' => 'dashboard-only-product:violet',
                'color' => 'Violet',
                'swatch_hex' => '#7755AA',
                'asin' => 'B012345674',
            ]);
    }
}
