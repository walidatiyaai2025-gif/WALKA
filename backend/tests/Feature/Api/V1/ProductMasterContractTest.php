<?php

namespace Tests\Feature\Api\V1;

use App\Models\Product;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class ProductMasterContractTest extends TestCase
{
    use RefreshDatabase;

    public function test_database_catalog_is_bound_to_the_verified_repository_product_master(): void
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
            'Lid and silicone gasket: dishwasher safe on the top rack; not microwave safe.',
            'PP outer body: microwave safe only after removing the stainless tray, lid, and silicone gasket.',
            'Secure Lock | Helps Prevent Spills',
            'SPILL-RESISTANT DESIGN',
            'Best suited for dry meals & snacks.',
            'Not intended for liquids. Best for dry & semi-wet foods.',
            'Carry upright.',
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
            'Dishwasher safe; not microwave safe.',
            $lunch->facts['care']['sus304_tray'],
        );
        $this->assertSame(
            'Dishwasher safe on the top rack; not microwave safe.',
            $lunch->facts['care']['lid_and_gasket'],
        );
        $this->assertSame(
            'Microwave safe only after removing the stainless tray, lid, and silicone gasket.',
            $lunch->facts['care']['pp_outer_body'],
        );
        $this->assertSame([
            'Secure Lock | Helps Prevent Spills',
            'SPILL-RESISTANT DESIGN',
            'Best suited for dry meals & snacks.',
            'Not intended for liquids. Best for dry & semi-wet foods.',
            'Carry upright.',
        ], $lunch->facts['usage_language']);
        $this->assertSame(
            ['PANTONE 4155 U', 'PANTONE 9242 U', 'PANTONE 6198 U'],
            $lunch->variants->pluck('pantone')->all(),
        );
    }
}
