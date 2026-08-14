<?php

namespace Tests\Feature\Api\V1;

use App\Services\Content\PdpLayoutContentDefinition;
use App\Services\ContentRevisionService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class PublishedPdpLayoutTest extends TestCase
{
    use RefreshDatabase;

    private string $actorFingerprint;

    protected function setUp(): void
    {
        parent::setUp();
        $this->actorFingerprint = hash('sha256', 'cms-012-pdp-layout-api-test');
    }

    public function test_pdp_layout_is_not_public_until_explicitly_published(): void
    {
        $this->getJson('/api/v1/content/pdp-layout')
            ->assertNotFound()
            ->assertJsonPath('error.code', 'content_not_published');

        $this->service()->saveDraft(
            PdpLayoutContentDefinition::KEY,
            PdpLayoutContentDefinition::TYPE,
            PdpLayoutContentDefinition::defaultPayload(),
            0,
            $this->actorFingerprint,
        );

        $this->getJson('/api/v1/content/pdp-layout')->assertNotFound();
    }

    public function test_public_pdp_layout_is_typed_versioned_and_revision_cacheable(): void
    {
        $payload = PdpLayoutContentDefinition::defaultPayload();
        $payload['sections'][3]['visible'] = false;
        $payload['sections'][5]['visible'] = false;

        $service = $this->service();
        $service->saveDraft(
            PdpLayoutContentDefinition::KEY,
            PdpLayoutContentDefinition::TYPE,
            $payload,
            0,
            $this->actorFingerprint,
        );
        $service->publish(PdpLayoutContentDefinition::KEY, 1, $this->actorFingerprint);

        $response = $this->getJson('/api/v1/content/pdp-layout')
            ->assertOk()
            ->assertJsonPath('data.key', 'pdp.layout')
            ->assertJsonPath('data.type', 'pdp.layout')
            ->assertJsonPath('data.schema_version', 1)
            ->assertJsonPath('data.revision', 2)
            ->assertJsonPath('data.payload.sections.0.id', 'gallery')
            ->assertJsonPath('data.payload.sections.3.id', 'usage')
            ->assertJsonPath('data.payload.sections.3.visible', false)
            ->assertJsonPath('data.payload.sections.5.id', 'editorial')
            ->assertJsonPath('data.payload.sections.5.visible', false)
            ->assertJsonPath('meta.api_version', 'v1');

        $this->assertSame('"walka-pdp-layout-r2"', $response->headers->get('ETag'));

        $this->withHeader('If-None-Match', '"walka-pdp-layout-r2"')
            ->get('/api/v1/content/pdp-layout')
            ->assertStatus(304)
            ->assertHeader('ETag', '"walka-pdp-layout-r2"');
    }

    public function test_invalid_published_pdp_layout_fails_closed(): void
    {
        $payload = PdpLayoutContentDefinition::defaultPayload();
        $payload['sections'][0]['id'] = 'arbitrary_remote_widget';

        $service = $this->service();
        $service->saveDraft(
            PdpLayoutContentDefinition::KEY,
            PdpLayoutContentDefinition::TYPE,
            $payload,
            0,
            $this->actorFingerprint,
        );
        $service->publish(PdpLayoutContentDefinition::KEY, 1, $this->actorFingerprint);

        $this->getJson('/api/v1/content/pdp-layout')
            ->assertStatus(503)
            ->assertJsonPath('error.code', 'content_invalid');
    }

    public function test_public_pdp_layout_strips_unknown_section_fields(): void
    {
        $payload = PdpLayoutContentDefinition::defaultPayload();
        $payload['sections'][0]['internal_note'] = 'do-not-leak';
        $payload['sections'][1]['private'] = ['secret' => true];

        $service = $this->service();
        $service->saveDraft(
            PdpLayoutContentDefinition::KEY,
            PdpLayoutContentDefinition::TYPE,
            $payload,
            0,
            $this->actorFingerprint,
        );
        $service->publish(PdpLayoutContentDefinition::KEY, 1, $this->actorFingerprint);

        $response = $this->getJson('/api/v1/content/pdp-layout')->assertOk();
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
