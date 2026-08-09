<?php

namespace Tests\Feature\Api\V1;

use Tests\TestCase;

final class HealthTest extends TestCase
{
    public function test_health_contract_is_stable(): void
    {
        $this->getJson('/api/v1/health')
            ->assertOk()
            ->assertJsonPath('data.status', 'ok')
            ->assertJsonPath('data.service', 'walka-api')
            ->assertJsonPath('data.release', '1.4.0')
            ->assertJsonPath('data.api_version', 'v1');
    }
}
