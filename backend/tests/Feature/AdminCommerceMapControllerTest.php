<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use App\Models\ContentRevision;
use App\Models\ProductVariant;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AdminCommerceMapControllerTest extends TestCase
{
    use RefreshDatabase;

    private array $session;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);

        config()->set('walka.dashboard_username', 'admin');
        config()->set('walka.dashboard_password', 'Walka-Admin-Test-Password-2026');

        $this->session = [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_actor' => hash('sha256', 'cms-060-commerce-admin-test'),
        ];
    }

    public function test_editor_is_protected_and_bootstraps_complete_read_only_product_master_mapping(): void
    {
        $this->get('/admin/content/commerce/amazon')
            ->assertRedirect(route('admin.login'));

        $this->withSession($this->session)
            ->get(route('admin.content.commerce.edit'))
            ->assertOk()
            ->assertSee('Amazon purchase destinations', false)
            ->assertSee('Product Master · read-only', false)
            ->assertSee('B0FQN4L8MW', false)
            ->assertSee('REQUIRED · ACTIVE', false);

        $entry = ContentEntry::query()->where('content_key', 'commerce.map')->firstOrFail();
        $variantCount = ProductVariant::query()->count();

        $this->assertSame('commerce.map', $entry->content_type);
        $this->assertSame(1, $entry->revision);
        $this->assertNull($entry->published_revision);
        $this->assertCount($variantCount * 3, $entry->draft_payload['mappings']);

        foreach (ProductVariant::query()->orderBy('id')->get() as $variant) {
            $us = $this->mapping($entry->draft_payload, $variant->id, 'US');
            $this->assertTrue($us['active']);
            $this->assertSame(strtoupper((string) $variant->asin), $us['asin']);
            $this->assertSame(
                'https://www.amazon.com/dp/'.strtoupper((string) $variant->asin),
                $us['destination_url'],
            );
        }
    }

    public function test_owner_can_enable_market_and_hostile_identity_fields_are_ignored_before_publish(): void
    {
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->patch(route('admin.content.commerce.update'), [
                'revision' => 1,
                'active' => [
                    'lunch-box:blue' => [
                        'CA' => '1',
                        'MX' => '0',
                    ],
                ],
                'asin' => 'B000000000',
                'variant_id' => 'attacker:variant',
                'destination_url' => 'https://example.invalid/open-redirect',
            ])
            ->assertRedirect(route('admin.content.commerce.edit'));

        $entry->refresh();
        $this->assertSame(2, $entry->revision);

        $blueUs = $this->mapping($entry->draft_payload, 'lunch-box:blue', 'US');
        $blueCa = $this->mapping($entry->draft_payload, 'lunch-box:blue', 'CA');
        $this->assertSame('B0FQN4L8MW', $blueUs['asin']);
        $this->assertSame('B0FQN4L8MW', $blueCa['asin']);
        $this->assertSame('https://www.amazon.ca/dp/B0FQN4L8MW', $blueCa['destination_url']);
        $this->assertTrue($blueCa['active']);
        $this->assertStringNotContainsString('example.invalid', json_encode($entry->draft_payload));
        $this->assertStringNotContainsString('attacker:variant', json_encode($entry->draft_payload));

        $this->withSession($this->session)
            ->post(route('admin.content.commerce.publish'), ['revision' => 2])
            ->assertRedirect(route('admin.content.commerce.edit'));

        $entry->refresh();
        $this->assertSame(3, $entry->published_revision);

        $this->getJson('/api/v1/commerce/amazon/lunch-box:blue?market=CA')
            ->assertOk()
            ->assertJsonPath('data.asin', 'B0FQN4L8MW')
            ->assertJsonPath('data.destination_url', 'https://www.amazon.ca/dp/B0FQN4L8MW');
    }

    public function test_restore_requires_reason_and_creates_private_draft_without_republishing(): void
    {
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->patch(route('admin.content.commerce.update'), [
                'revision' => 1,
                'active' => ['lunch-box:blue' => ['CA' => '1']],
            ])
            ->assertRedirect();
        $this->withSession($this->session)
            ->post(route('admin.content.commerce.publish'), ['revision' => 2])
            ->assertRedirect();

        $this->withSession($this->session)
            ->patch(route('admin.content.commerce.update'), [
                'revision' => 3,
                'active' => [],
            ])
            ->assertRedirect();

        $entry->refresh();
        $this->assertSame(4, $entry->revision);
        $this->assertSame(3, $entry->published_revision);
        $this->assertFalse($this->mapping($entry->draft_payload, 'lunch-box:blue', 'CA')['active']);
        $this->assertTrue($this->mapping($entry->published_payload, 'lunch-box:blue', 'CA')['active']);

        $this->withSession($this->session)
            ->from(route('admin.content.commerce.edit'))
            ->post(route('admin.content.commerce.restore'), [
                'revision' => 4,
                'source_revision' => 2,
            ])
            ->assertRedirect(route('admin.content.commerce.edit'))
            ->assertSessionHasErrors('reason');

        $this->withSession($this->session)
            ->post(route('admin.content.commerce.restore'), [
                'revision' => 4,
                'source_revision' => 2,
                'reason' => 'Restore the verified Canada destination after owner review',
            ])
            ->assertRedirect(route('admin.content.commerce.edit'));

        $entry->refresh();
        $this->assertSame(5, $entry->revision);
        $this->assertSame(3, $entry->published_revision);
        $this->assertTrue($this->mapping($entry->draft_payload, 'lunch-box:blue', 'CA')['active']);
        $this->assertTrue($this->mapping($entry->published_payload, 'lunch-box:blue', 'CA')['active']);

        $latest = ContentRevision::query()->latest('revision')->firstOrFail();
        $this->assertSame('draft_restored', $latest->action);
        $this->assertSame(2, $latest->source_revision);
        $this->assertSame('Restore the verified Canada destination after owner review', $latest->reason);
    }

    private function bootstrap(): ContentEntry
    {
        $this->withSession($this->session)
            ->get(route('admin.content.commerce.edit'))
            ->assertOk();

        return ContentEntry::query()->where('content_key', 'commerce.map')->firstOrFail();
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
