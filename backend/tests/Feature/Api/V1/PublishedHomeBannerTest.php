<?php

namespace Tests\Feature\Api\V1;

use App\Services\Content\HomeBannerContentDefinition;
use App\Services\ContentRevisionService;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class PublishedHomeBannerTest extends TestCase
{
    use RefreshDatabase;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->actor = hash('sha256', 'cms-023-public-banner-test');
    }

    protected function tearDown(): void
    {
        CarbonImmutable::setTestNow();
        parent::tearDown();
    }

    public function test_banner_is_private_until_explicit_publish(): void
    {
        $this->getJson('/api/v1/content/home-banner')
            ->assertNotFound()
            ->assertJsonPath('error.code', 'content_not_published');

        $this->service()->saveDraft(
            HomeBannerContentDefinition::KEY,
            HomeBannerContentDefinition::TYPE,
            HomeBannerContentDefinition::defaultPayload(),
            0,
            $this->actor,
        );

        $this->getJson('/api/v1/content/home-banner')->assertNotFound();
    }

    public function test_public_api_reports_active_state_at_schedule_boundaries(): void
    {
        CarbonImmutable::setTestNow('2026-08-13T09:59:59Z');
        $service = $this->service();
        $service->saveDraft(
            HomeBannerContentDefinition::KEY,
            HomeBannerContentDefinition::TYPE,
            $this->scheduledPayload(),
            0,
            $this->actor,
        );
        $service->publish(HomeBannerContentDefinition::KEY, 1, $this->actor);

        $this->getJson('/api/v1/content/home-banner')
            ->assertOk()
            ->assertJsonPath('data.schema_version', 1)
            ->assertJsonPath('data.revision', 2)
            ->assertJsonPath('meta.api_version', 'v1')
            ->assertJsonPath('meta.active', false);

        CarbonImmutable::setTestNow('2026-08-13T10:00:00Z');
        $response = $this->getJson('/api/v1/content/home-banner')
            ->assertOk()
            ->assertJsonPath('meta.active', true)
            ->assertJsonPath('data.payload.starts_at', '2026-08-13T10:00:00Z')
            ->assertJsonPath('data.payload.ends_at', '2026-08-13T12:00:00Z');

        $this->assertSame('"walka-home-banner-r2"', $response->headers->get('ETag'));

        CarbonImmutable::setTestNow('2026-08-13T12:00:00Z');
        $this->getJson('/api/v1/content/home-banner')
            ->assertOk()
            ->assertJsonPath('meta.active', false);
    }

    public function test_public_payload_discards_unknown_keys_and_remote_urls(): void
    {
        CarbonImmutable::setTestNow('2026-08-13T11:00:00Z');
        $payload = array_merge($this->scheduledPayload(), [
            'internal_note' => 'private-only',
            'target_url' => 'https://example.invalid/evil',
            'html' => '<script>alert(1)</script>',
            'discount_percent' => 90,
        ]);

        $service = $this->service();
        $service->saveDraft(
            HomeBannerContentDefinition::KEY,
            HomeBannerContentDefinition::TYPE,
            $payload,
            0,
            $this->actor,
        );
        $service->publish(HomeBannerContentDefinition::KEY, 1, $this->actor);

        $raw = $this->getJson('/api/v1/content/home-banner')
            ->assertOk()
            ->assertJsonPath('meta.active', true)
            ->getContent();

        $this->assertStringNotContainsString('internal_note', $raw);
        $this->assertStringNotContainsString('private-only', $raw);
        $this->assertStringNotContainsString('target_url', $raw);
        $this->assertStringNotContainsString('example.invalid', $raw);
        $this->assertStringNotContainsString('<script>', $raw);
        $this->assertStringNotContainsString('discount_percent', $raw);
    }

    /** @return array<string, mixed> */
    private function scheduledPayload(): array
    {
        return [
            'enabled' => true,
            'eyebrow' => 'WALKA WEEK',
            'title' => 'A calmer week starts here',
            'body' => 'Explore thoughtful organization while this announcement window is active.',
            'cta_label' => 'BROWSE COLLECTION',
            'cta_action' => 'browse',
            'starts_at' => '2026-08-13T10:00:00Z',
            'ends_at' => '2026-08-13T12:00:00Z',
        ];
    }

    private function service(): ContentRevisionService
    {
        return app(ContentRevisionService::class);
    }
}
