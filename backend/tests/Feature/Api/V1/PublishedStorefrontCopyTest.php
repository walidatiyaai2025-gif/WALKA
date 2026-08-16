<?php

namespace Tests\Feature\Api\V1;

use App\Services\Content\StorefrontCopyContentDefinition;
use App\Services\ContentRevisionService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class PublishedStorefrontCopyTest extends TestCase
{
    use RefreshDatabase;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->actor = hash('sha256', 'storefront-copy-public-test');
    }

    public function test_storefront_copy_is_private_until_explicit_publish(): void
    {
        $this->getJson('/api/v1/content/storefront')
            ->assertNotFound()
            ->assertJsonPath('error.code', 'content_not_published');

        $this->service()->saveDraft(
            StorefrontCopyContentDefinition::KEY,
            StorefrontCopyContentDefinition::TYPE,
            StorefrontCopyContentDefinition::defaultPayload(),
            0,
            $this->actor,
        );

        $this->getJson('/api/v1/content/storefront')->assertNotFound();
    }

    public function test_published_storefront_copy_is_versioned_and_allowlisted(): void
    {
        $payload = StorefrontCopyContentDefinition::defaultPayload();
        $payload['categories_heading'] = 'Shop by collection';
        $payload['pdp_buy_label'] = 'Continue to Amazon';
        $payload['internal_note'] = 'never-public';
        $payload['target_url'] = 'https://example.invalid';

        $service = $this->service();
        $service->saveDraft(
            StorefrontCopyContentDefinition::KEY,
            StorefrontCopyContentDefinition::TYPE,
            $payload,
            0,
            $this->actor,
        );
        $service->publish(StorefrontCopyContentDefinition::KEY, 1, $this->actor);

        $response = $this->getJson('/api/v1/content/storefront')
            ->assertOk()
            ->assertJsonPath('data.key', 'storefront.copy')
            ->assertJsonPath('data.type', 'storefront.copy')
            ->assertJsonPath('data.schema_version', 1)
            ->assertJsonPath('data.revision', 2)
            ->assertJsonPath('data.payload.categories_heading', 'Shop by collection')
            ->assertJsonPath('data.payload.favorites_heading', 'Favorites')
            ->assertJsonPath('data.payload.favorites_remove_label', 'Remove')
            ->assertJsonPath('data.payload.pdp_buy_label', 'Continue to Amazon')
            ->assertJsonPath('data.payload.pdp_favorite_add_label', 'Save favorite')
            ->assertJsonPath('data.payload.pdp_favorite_remove_label', 'Remove favorite');

        $publicPayload = $response->json('data.payload');
        $this->assertIsArray($publicPayload);
        $this->assertSame(
            array_keys(StorefrontCopyContentDefinition::defaultPayload()),
            array_keys($publicPayload),
            'Public Storefront copy must expose exactly the typed allowlist.',
        );

        $raw = $response->getContent();
        $this->assertStringNotContainsString('internal_note', $raw);
        $this->assertStringNotContainsString('never-public', $raw);
        $this->assertStringNotContainsString('target_url', $raw);
        $this->assertStringNotContainsString('example.invalid', $raw);
        $this->assertSame('"walka-storefront-copy-r2"', $response->headers->get('ETag'));

        $this->withHeader('If-None-Match', '"walka-storefront-copy-r2"')
            ->get('/api/v1/content/storefront')
            ->assertStatus(304);
    }

    private function service(): ContentRevisionService
    {
        return app(ContentRevisionService::class);
    }
}
