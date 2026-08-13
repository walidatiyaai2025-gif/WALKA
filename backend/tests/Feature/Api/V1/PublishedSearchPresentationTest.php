<?php

namespace Tests\Feature\Api\V1;

use App\Models\ProductVariant;
use App\Services\Content\ContentRevisionService;
use App\Services\Content\SearchPresentationContentDefinition;
use App\Services\ContentRevisionService as ContentService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class PublishedSearchPresentationTest extends TestCase
{
    use RefreshDatabase;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        $this->actor = hash('sha256', 'cms-025-public-test');
    }

    public function test_search_is_private_until_explicit_publish(): void
    {
        $this->getJson('/api/v1/content/search')
            ->assertNotFound()
            ->assertJsonPath('error.code', 'content_not_published');

        $this->service()->saveDraft(
            SearchPresentationContentDefinition::KEY,
            SearchPresentationContentDefinition::TYPE,
            SearchPresentationContentDefinition::defaultPayload(),
            0,
            $this->actor,
        );

        $this->getJson('/api/v1/content/search')->assertNotFound();
    }

    public function test_public_search_is_versioned_allowlisted_and_complete(): void
    {
        $payload = SearchPresentationContentDefinition::defaultPayload();
        $payload['heading'] = 'Find WALKA';
        $payload['internal_note'] = 'never-public';
        $payload['target_url'] = 'https://example.invalid';

        $service = $this->service();
        $service->saveDraft(
            SearchPresentationContentDefinition::KEY,
            SearchPresentationContentDefinition::TYPE,
            $payload,
            0,
            $this->actor,
        );
        $service->publish(SearchPresentationContentDefinition::KEY, 1, $this->actor);

        $response = $this->getJson('/api/v1/content/search')
            ->assertOk()
            ->assertJsonPath('data.key', 'search.presentation')
            ->assertJsonPath('data.schema_version', 1)
            ->assertJsonPath('data.revision', 2)
            ->assertJsonPath('data.payload.heading', 'Find WALKA')
            ->assertJsonCount(5, 'data.payload.featured_variant_ids')
            ->assertJsonCount(3, 'data.payload.filter_labels');

        $raw = $response->getContent();
        $this->assertStringNotContainsString('internal_note', $raw);
        $this->assertStringNotContainsString('never-public', $raw);
        $this->assertStringNotContainsString('target_url', $raw);
        $this->assertStringNotContainsString('example.invalid', $raw);
        $this->assertSame('"walka-search-r2"', $response->headers->get('ETag'));

        $this->withHeader('If-None-Match', '"walka-search-r2"')
            ->get('/api/v1/content/search')
            ->assertStatus(304);
    }

    public function test_delivery_fails_closed_if_published_merchandising_no_longer_matches_catalog(): void
    {
        $service = $this->service();
        $service->saveDraft(
            SearchPresentationContentDefinition::KEY,
            SearchPresentationContentDefinition::TYPE,
            SearchPresentationContentDefinition::defaultPayload(),
            0,
            $this->actor,
        );
        $service->publish(SearchPresentationContentDefinition::KEY, 1, $this->actor);

        ProductVariant::query()->where('id', 'lunch-box:green')->delete();

        $this->getJson('/api/v1/content/search')
            ->assertStatus(503)
            ->assertJsonPath('error.code', 'content_invalid');
    }

    private function service(): ContentService
    {
        return app(ContentService::class);
    }
}
