<?php

namespace Tests\Feature\Api\V1;

use Tests\TestCase;

final class CatalogTest extends TestCase
{
    public function test_catalog_exposes_stable_products_product_master_facts_and_amazon_destinations(): void
    {
        $response = $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonPath('meta.release', '1.1.0')
            ->assertJsonPath('meta.api_version', 'v1')
            ->assertJsonPath('meta.purchase_mode', 'amazon_redirect')
            ->assertJsonCount(2, 'data');

        $response
            ->assertJsonPath('data.0.id', 'drawer-organizer')
            ->assertJsonPath('data.0.facts.material', 'Plastic')
            ->assertJsonPath('data.0.facts.compartments', 8)
            ->assertJsonPath('data.0.facts.expandable_width_in', 22.4)
            ->assertJsonMissingPath('data.0.facts.product_weight_lb')
            ->assertJsonMissingPath('data.0.facts.packaging_in')
            ->assertJsonPath('data.0.variants.0.id', 'drawer-organizer:white')
            ->assertJsonPath('data.0.variants.0.asin', 'B0FQN4DCTG')
            ->assertJsonPath('data.0.variants.0.purchase_url', 'https://www.amazon.com/dp/B0FQN4DCTG')
            ->assertJsonPath('data.0.variants.1.id', 'drawer-organizer:gray')
            ->assertJsonPath('data.0.variants.1.asin', 'B0FQN4L2ZD')
            ->assertJsonPath('data.0.variants.1.purchase_url', 'https://www.amazon.com/dp/B0FQN4L2ZD')
            ->assertJsonPath('data.1.id', 'stainless-steel-bento-lunch-box')
            ->assertJsonPath('data.1.facts.capacity_ml', 1200)
            ->assertJsonPath('data.1.facts.food_tray', 'SUS304 stainless steel')
            ->assertJsonPath('data.1.facts.compartments', 4)
            ->assertJsonPath('data.1.facts.outer_body', 'Food-grade PP')
            ->assertJsonPath('data.1.facts.lid', '4 clips with silicone gasket')
            ->assertJsonPath('data.1.facts.weight_with_bag_lb', 1.84)
            ->assertJsonPath(
                'data.1.facts.care.lid_and_gasket',
                'Dishwasher safe on the top rack; not microwave safe.',
            )
            ->assertJsonPath(
                'data.1.facts.care.pp_outer_body',
                'Microwave safe only after removing the stainless tray, lid, and silicone gasket.',
            )
            ->assertJsonPath(
                'data.1.facts.usage_language.0',
                'Secure Lock | Helps Prevent Spills',
            )
            ->assertJsonPath('data.1.facts.usage_language.1', 'SPILL-RESISTANT DESIGN')
            ->assertJsonPath(
                'data.1.facts.usage_language.3',
                'Not intended for liquids. Best for dry & semi-wet foods.',
            )
            ->assertJsonPath('data.1.facts.usage_language.4', 'Carry upright.')
            ->assertJsonCount(3, 'data.1.variants')
            ->assertJsonPath('data.1.variants.0.pantone', 'PANTONE 4155 U')
            ->assertJsonPath('data.1.variants.0.purchase_url', 'https://www.amazon.com/dp/B0FQN4L8MW')
            ->assertJsonPath('data.1.variants.1.pantone', 'PANTONE 9242 U')
            ->assertJsonPath('data.1.variants.1.purchase_url', 'https://www.amazon.com/dp/B0FQN3W4SF')
            ->assertJsonPath('data.1.variants.2.pantone', 'PANTONE 6198 U')
            ->assertJsonPath('data.1.variants.2.purchase_url', 'https://www.amazon.com/dp/B0GPZNKF9F');
    }
}
