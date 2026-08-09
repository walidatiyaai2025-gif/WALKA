<?php

namespace Tests\Feature\Api\V1;

use Tests\TestCase;

final class ConfigTest extends TestCase
{
    public function test_mobile_safe_config_contract(): void
    {
        $this->getJson('/api/v1/config')
            ->assertOk()
            ->assertJson([
                'data' => [
                    'brand' => 'WALKA',
                    'release' => '1.1.0',
                    'api_version' => 'v1',
                    'purchase_mode' => 'amazon_redirect',
                ],
            ]);
    }
}
