<?php

namespace Tests\Feature\Api\V1;

use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class CatalogAdminAuthTest extends TestCase
{
    use RefreshDatabase;

    private const TOKEN = 'walka-test-admin-token-0123456789abcdef';

    public function test_admin_api_fails_closed_when_token_is_not_configured_or_is_weak(): void
    {
        config()->set('walka.admin_token', null);

        $this->getJson('/api/v1/admin/catalog')
            ->assertStatus(503)
            ->assertJsonPath('error.code', 'admin_auth_unconfigured')
            ->assertHeader('Cache-Control', 'no-store, private');

        config()->set('walka.admin_token', 'too-short');

        $this->getJson('/api/v1/admin/catalog')
            ->assertStatus(503)
            ->assertJsonPath('error.code', 'admin_auth_unconfigured');
    }

    public function test_admin_api_rejects_missing_and_invalid_bearer_tokens(): void
    {
        config()->set('walka.admin_token', self::TOKEN);

        $this->getJson('/api/v1/admin/catalog')
            ->assertUnauthorized()
            ->assertJsonPath('error.code', 'admin_unauthorized')
            ->assertHeader('WWW-Authenticate', 'Bearer');

        $this->withToken('definitely-not-the-admin-token')
            ->getJson('/api/v1/admin/catalog')
            ->assertUnauthorized()
            ->assertJsonPath('error.code', 'admin_unauthorized');
    }

    public function test_valid_admin_token_can_read_seeded_catalog_revision_metadata(): void
    {
        config()->set('walka.admin_token', self::TOKEN);
        $this->seed(WalkaCatalogSeeder::class);

        $this->withToken(self::TOKEN)
            ->getJson('/api/v1/admin/catalog')
            ->assertOk()
            ->assertHeader('Cache-Control', 'no-store, private')
            ->assertJsonPath('data.0.id', 'drawer-organizer')
            ->assertJsonPath('data.0.revision', 1)
            ->assertJsonPath('data.0.variants.0.revision', 1)
            ->assertJsonPath('meta.authoring.product_fields.0', 'name');
    }
}
