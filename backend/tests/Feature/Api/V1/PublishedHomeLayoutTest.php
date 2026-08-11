<?php

namespace Tests\Feature\Api\V1;

use App\Services\Content\HomeLayoutContentDefinition;
use App\Services\ContentRevisionService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class PublishedHomeLayoutTest extends TestCase
{
    use RefreshDatabase;

    private string $actorFingerprint;

    protected function setUp(): void
    {
        parent::setUp();
        $this->actorFingerprint = hash('sha256', 'cms-021-layout-api-test');
    }

    public function test_layout_is_not_public_until_explicitly_published(): void
    {
        $this->getJson('/api/v1/content/home-layout')
            ->assertNotFound()
            ->assertJsonPath('error.code', 'content_not_published');

        $this->service()->saveDraft(
            HomeLayoutContentDefinition::KEY,
            HomeLayoutContentDefinition::TYPE,
            HomeLayoutContentDefinition::defaultPayload(),
            0,
            $this->actorFingerprint,
        );

        $this->getJson('/api/v1/content/home-layout')
            ->assertNotFound();
    }

    public function test_public_layout_is_typed_versioned_and_revision_cacheable(): void
    {
        $service = $this->service();
        $service->saveDraft(
            HomeLayoutContentDefinition::KEY,
            HomeLayoutContentDefinition::TYPE,
            HomeLayoutContentDefinition::defaultPayload(),
            0,
            $this->actorFingerprint,
        );
        $service->publish(HomeLayoutContentDefinition::KEY, 1, $this->actorFingerprint);

        $response = $this->getJson('/api/v1/content/home-layout')
            ->assertOk()
            ->assertJsonPath('data.key', 'home.layout')
            ->assertJsonPath('data.type', 'home.layout')
            ->assertJsonPath('data.schema_version', 1)
            ->assertJsonPath('data.revision', 2)
            ->assertJsonPath('data.payload.sections.0.id', 'hero')
            ->assertJsonPath('data.payload.sections.2.id', 'collection')
            ->assertJsonPath('data.payload.sections.2.title', 'Everything in Its Place');

        $this->assertSame('"walka-home-layout-r2"', $response->headers->get('ETag'));

        $this->withHeader('If-None-Match', '"walka-home-layout-r2"')
            ->get('/api/v1/content/home-layout')
            ->assertStatus(304)
            ->assertHeader('ETag', '"walka-home-layout-r2"');
    }

    public function test_invalid_or_unknown_published_layout_fails_closed(): void
    {
        $payload = HomeLayoutContentDefinition::defaultPayload();
        $payload['sections'][1]['id'] = 'arbitrary_remote_widget';

        $service = $this->service();
        $service->saveDraft(
            HomeLayoutContentDefinition::KEY,
            HomeLayoutContentDefinition::TYPE,
            $payload,
            0,
            $this->actorFingerprint,
        );
        $service->publish(HomeLayoutContentDefinition::KEY, 1, $this->actorFingerprint);

        $this->getJson('/api/v1/content/home-layout')
            ->assertStatus(503)
            ->assertJsonPath('error.code', 'content_invalid');
    }

    public function test_public_layout_strips_unknown_section_fields(): void
    {
        $payload = HomeLayoutContentDefinition::defaultPayload();
        $payload['sections'][0]['internal_note'] = 'do-not-leak';
        $payload['sections'][2]['private'] = ['secret' => true];

        $service = $this->service();
        $service->saveDraft(
            HomeLayoutContentDefinition::KEY,
            HomeLayoutContentDefinition::TYPE,
            $payload,
            0,
            $this->actorFingerprint,
        );
        $service->publish(HomeLayoutContentDefinition::KEY, 1, $this->actorFingerprint);

        $response = $this->getJson('/api/v1/content/home-layout')->assertOk();
        $raw = $response->getContent();
        $this->assertStringNotContainsString('internal_note', $raw);
        $this->assertStringNotContainsString('do-not-leak', $raw);
        $this->assertStringNotContainsString('private', $raw);
        $this->assertStringNotContainsString('secret', $raw);
    }

    private function service(): ContentRevisionService
    {
        return app(ContentRevisionService::class);
    }
}
