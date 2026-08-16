<?php

namespace Tests\Feature\Api\V1;

use App\Models\ContentEntry;
use App\Models\ProductVariant;
use App\Services\Content\CommerceMapContentDefinition;
use App\Services\ContentRevisionService;
use App\Services\ContentScheduleService;
use Carbon\CarbonImmutable;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class GovernedCommerceMapTest extends TestCase
{
    use RefreshDatabase;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        $this->actor = hash('sha256', 'cms-060-governed-commerce-test');
    }

    public function test_authoring_normalizes_and_publishes_only_canonical_amazon_destination(): void
    {
        $service = app(ContentRevisionService::class);
        $entry = $service->saveDraft(
            CommerceMapContentDefinition::KEY,
            CommerceMapContentDefinition::TYPE,
            $this->payload(),
            0,
            $this->actor,
        );

        $this->assertSame('https://www.amazon.com/dp/B0FQN4L8MW', $entry->draft_payload['mappings'][0]['destination_url']);
        $service->publish(CommerceMapContentDefinition::KEY, 1, $this->actor);

        $response = $this->getJson('/api/v1/commerce/amazon/lunch-box:blue?market=US')
            ->assertOk()
            ->assertJsonPath('data.variant_id', 'lunch-box:blue')
            ->assertJsonPath('data.asin', 'B0FQN4L8MW')
            ->assertJsonPath('data.destination_url', 'https://www.amazon.com/dp/B0FQN4L8MW')
            ->assertJsonPath('meta.market_source', 'query')
            ->assertJsonPath('meta.retry_safe', true);

        $this->assertMatchesRegularExpression('/^[a-f0-9]{64}$/', (string) $response->json('data.verification_digest'));
        $this->assertMatchesRegularExpression('/^[a-f0-9]{64}$/', (string) $response->json('meta.resolution_id'));
    }

    public function test_missing_market_has_deterministic_us_fallback_and_retry_identity(): void
    {
        $this->publishPayload($this->payload());

        $first = $this->getJson('/api/v1/commerce/amazon/lunch-box:blue')->assertOk();
        $second = $this->getJson('/api/v1/commerce/amazon/lunch-box:blue')->assertOk();

        $first->assertJsonPath('data.region_market', 'US')
            ->assertJsonPath('meta.market_source', 'default_us');
        $this->assertSame($first->json('meta.resolution_id'), $second->json('meta.resolution_id'));
        $this->assertSame($first->json('data.verification_digest'), $second->json('data.verification_digest'));
    }

    public function test_malformed_or_unmapped_market_fails_closed_without_destination(): void
    {
        $this->publishPayload($this->payload());

        $malformed = $this->getJson('/api/v1/commerce/amazon/lunch-box:blue?market=evil')
            ->assertStatus(422)
            ->assertJsonPath('error.code', 'amazon_destination_rejected');
        $this->assertStringNotContainsString('destination_url', $malformed->getContent());

        $unmapped = $this->getJson('/api/v1/commerce/amazon/lunch-box:blue?market=CA')
            ->assertNotFound()
            ->assertJsonPath('error.code', 'amazon_destination_unmapped');
        $this->assertStringNotContainsString('destination_url', $unmapped->getContent());
    }

    public function test_published_mapping_fails_closed_after_variant_revision_becomes_stale(): void
    {
        $this->publishPayload($this->payload());
        ProductVariant::query()->whereKey('lunch-box:blue')->increment('revision');

        $response = $this->getJson('/api/v1/commerce/amazon/lunch-box:blue?market=US')
            ->assertStatus(503)
            ->assertJsonPath('error.code', 'commerce_map_invalid');
        $this->assertStringNotContainsString('destination_url', $response->getContent());
    }

    public function test_restore_and_scheduled_publish_revalidate_governed_revision(): void
    {
        $service = app(ContentRevisionService::class);
        $service->saveDraft(
            CommerceMapContentDefinition::KEY,
            CommerceMapContentDefinition::TYPE,
            $this->payload(),
            0,
            $this->actor,
        );

        ProductVariant::query()->whereKey('lunch-box:blue')->increment('revision');

        try {
            $service->restoreDraftFromRevision(
                CommerceMapContentDefinition::KEY,
                1,
                1,
                $this->actor,
                'rollback stale mapping test',
            );
            $this->fail('Stale historical CommerceMap revision should not restore.');
        } catch (ValidationException) {
            $this->assertTrue(true);
        }

        $freshPayload = $this->payload(variantRevision: 2);
        $service->saveDraft(
            CommerceMapContentDefinition::KEY,
            CommerceMapContentDefinition::TYPE,
            $freshPayload,
            1,
            $this->actor,
        );

        $publishAt = CarbonImmutable::parse('2026-08-16T15:00:00Z');
        app(ContentScheduleService::class)->schedule(
            CommerceMapContentDefinition::KEY,
            2,
            $publishAt,
            null,
            $this->actor,
        );

        ProductVariant::query()->whereKey('lunch-box:blue')->increment('revision');
        $result = app(ContentScheduleService::class)->runDue($publishAt->addMinute());

        $this->assertSame(1, $result['stale']);
        $this->assertNull(ContentEntry::query()->where('content_key', CommerceMapContentDefinition::KEY)->value('published_payload'));
    }

    /** @return array<string, mixed> */
    private function payload(int $variantRevision = 1): array
    {
        return [
            'mappings' => [[
                'variant_id' => 'lunch-box:blue',
                'variant_revision' => $variantRevision,
                'region_market' => 'us',
                'asin' => 'b0fqn4l8mw',
                'destination_url' => 'https://example.invalid/open-redirect-is-ignored',
                'cta_key' => 'buy_on_amazon',
                'disclosure_key' => 'amazon_purchase_disclosure',
                'entitlements' => ['amazon_purchase'],
                'active' => true,
                'trace' => [
                    'source' => 'cms',
                    'reference' => 'CMS-060',
                ],
            ]],
        ];
    }

    /** @param array<string, mixed> $payload */
    private function publishPayload(array $payload): void
    {
        $service = app(ContentRevisionService::class);
        $service->saveDraft(
            CommerceMapContentDefinition::KEY,
            CommerceMapContentDefinition::TYPE,
            $payload,
            0,
            $this->actor,
        );
        $service->publish(CommerceMapContentDefinition::KEY, 1, $this->actor);
    }
}
