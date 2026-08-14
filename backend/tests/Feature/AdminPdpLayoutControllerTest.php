<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use App\Models\ContentRevision;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AdminPdpLayoutControllerTest extends TestCase
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
            'walka_admin_dashboard_actor' => hash('sha256', 'cms-012-pdp-layout-test'),
        ];
    }

    public function test_pdp_layout_editor_is_protected_and_bootstraps_safe_manifest(): void
    {
        $this->get('/admin/content/pdp/layout')->assertRedirect(route('admin.login'));

        $this->withSession($this->session)
            ->get(route('admin.content.pdp.layout.edit'))
            ->assertOk()
            ->assertSee('Product Detail section order & visibility', false)
            ->assertSee('Commerce boundary');

        $entry = ContentEntry::query()->where('content_key', 'pdp.layout')->firstOrFail();
        $this->assertSame('pdp.layout', $entry->content_type);
        $this->assertSame(1, $entry->revision);
        $this->assertNull($entry->published_revision);
        $this->assertSame(
            ['gallery', 'identity', 'variants', 'usage', 'facts', 'editorial', 'specifications', 'amazon_trust'],
            array_column($entry->draft_payload['sections'], 'id'),
        );
    }

    public function test_owner_can_reorder_hide_optional_sections_and_publish(): void
    {
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->patch(route('admin.content.pdp.layout.update'), $this->formPayload(
                revision: 1,
                order: [
                    'gallery' => 1,
                    'identity' => 2,
                    'variants' => 3,
                    'usage' => 8,
                    'facts' => 4,
                    'editorial' => 7,
                    'specifications' => 5,
                    'amazon_trust' => 6,
                ],
                visible: [
                    'gallery' => 1,
                    'identity' => 1,
                    'variants' => 1,
                    'usage' => 0,
                    'facts' => 1,
                    'editorial' => 0,
                    'specifications' => 1,
                    'amazon_trust' => 1,
                ],
            ))
            ->assertRedirect(route('admin.content.pdp.layout.edit'));

        $entry->refresh();
        $this->assertSame(2, $entry->revision);
        $this->assertSame(
            ['gallery', 'identity', 'variants', 'facts', 'specifications', 'amazon_trust', 'editorial', 'usage'],
            array_column($entry->draft_payload['sections'], 'id'),
        );
        $this->assertFalse($this->section($entry, 'usage')['visible']);
        $this->assertFalse($this->section($entry, 'editorial')['visible']);

        $this->withSession($this->session)
            ->post(route('admin.content.pdp.layout.publish'), ['revision' => 2])
            ->assertRedirect(route('admin.content.pdp.layout.edit'));

        $entry->refresh();
        $this->assertSame(3, $entry->published_revision);

        $this->getJson('/api/v1/content/pdp-layout')
            ->assertOk()
            ->assertJsonPath('data.key', 'pdp.layout')
            ->assertJsonPath('data.revision', 3)
            ->assertJsonPath('data.payload.sections.3.id', 'facts')
            ->assertJsonPath('data.payload.sections.7.id', 'usage')
            ->assertJsonPath('data.payload.sections.7.visible', false);
    }

    public function test_direct_request_cannot_hide_protected_sections_and_duplicate_order_is_rejected(): void
    {
        $entry = $this->bootstrap();
        $payload = $this->formPayload(revision: 1);
        $payload['visible']['gallery'] = 0;
        $payload['visible']['facts'] = 0;
        $payload['visible']['amazon_trust'] = 0;

        $this->withSession($this->session)
            ->patch(route('admin.content.pdp.layout.update'), $payload)
            ->assertRedirect(route('admin.content.pdp.layout.edit'));

        $entry->refresh();
        $this->assertTrue($this->section($entry, 'gallery')['visible']);
        $this->assertTrue($this->section($entry, 'facts')['visible']);
        $this->assertTrue($this->section($entry, 'amazon_trust')['visible']);
        $this->assertSame(1, $entry->revision);

        $duplicate = $this->formPayload(revision: 1);
        $duplicate['order']['editorial'] = 7;
        $duplicate['order']['specifications'] = 7;

        $this->withSession($this->session)
            ->from(route('admin.content.pdp.layout.edit'))
            ->patch(route('admin.content.pdp.layout.update'), $duplicate)
            ->assertRedirect(route('admin.content.pdp.layout.edit'))
            ->assertSessionHasErrors('order');

        $entry->refresh();
        $this->assertSame(1, $entry->revision);
    }

    public function test_stale_edit_is_blocked_and_restore_never_auto_publishes(): void
    {
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->post(route('admin.content.pdp.layout.publish'), ['revision' => 1])
            ->assertRedirect();

        $changed = $this->formPayload(revision: 2);
        $changed['visible']['editorial'] = 0;
        $this->withSession($this->session)
            ->patch(route('admin.content.pdp.layout.update'), $changed)
            ->assertRedirect();

        $this->withSession($this->session)
            ->patch(route('admin.content.pdp.layout.update'), $this->formPayload(revision: 2))
            ->assertRedirect(route('admin.content.pdp.layout.edit'))
            ->assertSessionHasErrors('revision');

        $this->withSession($this->session)
            ->post(route('admin.content.pdp.layout.restore'), [
                'revision' => 3,
                'source_revision' => 1,
            ])
            ->assertRedirect(route('admin.content.pdp.layout.edit'));

        $entry->refresh();
        $this->assertSame(4, $entry->revision);
        $this->assertTrue($this->section($entry, 'editorial')['visible']);
        $this->assertSame(2, $entry->published_revision);
        $this->assertTrue($this->publishedSection($entry, 'editorial')['visible']);

        $latest = ContentRevision::query()->latest('revision')->firstOrFail();
        $this->assertSame('draft_restored', $latest->action);
        $this->assertSame(1, $latest->source_revision);
    }

    private function bootstrap(): ContentEntry
    {
        $this->withSession($this->session)
            ->get(route('admin.content.pdp.layout.edit'))
            ->assertOk();

        return ContentEntry::query()->where('content_key', 'pdp.layout')->firstOrFail();
    }

    private function formPayload(
        int $revision,
        ?array $order = null,
        ?array $visible = null,
    ): array {
        return [
            'revision' => $revision,
            'order' => $order ?? [
                'gallery' => 1,
                'identity' => 2,
                'variants' => 3,
                'usage' => 4,
                'facts' => 5,
                'editorial' => 6,
                'specifications' => 7,
                'amazon_trust' => 8,
            ],
            'visible' => $visible ?? [
                'gallery' => 1,
                'identity' => 1,
                'variants' => 1,
                'usage' => 1,
                'facts' => 1,
                'editorial' => 1,
                'specifications' => 1,
                'amazon_trust' => 1,
            ],
        ];
    }

    private function section(ContentEntry $entry, string $id): array
    {
        foreach ($entry->draft_payload['sections'] as $section) {
            if ($section['id'] === $id) {
                return $section;
            }
        }

        $this->fail("Missing draft section $id");
    }

    private function publishedSection(ContentEntry $entry, string $id): array
    {
        foreach ($entry->published_payload['sections'] as $section) {
            if ($section['id'] === $id) {
                return $section;
            }
        }

        $this->fail("Missing published section $id");
    }
}
