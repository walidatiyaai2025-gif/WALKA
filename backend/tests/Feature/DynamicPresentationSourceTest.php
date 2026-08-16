<?php

namespace Tests\Feature;

use App\Models\CatalogCategory;
use App\Models\Product;
use App\Models\ProductVariant;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class DynamicPresentationSourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
    }

    public function test_new_dashboard_catalog_entities_appear_in_media_contract_without_code_allowlist(): void
    {
        CatalogCategory::query()->create([
            'id' => 'travel',
            'name' => 'Travel',
            'is_visible' => true,
            'sort_order' => 90,
            'revision' => 1,
        ]);
        Product::query()->create([
            'id' => 'travel-mug',
            'name' => 'Travel Mug',
            'category' => 'travel',
            'category_id' => 'travel',
            'features' => ['Insulated'],
            'facts' => ['capacity_ml' => 500],
            'sort_order' => 90,
            'is_visible' => true,
            'revision' => 1,
        ]);
        ProductVariant::query()->create([
            'id' => 'travel-mug:sand',
            'product_id' => 'travel-mug',
            'color' => 'Sand',
            'swatch_hex' => '#C9B79C',
            'pantone' => null,
            'asin' => 'B012345673',
            'sort_order' => 0,
            'is_visible' => true,
            'revision' => 1,
        ]);

        $products = $this->getJson('/api/v1/media/product-galleries')
            ->assertOk()
            ->json('data.products');
        $travel = collect($products)->firstWhere('product_id', 'travel-mug');
        $this->assertNotNull($travel);
        $this->assertSame('travel-mug:sand', $travel['variants'][0]['variant_id']);

        $slots = $this->getJson('/api/v1/media/surfaces')
            ->assertOk()
            ->json('data.slots');
        $travelSlot = collect($slots)->firstWhere('slot_key', 'category:travel');
        $this->assertNotNull($travelSlot);
        $this->assertSame('category', $travelSlot['purpose']);
        $this->assertSame('travel', $travelSlot['category_id']);
    }

    public function test_hidden_dashboard_entities_are_not_published_by_product_media(): void
    {
        ProductVariant::query()->whereKey('lunch-box:pink')->update(['is_visible' => false]);
        Product::query()->whereKey('drawer-organizer')->update(['is_visible' => false]);

        $products = $this->getJson('/api/v1/media/product-galleries')
            ->assertOk()
            ->json('data.products');

        $this->assertNull(collect($products)->firstWhere('product_id', 'drawer-organizer'));
        $lunch = collect($products)->firstWhere('product_id', 'stainless-steel-bento-lunch-box');
        $this->assertNotNull($lunch);
        $this->assertNotContains(
            'lunch-box:pink',
            collect($lunch['variants'])->pluck('variant_id')->all(),
        );
    }
}
