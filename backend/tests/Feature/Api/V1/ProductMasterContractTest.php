<?php

namespace Tests\Feature\Api\V1;

use Tests\TestCase;

final class ProductMasterContractTest extends TestCase
{
    public function test_api_catalog_is_bound_to_the_verified_repository_product_master(): void
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

        $products = config('walka.products');

        $this->assertArrayNotHasKey('product_weight_lb', $products[0]['facts']);
        $this->assertArrayNotHasKey('packaging_in', $products[0]['facts']);
        $this->assertSame('Food-grade PP', $products[1]['facts']['outer_body']);
        $this->assertSame(
            'Dishwasher safe; not microwave safe.',
            $products[1]['facts']['care']['sus304_tray'],
        );
        $this->assertSame(
            'Dishwasher safe on the top rack; not microwave safe.',
            $products[1]['facts']['care']['lid_and_gasket'],
        );
        $this->assertSame(
            'Microwave safe only after removing the stainless tray, lid, and silicone gasket.',
            $products[1]['facts']['care']['pp_outer_body'],
        );
        $this->assertSame([
            'Secure Lock | Helps Prevent Spills',
            'SPILL-RESISTANT DESIGN',
            'Best suited for dry meals & snacks.',
            'Not intended for liquids. Best for dry & semi-wet foods.',
            'Carry upright.',
        ], $products[1]['facts']['usage_language']);
        $this->assertSame('PANTONE 4155 U', $products[1]['variants'][0]['pantone']);
        $this->assertSame('PANTONE 9242 U', $products[1]['variants'][1]['pantone']);
        $this->assertSame('PANTONE 6198 U', $products[1]['variants'][2]['pantone']);
    }
}
