<?php

namespace Tests\Feature\Api\V1;

use App\Services\Content\HomeFeaturedContentDefinition;
use App\Services\ContentRevisionService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class PublishedHomeFeaturedTest extends TestCase
{
    use RefreshDatabase;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        $this->actor = hash('sha256', 'cms-022-public-test');
    }

    public function test_featured_content_is_private_until_published(): void
    {
        $this->getJson('/api/v1/content/home-featured')
            ->assertNotFound()
            ->assertJsonPath('error.code', 'content_not_published');

        $this->service()->saveDraft(
            HomeFeaturedContentDefinition::KEY,
            HomeFeaturedContentDefinition::TYPE,
            HomeFeaturedContentDefinition::defaultPayload(),
            0,
            $this->actor,
        );

        $this->getJson('/api/v1/content/home-featured')->assertNotFound();
    }

    public function test_public_featured_payload_is_versioned_and_cacheable(): void
    {
        $service = $this->service();
        $service->saveDraft(
            HomeFeaturedContentDefinition::KEY,
            HomeFeaturedContentDefinition::TYPE,
            HomeFeaturedContentDefinition::defaultPayload(),
            0,
            $this->actor,
        );
        $service->publish(HomeFeaturedContentDefinition::KEY, 1, $this->actor);

        $response = $this->getJson('/api/v1/content/home-featured')
            ->assertOk()
            ->assertJsonPath('data.key', 'home.featured')
            ->assertJsonPath('data.type', 'home.featured')
            ->assertJsonPath('data.schema_version', 1)
            ->assertJsonPath('data.revision', 2)
            ->assertJsonPath('data.payload.collection_variant_ids.0', 'lunch-box:blue')
            ->assertJsonPath('data.payload.editorial_variant_id', 'drawer-organizer:white');

        $this->assertSame('"walka-home-featured-r2"', $response->headers->get('ETag'));
        $this->withHeader('If-None-Match', '"walka-home-featured-r2"')
            ->get('/api/v1/content/home-featured')
            ->assertStatus(304);
    }

    public function test_public_delivery_fails_closed_if_published_membership_no_longer_matches_catalog(): void
    {
        $service = $this->service();
        $service->saveDraft(
            HomeFeaturedContentDefinition::KEY,
            HomeFeaturedContentDefinition::TYPE,
            [
                'collection_variant_ids' => ['lunch-box:blue', 'unknown:variant'],
                'editorial_variant_id' => 'drawer-organizer:white',
            ],
            0,
            $this->actor,
        );
        $service->publish(HomeFeaturedContentDefinition::KEY, 1, $this->actor);

        $this->getJson('/api/v1/content/home-featured')
            ->assertStatus(503)
            ->assertJsonPath('error.code', 'content_invalid');
    }

    public function test_unknown_generic_payload_fields_are_not_reflected_publicly(): void
    {
        $payload = array_merge(HomeFeaturedContentDefinition::defaultPayload(), [
            'internal_note' => 'never-public',
            'amazon_url_override' => 'https://example.invalid',
        ]);
        $service = $this->service();
        $service->saveDraft(
            HomeFeaturedContentDefinition::KEY,
            HomeFeaturedContentDefinition::TYPE,
            $payload,
            0,
            $this->actor,
        );
        $service->publish(HomeFeaturedContentDefinition::KEY, 1, $this->actor);

        $response = $this->getJson('/api/v1/content/home-featured')->assertOk();
        $raw = $response->getContent();
        $this->assertStringNotContainsString('internal_note', $raw);
        $this->assertStringNotContainsString('never-public', $raw);
        $this->assertStringNotContainsString('amazon_url_override', $raw);
        $this->assertStringNotContainsString('example.invalid', $raw);
    }

    private function service(): ContentRevisionService
    {
        return app(ContentRevisionService::class);
    }
}
