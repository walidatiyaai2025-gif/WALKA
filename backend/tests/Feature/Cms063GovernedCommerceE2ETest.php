<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use App\Models\ProductVariant;
use App\Services\CmsMetadataBackupService;
use App\Services\CmsProductionSmokeService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class Cms063GovernedCommerceE2ETest extends TestCase
{
    use RefreshDatabase;

    private array $session;

    protected function setUp(): void
    {
        parent::setUp();

        config()->set('walka.dashboard_username', 'admin');
        config()->set('walka.dashboard_password', 'Walka-Admin-Test-Password-2026');
        $this->session = [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_actor' => hash('sha256', 'cms-063-e2e'),
        ];
        $this->seed(WalkaCatalogSeeder::class);
    }

    public function test_admin_publish_flows_through_public_verified_commerce_and_preserves_product_master(): void
    {
        $variant = ProductVariant::query()->findOrFail('lunch-box:blue');
        $protectedIdentity = [
            'id' => $variant->id,
            'asin' => $variant->asin,
            'pantone' => $variant->pantone,
            'revision' => (int) $variant->revision,
        ];

        $payload = [
            'mappings' => [[
                'variant_id' => 'lunch-box:blue',
                'variant_revision' => (int) $variant->revision,
                'region_market' => 'US',
                'asin' => $variant->asin,
                'destination_url' => 'https://example.invalid/attempted-open-redirect',
                'cta_key' => 'commerce.amazon.buy',
                'disclosure_key' => 'commerce.amazon.disclosure',
                'entitlements' => ['amazon.redirect'],
                'active' => true,
                'trace' => [
                    'source' => 'cms.verified',
                    'reference' => '#376',
                ],
            ]],
        ];

        $this->withSession($this->session)
            ->post(route('admin.content.store'), [
                'content_key' => 'commerce.map',
                'content_type' => 'commerce.map',
                'payload_json' => json_encode($payload, JSON_THROW_ON_ERROR),
            ])
            ->assertRedirect();

        $entry = ContentEntry::query()->where('content_key', 'commerce.map')->firstOrFail();
        $this->assertSame(1, $entry->revision);
        $this->assertNull($entry->published_revision);
        $this->assertSame(
            'https://www.amazon.com/dp/'.$variant->asin,
            $entry->draft_payload['mappings'][0]['destination_url'],
        );

        $this->withSession($this->session)
            ->post(route('admin.content.publish', ['content' => $entry->id]), [
                'revision' => 1,
            ])
            ->assertRedirect(route('admin.content.show', ['content' => $entry->id]));

        $entry->refresh();
        $this->assertSame(2, $entry->published_revision);

        $index = $this->getJson('/api/v1/commerce/amazon')
            ->assertOk()
            ->assertHeader('ETag', '"walka-commerce-map-r2"')
            ->assertJsonPath('data.schema_version', 1)
            ->assertJsonPath('data.mappings.0.variant_id', 'lunch-box:blue')
            ->assertJsonPath('data.mappings.0.asin', $variant->asin)
            ->assertJsonPath('data.mappings.0.destination_url', 'https://www.amazon.com/dp/'.$variant->asin)
            ->assertJsonPath('data.verification.algorithm', 'sha256')
            ->assertJsonPath('data.verification.published_revision', 2)
            ->assertJsonPath('data.verification.active_mapping_count', 1);

        $digest = $index->json('data.verification.digest');
        $this->assertIsString($digest);
        $this->assertMatchesRegularExpression('/^[a-f0-9]{64}$/', $digest);

        $this->withHeader('If-None-Match', '"walka-commerce-map-r2"')
            ->get('/api/v1/commerce/amazon')
            ->assertStatus(304);

        $this->getJson('/api/v1/commerce/amazon/lunch-box:blue?market=US')
            ->assertOk()
            ->assertJsonPath('data.variant_id', 'lunch-box:blue')
            ->assertJsonPath('data.asin', $variant->asin)
            ->assertJsonPath('data.destination_url', 'https://www.amazon.com/dp/'.$variant->asin)
            ->assertJsonPath('meta.market_source', 'query')
            ->assertJsonPath('meta.retry_safe', true);

        $this->getJson('/api/v1/config')
            ->assertOk()
            ->assertJsonPath('data.purchase_mode', 'amazon_redirect');

        $backup = app(CmsMetadataBackupService::class)->export();
        $backupEntry = collect($backup['sections']['content_entries'])
            ->firstWhere('content_key', 'commerce.map');
        $this->assertSame('commerce.map', $backupEntry['content_type']);
        $this->assertSame(2, $backupEntry['published_revision']);
        $this->assertTrue(app(CmsMetadataBackupService::class)->validatePackage($backup)['valid']);

        $smoke = app(CmsProductionSmokeService::class)->run();
        $this->assertSame(0, $smoke['summary']['failed'], json_encode($smoke, JSON_PRETTY_PRINT));
        $smokeIds = collect($smoke['checks'])->pluck('id');
        $this->assertTrue($smokeIds->contains('api.route.commerce.map'));
        $this->assertTrue($smokeIds->contains('commerce.verification-contract'));
        $this->assertTrue($smokeIds->contains('flutter.commerce.endpoint'));
        $this->assertTrue($smokeIds->contains('flutter.commerce.verification'));
        $this->assertTrue($smokeIds->contains('flutter.commerce.purchase-guard'));

        $variant->refresh();
        $this->assertSame($protectedIdentity['id'], $variant->id);
        $this->assertSame($protectedIdentity['asin'], $variant->asin);
        $this->assertSame($protectedIdentity['pantone'], $variant->pantone);
        $this->assertSame($protectedIdentity['revision'], (int) $variant->revision);
    }
}
