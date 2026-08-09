<?php

namespace Tests\Feature\Api\V1;

use Tests\TestCase;

final class CatalogTest extends TestCase
{
    public function test_catalog_exposes_stable_products_and_amazon_destinations(): void
    {
        $response = $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonPath('meta.api_version', 'v1')
            ->assertJsonPath('meta.purchase_mode', 'amazon_redirect')
            ->assertJsonCount(2, 'data');

        $response
            ->assertJsonPath('data.0.id', 'drawer-organizer')
            ->assertJsonPath('data.0.variants.0.id', 'drawer-organizer:white')
            ->assertJsonPath('data.0.variants.0.asin', 'B0FQN4DCTG')
            ->assertJsonPath('data.0.variants.0.purchase_url', 'https://www.amazon.com/dp/B0FQN4DCTG')
            ->assertJsonPath('data.0.variants.1.id', 'drawer-organizer:gray')
            ->assertJsonPath('data.0.variants.1.asin', 'B0FQN4L2ZD')
            ->assertJsonPath('data.0.variants.1.purchase_url', 'https://www.amazon.com/dp/B0FQN4L2ZD')
            ->assertJsonPath('data.1.id', 'stainless-steel-bento-lunch-box')
            ->assertJsonCount(3, 'data.1.variants')
            ->assertJsonPath('data.1.variants.0.purchase_url', 'https://www.amazon.com/dp/B0FQN4L8MW')
            ->assertJsonPath('data.1.variants.1.purchase_url', 'https://www.amazon.com/dp/B0FQN3W4SF')
            ->assertJsonPath('data.1.variants.2.purchase_url', 'https://www.amazon.com/dp/B0GPZNKF9F');
    }
}
