<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use App\Models\ContentRevision;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AdminHomeLayoutControllerTest extends TestCase
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
            'walka_admin_dashboard_actor' => hash('sha256', 'cms-021-home-layout-test'),
        ];
    }

    public function test_home_layout_editor_is_protected_and_bootstraps_default_manifest(): void
    {
        $this->get('/admin/content/home/layout')->assertRedirect(route('admin.login'));

        $this->withSession($this->session)
            ->get(route('admin.content.home.layout.edit'))
            ->assertOk()
            ->assertSee('Section order & visibility', false)
            ->assertSee('Home Layout')
            ->assertSee('Everything in Its Place');

        $entry = ContentEntry::query()->where('content_key', 'home.layout')->firstOrFail();
        $this->assertSame('home.layout', $entry->content_type);
        $this->assertSame(1, $entry->revision);
        $this->assertNull($entry->published_revision);
        $this->assertSame(
            ['hero', 'benefits', 'collection', 'small_changes', 'trust'],
            array_column($entry->draft_payload['sections'], 'id'),
        );
    }

    public function test_owner_can_reorder_hide_optional_sections_edit_safe_copy_and_publish(): void
    {
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->patch(route('admin.content.home.layout.update'), $this->formPayload(
                revision: 1,
                order: [
                    'hero' => 2,
                    'benefits' => 5,
                    'collection' => 1,
                    'small_changes' => 3,
                    'trust' => 4,
                ],
                visible: [
                    'hero' => 1,
                    'benefits' => 0,
                    'collection' => 1,
                    'small_changes' => 1,
                    'trust' => 0,
                ],
                collectionTitle: 'Shop the WALKA Collection',
            ))
            ->assertRedirect(route('admin.content.home.layout.edit'));

        $entry->refresh();
        $this->assertSame(2, $entry->revision);
        $this->assertSame(
            ['collection', 'hero', 'small_changes', 'trust', 'benefits'],
            array_column($entry->draft_payload['sections'], 'id'),
        );
        $this->assertFalse($this->section($entry, 'benefits')['visible']);
        $this->assertFalse($this->section($entry, 'trust')['visible']);
        $this->assertSame('Shop the WALKA Collection', $this->section($entry, 'collection')['title']);
        $this->assertNull($entry->published_payload);

        $this->withSession($this->session)
            ->post(route('admin.content.home.layout.publish'), ['revision' => 2])
            ->assertRedirect(route('admin.content.home.layout.edit'));

        $entry->refresh();
        $this->assertSame(3, $entry->published_revision);

        $this->getJson('/api/v1/content/home-layout')
            ->assertOk()
            ->assertJsonPath('data.key', 'home.layout')
            ->assertJsonPath('data.revision', 3)
            ->assertJsonPath('data.payload.sections.0.id', 'collection')
            ->assertJsonPath('data.payload.sections.4.id', 'benefits')
            ->assertJsonPath('data.payload.sections.4.visible', false)
            ->assertJsonPath('data.payload.sections.0.title', 'Shop the WALKA Collection');
    }

    public function test_duplicate_order_positions_are_rejected_without_mutating_draft(): void
    {
        $entry = $this->bootstrap();

        $payload = $this->formPayload(revision: 1);
        $payload['order']['trust'] = 4;
        $payload['order']['small_changes'] = 4;

        $this->withSession($this->session)
            ->from(route('admin.content.home.layout.edit'))
            ->patch(route('admin.content.home.layout.update'), $payload)
            ->assertRedirect(route('admin.content.home.layout.edit'))
            ->assertSessionHasErrors('order');

        $entry->refresh();
        $this->assertSame(1, $entry->revision);
    }

    public function test_core_hero_and_collection_sections_cannot_be_hidden(): void
    {
        $entry = $this->bootstrap();
        $payload = $this->formPayload(revision: 1);
        $payload['visible']['hero'] = 0;

        $this->withSession($this->session)
            ->from(route('admin.content.home.layout.edit'))
            ->patch(route('admin.content.home.layout.update'), $payload)
            ->assertRedirect(route('admin.content.home.layout.edit'))
            ->assertSessionHasErrors('visible.hero');

        $entry->refresh();
        $this->assertSame(1, $entry->revision);
        $this->assertTrue($this->section($entry, 'hero')['visible']);
    }

    public function test_stale_layout_edit_is_blocked_and_history_restore_never_auto_publishes(): void
    {
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->post(route('admin.content.home.layout.publish'), ['revision' => 1])
            ->assertRedirect();

        $changed = $this->formPayload(revision: 2, collectionTitle: 'Changed collection heading');
        $this->withSession($this->session)
            ->patch(route('admin.content.home.layout.update'), $changed)
            ->assertRedirect();

        $this->withSession($this->session)
            ->patch(route('admin.content.home.layout.update'), $this->formPayload(
                revision: 2,
                collectionTitle: 'Stale overwrite',
            ))
            ->assertRedirect(route('admin.content.home.layout.edit'))
            ->assertSessionHasErrors('revision');

        $this->withSession($this->session)
            ->post(route('admin.content.home.layout.restore'), [
                'revision' => 3,
                'source_revision' => 1,
            ])
            ->assertRedirect(route('admin.content.home.layout.edit'));

        $entry->refresh();
        $this->assertSame(4, $entry->revision);
        $this->assertSame('Everything in Its Place', $this->section($entry, 'collection')['title']);
        $this->assertSame('Everything in Its Place', $this->publishedSection($entry, 'collection')['title']);
        $this->assertSame(2, $entry->published_revision);

        $latest = ContentRevision::query()->latest('revision')->firstOrFail();
        $this->assertSame('draft_restored', $latest->action);
        $this->assertSame(1, $latest->source_revision);
    }

    private function bootstrap(): ContentEntry
    {
        $this->withSession($this->session)
            ->get(route('admin.content.home.layout.edit'))
            ->assertOk();

        return ContentEntry::query()->where('content_key', 'home.layout')->firstOrFail();
    }

    private function formPayload(
        int $revision,
        ?array $order = null,
        ?array $visible = null,
        string $collectionTitle = 'Everything in Its Place',
    ): array {
        return [
            'revision' => $revision,
            'order' => $order ?? [
                'hero' => 1,
                'benefits' => 2,
                'collection' => 3,
                'small_changes' => 4,
                'trust' => 5,
            ],
            'visible' => $visible ?? [
                'hero' => 1,
                'benefits' => 1,
                'collection' => 1,
                'small_changes' => 1,
                'trust' => 1,
            ],
            'collection_eyebrow' => 'OUR COLLECTION',
            'collection_title' => $collectionTitle,
            'small_changes_title' => "Small Changes,\nBetter Living",
            'small_changes_body' => 'Simple solutions that bring order, beauty and peace of mind.',
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
