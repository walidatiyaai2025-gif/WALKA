<?php

namespace Tests\Feature\Api\V1;

use App\Models\Product;
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
            $this->currentPayload(),
            0,
            $this->actor,
        );

        $this->getJson('/api/v1/content/home-featured')->assertNotFound();
    }

    public function test_public_featured_payload_is_versioned_cacheable_and_catalog_driven(): void
    {
        $payload = $this->currentPayload();
        $service = $this->service();
        $service->saveDraft(
            HomeFeaturedContentDefinition::KEY,
            HomeFeaturedContentDefinition::TYPE,
            $payload,
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
            ->assertJsonPath('data.payload.collection_variant_ids.0', $payload['collection_variant_ids'][0])
            ->assertJsonPath('data.payload.collection_variant_ids.1', $payload['collection_variant_ids'][1])
            ->assertJsonPath('data.payload.editorial_variant_id', $payload['editorial_variant_id']);

        $this->assertSame('"walka-home-featured-r2"', $response->headers->get('ETag'));
        $this->withHeader('If-None-Match', '"walka-home-featured-r2"')
            ->get('/api/v1/content/home-featured')
            ->assertStatus(304);
    }

    public function test_public_delivery_fails_closed_if_published_membership_no_longer_matches_catalog(): void
    {
        $payload = $this->currentPayload();
        $payload['collection_variant_ids'][1] = 'unknown:variant';
        $service = $this->service();
        $service->saveDraft(
            HomeFeaturedContentDefinition::KEY,
            HomeFeaturedContentDefinition::TYPE,
            $payload,
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
        $payload = array_merge($this->currentPayload(), [
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

    /** @return array{collection_variant_ids:list<string>,editorial_variant_id:string} */
    private function currentPayload(): array
    {
        $families = Product::query()
            ->where('is_visible', true)
            ->whereHas('categoryEntity', fn ($query) => $query->where('is_visible', true))
            ->whereHas('variants', fn ($query) => $query->where('is_visible', true))
            ->with(['variants' => fn ($query) => $query
                ->where('is_visible', true)
                ->orderBy('sort_order')
                ->orderBy('id')])
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get()
            ->take(2)
            ->map(fn (Product $product): string => (string) $product->variants->first()->id)
            ->values()
            ->all();

        $this->assertCount(2, $families);

        return [
            'collection_variant_ids' => $families,
            'editorial_variant_id' => $families[0],
        ];
    }

    private function service(): ContentRevisionService
    {
        return app(ContentRevisionService::class);
    }
}
