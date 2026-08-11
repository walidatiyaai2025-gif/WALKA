<?php

namespace Tests\Feature\Api\V1;

use App\Services\ContentRevisionService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class PublishedContentTest extends TestCase
{
    use RefreshDatabase;

    private string $actorFingerprint;

    protected function setUp(): void
    {
        parent::setUp();
        $this->actorFingerprint = hash('sha256', 'cms-003-test-actor');
    }

    public function test_home_content_is_404_until_an_allowlisted_entry_is_published(): void
    {
        $this->getJson('/api/v1/content/home')
            ->assertNotFound()
            ->assertJsonPath('error.code', 'content_not_published');

        $this->service()->saveDraft(
            'home.hero',
            'home.hero',
            $this->payload('Draft only'),
            0,
            $this->actorFingerprint,
        );

        $this->getJson('/api/v1/content/home')
            ->assertNotFound()
            ->assertJsonPath('error.code', 'content_not_published');
    }

    public function test_published_home_content_uses_a_versioned_safe_envelope_without_admin_metadata(): void
    {
        $service = $this->service();
        $service->saveDraft('home.hero', 'home.hero', $this->payload('Remote Hero'), 0, $this->actorFingerprint);
        $entry = $service->publish('home.hero', 1, $this->actorFingerprint);

        $response = $this->getJson('/api/v1/content/home')
            ->assertOk()
            ->assertJsonPath('data.key', 'home.hero')
            ->assertJsonPath('data.type', 'home.hero')
            ->assertJsonPath('data.schema_version', 1)
            ->assertJsonPath('data.revision', $entry->published_revision)
            ->assertJsonPath('data.payload.title', 'Remote Hero')
            ->assertJsonPath('meta.api_version', 'v1');

        $raw = $response->getContent();
        $this->assertStringNotContainsString('draft_payload', $raw);
        $this->assertStringNotContainsString('actor_fingerprint', $raw);
        $this->assertStringNotContainsString('content_revisions', $raw);
        $this->assertSame('"walka-home-hero-r2"', $response->headers->get('ETag'));
        $this->assertStringContainsString('max-age=60', (string) $response->headers->get('Cache-Control'));
    }

    public function test_invalid_published_payload_fails_closed_instead_of_reaching_mobile_clients(): void
    {
        $service = $this->service();
        $service->saveDraft('home.hero', 'home.hero', ['title' => 'Missing required fields'], 0, $this->actorFingerprint);
        $service->publish('home.hero', 1, $this->actorFingerprint);

        $this->getJson('/api/v1/content/home')
            ->assertStatus(503)
            ->assertJsonPath('error.code', 'content_invalid');
    }

    public function test_etag_returns_not_modified_for_the_current_published_revision(): void
    {
        $service = $this->service();
        $service->saveDraft('home.hero', 'home.hero', $this->payload('Cached Hero'), 0, $this->actorFingerprint);
        $service->publish('home.hero', 1, $this->actorFingerprint);

        $this->withHeader('If-None-Match', '"walka-home-hero-r2"')
            ->get('/api/v1/content/home')
            ->assertStatus(304)
            ->assertHeader('ETag', '"walka-home-hero-r2"');
    }

    public function test_restore_then_republish_advances_revision_and_delivers_the_restored_snapshot(): void
    {
        $service = $this->service();
        $service->saveDraft('home.hero', 'home.hero', $this->payload('Hero A'), 0, $this->actorFingerprint);
        $service->publish('home.hero', 1, $this->actorFingerprint);
        $service->saveDraft('home.hero', 'home.hero', $this->payload('Hero B'), 2, $this->actorFingerprint);
        $service->publish('home.hero', 3, $this->actorFingerprint);
        $service->restoreDraftFromRevision('home.hero', 1, 4, $this->actorFingerprint);
        $entry = $service->publish('home.hero', 5, $this->actorFingerprint);

        $this->assertSame(6, $entry->published_revision);

        $this->getJson('/api/v1/content/home')
            ->assertOk()
            ->assertJsonPath('data.revision', 6)
            ->assertJsonPath('data.payload.title', 'Hero A');
    }

    private function service(): ContentRevisionService
    {
        return app(ContentRevisionService::class);
    }

    private function payload(string $title): array
    {
        return [
            'eyebrow' => 'PREMIUM ORGANIZATION ELEVATED EVERYDAY.',
            'title' => $title,
            'body' => 'Premium organization designed for calm, everyday order.',
            'shop_label' => 'SHOP PRODUCTS',
            'search_label' => 'SEARCH COLLECTION',
        ];
    }
}
