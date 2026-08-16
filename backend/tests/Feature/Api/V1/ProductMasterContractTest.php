<?php

namespace Tests\Feature\Api\V1;

use App\Models\CatalogCategory;
use App\Models\Product;
use App\Models\ProductVariant;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class ProductMasterContractTest extends TestCase
{
    use RefreshDatabase;

    public function test_repository_product_master_remains_a_verified_bootstrap_reference(): void
    {
        $masterPath = base_path('../docs/PRODUCT_MASTER.md');

        $this->assertFileExists($masterPath);

        $master = file_get_contents($masterPath);
        $this->assertIsString($master);

        foreach ([
            'Do not publish a product weight or packaging dimensions unless a verified product-owner value is added to this document.',
            'Outer body: food-grade PP',
            'stainless sauce cup with lid',
            'SUS304 stainless tray: dishwasher safe; not microwave safe.',
            'PANTONE 4155 U',
            'PANTONE 9242 U',
            'PANTONE 6198 U',
        ] as $requiredFact) {
            $this->assertStringContainsString($requiredFact, $master);
        }

        $this->seed(WalkaCatalogSeeder::class);

        $drawer = Product::query()->with('variants')->findOrFail('drawer-organizer');
        $lunch = Product::query()->with('variants')->findOrFail('stainless-steel-bento-lunch-box');

        $this->assertArrayNotHasKey('product_weight_lb', $drawer->facts);
        $this->assertArrayNotHasKey('packaging_in', $drawer->facts);
        $this->assertSame('Food-grade PP', $lunch->facts['outer_body']);
        $this->assertSame(
            ['PANTONE 4155 U', 'PANTONE 9242 U', 'PANTONE 6198 U'],
            $lunch->variants->pluck('pantone')->all(),
        );
    }

    public function test_product_master_does_not_limit_runtime_database_membership_or_authoring(): void
    {
        $this->seed(WalkaCatalogSeeder::class);

        CatalogCategory::query()->create([
            'id' => 'dashboard-category',
            'name' => 'Dashboard Category',
            'is_visible' => true,
            'sort_order' => 90,
            'revision' => 1,
        ]);
        Product::query()->create([
            'id' => 'dashboard-product',
            'name' => 'Dashboard Product',
            'category' => 'dashboard-category',
            'category_id' => 'dashboard-category',
            'features' => ['Created outside the bootstrap master'],
            'facts' => ['dashboard_owned' => true],
            'sort_order' => 0,
            'is_visible' => true,
            'revision' => 1,
        ]);
        ProductVariant::query()->create([
            'id' => 'dashboard-product:custom',
            'product_id' => 'dashboard-product',
            'color' => 'Custom',
            'swatch_hex' => '#123456',
            'pantone' => 'OWNER MANAGED',
            'asin' => 'B012345675',
            'sort_order' => 0,
            'is_visible' => true,
            'revision' => 1,
        ]);

        $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonFragment([
                'id' => 'dashboard-product',
                'name' => 'Dashboard Product',
                'category' => 'dashboard-category',
            ])
            ->assertJsonFragment([
                'id' => 'dashboard-product:custom',
                'color' => 'Custom',
                'swatch_hex' => '#123456',
                'pantone' => 'OWNER MANAGED',
                'asin' => 'B012345675',
            ]);
    }
}
