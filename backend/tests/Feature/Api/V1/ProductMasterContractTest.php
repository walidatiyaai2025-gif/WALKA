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
            'Product weight: 1.72 lb',
            'Packaging: 13.46 × 15.16 × 2.36 in',
            'Outer body: BPA-free PP',
            'stainless sauce cup with lid',
            'Lid and silicone gasket: hand wash',
            'dishwasher safe on the top rack',
            'PP outer body: microwave safe without the stainless steel tray',
            'Secure Lock | Helps Prevent Spills',
            'Best for dry & semi-wet foods',
            'Not intended for liquids',
            'Carry upright',
            'PANTONE 4155 U',
            'PANTONE 9242 U',
            'PANTONE 6198 U',
        ] as $requiredFact) {
            $this->assertStringContainsString($requiredFact, $master);
        }

        $products = config('walka.products');

        $this->assertSame(1.72, $products[0]['facts']['product_weight_lb']);
        $this->assertSame([13.46, 15.16, 2.36], $products[0]['facts']['packaging_in']);
        $this->assertSame('BPA-free PP', $products[1]['facts']['outer_body']);
        $this->assertSame('Hand wash.', $products[1]['facts']['care']['lid_and_gasket']);
        $this->assertSame(
            'Microwave safe without the stainless steel tray.',
            $products[1]['facts']['care']['pp_outer_body'],
        );
        $this->assertContains(
            'Secure Lock | Helps Prevent Spills',
            $products[1]['facts']['usage_language'],
        );
        $this->assertContains(
            'Not intended for liquids',
            $products[1]['facts']['usage_language'],
        );
        $this->assertSame('PANTONE 4155 U', $products[1]['variants'][0]['pantone']);
        $this->assertSame('PANTONE 9242 U', $products[1]['variants'][1]['pantone']);
        $this->assertSame('PANTONE 6198 U', $products[1]['variants'][2]['pantone']);
    }
}
