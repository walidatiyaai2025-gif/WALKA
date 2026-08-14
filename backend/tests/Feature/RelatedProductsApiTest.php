<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use App\Services\Content\RelatedProductsContentDefinition;
use App\Services\ContentRevisionService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class RelatedProductsApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
    }

    public function test_unpublished_related_products_are_not_public(): void
    {
        app(ContentRevisionService::class)->saveDraft(
            contentKey: RelatedProductsContentDefinition::KEY,
            contentType: RelatedProductsContentDefinition::TYPE,
            payload: RelatedProductsContentDefinition::defaultPayload(),
            expectedRevision: 0,
            actorFingerprint: $this->actorFingerprint(),
        );

        $this->getJson('/api/v1/content/related-products')
            ->assertStatus(404)
            ->assertJsonPath('error.code', 'content_not_published');
    }

    public function test_published_related_products_use_versioned_public_envelope_and_etag(): void
    {
        $service = app(ContentRevisionService::class);
        $service->saveDraft(
            contentKey: RelatedProductsContentDefinition::KEY,
            contentType: RelatedProductsContentDefinition::TYPE,
            payload: RelatedProductsContentDefinition::defaultPayload(),
            expectedRevision: 0,
            actorFingerprint: $this->actorFingerprint(),
        );
        $service->publish(
            contentKey: RelatedProductsContentDefinition::KEY,
            expectedRevision: 1,
            actorFingerprint: $this->actorFingerprint(),
        );

        $response = $this->getJson('/api/v1/content/related-products')
            ->assertOk()
            ->assertJsonPath('data.key', 'pdp.related_products')
            ->assertJsonPath('data.type', 'pdp.related_products')
            ->assertJsonPath('data.schema_version', 1)
            ->assertJsonPath('data.revision', 2)
            ->assertJsonPath('meta.api_version', 'v1')
            ->assertJsonPath('data.payload.relationships.0.product_id', 'drawer-organizer')
            ->assertJsonPath('data.payload.relationships.0.related_product_ids.0', 'stainless-steel-bento-lunch-box');

        $etag = $response->headers->get('ETag');
        $this->assertSame('"walka-related-products-r2"', $etag);

        $this->withHeader('If-None-Match', (string) $etag)
            ->get('/api/v1/content/related-products')
            ->assertStatus(304)
            ->assertHeader('ETag', (string) $etag);
    }

    public function test_public_normalization_strips_private_fields(): void
    {
        $service = app(ContentRevisionService::class);
        $payload = RelatedProductsContentDefinition::defaultPayload();
        $payload['private_note'] = 'draft-only';
        $payload['relationships'][0]['amazon_url'] = 'https://example.com/not-allowed';

        $service->saveDraft(
            contentKey: RelatedProductsContentDefinition::KEY,
            contentType: RelatedProductsContentDefinition::TYPE,
            payload: $payload,
            expectedRevision: 0,
            actorFingerprint: $this->actorFingerprint(),
        );
        $service->publish(
            contentKey: RelatedProductsContentDefinition::KEY,
            expectedRevision: 1,
            actorFingerprint: $this->actorFingerprint(),
        );

        $json = $this->getJson('/api/v1/content/related-products')
            ->assertOk()
            ->json('data.payload');

        $this->assertSame(['relationships'], array_keys($json));
        $this->assertSame(
            ['product_id', 'related_product_ids'],
            array_keys($json['relationships'][0]),
        );
    }

    public function test_unknown_catalog_identity_in_published_payload_fails_closed(): void
    {
        $service = app(ContentRevisionService::class);
        $service->saveDraft(
            contentKey: RelatedProductsContentDefinition::KEY,
            contentType: RelatedProductsContentDefinition::TYPE,
            payload: RelatedProductsContentDefinition::defaultPayload(),
            expectedRevision: 0,
            actorFingerprint: $this->actorFingerprint(),
        );
        $service->publish(
            contentKey: RelatedProductsContentDefinition::KEY,
            expectedRevision: 1,
            actorFingerprint: $this->actorFingerprint(),
        );

        $entry = ContentEntry::query()
            ->where('content_key', RelatedProductsContentDefinition::KEY)
            ->firstOrFail();
        $corrupt = $entry->published_payload;
        $corrupt['relationships'][0]['related_product_ids'] = ['server-authored-product'];
        $entry->forceFill(['published_payload' => $corrupt])->save();

        $this->getJson('/api/v1/content/related-products')
            ->assertStatus(503)
            ->assertJsonPath('error.code', 'content_invalid');
    }

    private function actorFingerprint(): string
    {
        return hash('sha256', 'cms-013-related-products-api-test');
    }
}
