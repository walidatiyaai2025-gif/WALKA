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

        $blue = $this->mapping($entry->draft_payload, 'lunch-box:blue', 'US');
        $this->assertSame('B0FQN4L8MW', $blue['asin']);
        $this->assertSame('https://www.amazon.com/dp/B0FQN4L8MW', $blue['destination_url']);
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

    public function test_asin_tamper_is_rejected_against_product_master(): void
    {
        $payload = $this->payload(function (array $mappings): array {
            foreach ($mappings as &$mapping) {
                if ($mapping['variant_id'] === 'lunch-box:blue') {
                    $mapping['asin'] = 'B000000000';
                    break;
                }
            }
            unset($mapping);

            return $mappings;
        });

        $this->expectException(ValidationException::class);
        app(ContentRevisionService::class)->saveDraft(
            CommerceMapContentDefinition::KEY,
            CommerceMapContentDefinition::TYPE,
            $payload,
            0,
            $this->actor,
        );
    }

    public function test_incomplete_or_inactive_us_mapping_is_rejected_for_released_variants(): void
    {
        $service = app(ContentRevisionService::class);
        $incomplete = $this->payload(static function (array $mappings): array {
            array_pop($mappings);

            return $mappings;
        });

        try {
            $service->saveDraft(
                CommerceMapContentDefinition::KEY,
                CommerceMapContentDefinition::TYPE,
                $incomplete,
                0,
                $this->actor,
            );
            $this->fail('A CommerceMap missing a released variant should be rejected.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey('mappings', $exception->errors());
        }

        $inactive = $this->payload(static function (array $mappings): array {
            $mappings[0]['active'] = false;

            return $mappings;
        });

        try {
            $service->saveDraft(
                CommerceMapContentDefinition::KEY,
                CommerceMapContentDefinition::TYPE,
                $inactive,
                0,
                $this->actor,
            );
            $this->fail('An inactive mandatory US mapping should be rejected.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey('mappings', $exception->errors());
        }
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

        $service->saveDraft(
            CommerceMapContentDefinition::KEY,
            CommerceMapContentDefinition::TYPE,
            $this->payload(),
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

    /**
     * @param  null|callable(list<array<string, mixed>>): list<array<string, mixed>>  $mutate
     * @return array{mappings: list<array<string, mixed>>}
     */
    private function payload(?callable $mutate = null): array
    {
        $mappings = ProductVariant::query()
            ->orderBy('id')
            ->get()
            ->map(static fn (ProductVariant $variant): array => [
                'variant_id' => $variant->id,
                'variant_revision' => (int) $variant->revision,
                'region_market' => 'US',
                'asin' => strtoupper((string) $variant->asin),
                'destination_url' => 'https://example.invalid/open-redirect-is-ignored',
                'cta_key' => 'buy_on_amazon',
                'disclosure_key' => 'amazon_purchase_disclosure',
                'entitlements' => ['amazon_purchase'],
                'active' => true,
                'trace' => [
                    'source' => 'cms',
                    'reference' => 'CMS-060',
                ],
            ])
            ->values()
            ->all();

        if ($mutate !== null) {
            $mappings = $mutate($mappings);
        }

        return ['mappings' => $mappings];
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

    /**
     * @param  array<string, mixed>  $payload
     * @return array<string, mixed>
     */
    private function mapping(array $payload, string $variantId, string $market): array
    {
        foreach ($payload['mappings'] as $mapping) {
            if ($mapping['variant_id'] === $variantId && $mapping['region_market'] === $market) {
                return $mapping;
            }
        }

        $this->fail("Missing mapping for $variantId / $market");
    }
}
