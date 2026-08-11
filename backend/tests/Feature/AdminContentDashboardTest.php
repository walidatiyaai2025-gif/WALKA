<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use App\Models\ContentRevision;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AdminContentDashboardTest extends TestCase
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
            'walka_admin_dashboard_actor' => hash('sha256', 'cms-dashboard-test'),
        ];
    }

    public function test_content_workspace_is_protected_and_navigation_is_owner_visible(): void
    {
        $this->get('/admin/content')->assertRedirect(route('admin.login'));

        $this->withSession($this->session)
            ->get('/admin/content')
            ->assertOk()
            ->assertSee('Mobile content')
            ->assertSee('Create content entry')
            ->assertSee('Content');
    }

    public function test_admin_can_create_a_private_draft_from_structured_json(): void
    {
        $this->withSession($this->session)
            ->post(route('admin.content.store'), [
                'content_key' => 'home.hero',
                'content_type' => 'home.hero',
                'payload_json' => '{"title":"Organize beautifully","subtitle":"Premium WALKA storage"}',
            ])
            ->assertRedirect();

        $entry = ContentEntry::query()->where('content_key', 'home.hero')->firstOrFail();
        $this->assertSame(1, $entry->revision);
        $this->assertNull($entry->published_revision);
        $this->assertSame('Organize beautifully', $entry->draft_payload['title']);
        $this->assertSame(1, ContentRevision::query()->count());

        $catalog = $this->getJson('/api/v1/catalog')->assertOk();
        $this->assertStringNotContainsString('Organize beautifully', $catalog->getContent());
        $this->getJson('/api/v1/content/home')->assertNotFound();
    }

    public function test_invalid_or_scalar_json_is_rejected_without_creating_content(): void
    {
        $this->withSession($this->session)
            ->from('/admin/content')
            ->post(route('admin.content.store'), [
                'content_key' => 'home.hero',
                'content_type' => 'home.hero',
                'payload_json' => '{invalid',
            ])
            ->assertRedirect('/admin/content')
            ->assertSessionHasErrors('payload_json');

        $this->withSession($this->session)
            ->from('/admin/content')
            ->post(route('admin.content.store'), [
                'content_key' => 'home.hero',
                'content_type' => 'home.hero',
                'payload_json' => '"scalar"',
            ])
            ->assertRedirect('/admin/content')
            ->assertSessionHasErrors('payload_json');

        $this->assertSame(0, ContentEntry::query()->count());
    }

    public function test_admin_can_save_preview_and_publish_a_revision_snapshot(): void
    {
        $entry = $this->createDraft();

        $this->withSession($this->session)
            ->patch(route('admin.content.draft.update', ['content' => $entry->id]), [
                'revision' => 1,
                'payload_json' => '{"title":"Draft B","enabled":true}',
            ])
            ->assertRedirect(route('admin.content.show', ['content' => $entry->id]));

        $entry->refresh();
        $this->assertSame(2, $entry->revision);
        $this->assertNull($entry->published_payload);

        $this->withSession($this->session)
            ->get(route('admin.content.show', ['content' => $entry->id]))
            ->assertOk()
            ->assertSee('Draft vs published snapshot')
            ->assertSee('Draft B')
            ->assertSee('No published snapshot yet.');

        $this->withSession($this->session)
            ->post(route('admin.content.publish', ['content' => $entry->id]), [
                'revision' => 2,
            ])
            ->assertRedirect(route('admin.content.show', ['content' => $entry->id]));

        $entry->refresh();
        $this->assertSame(3, $entry->revision);
        $this->assertSame(3, $entry->published_revision);
        $this->assertSame(['enabled' => true, 'title' => 'Draft B'], $entry->published_payload);
        $this->assertSame(3, ContentRevision::query()->count());
    }

    public function test_stale_dashboard_edit_is_blocked_and_current_content_is_preserved(): void
    {
        $entry = $this->createDraft();

        $this->withSession($this->session)
            ->patch(route('admin.content.draft.update', ['content' => $entry->id]), [
                'revision' => 1,
                'payload_json' => '{"title":"Current"}',
            ])
            ->assertRedirect();

        $this->withSession($this->session)
            ->patch(route('admin.content.draft.update', ['content' => $entry->id]), [
                'revision' => 1,
                'payload_json' => '{"title":"Stale overwrite"}',
            ])
            ->assertRedirect(route('admin.content.show', ['content' => $entry->id]))
            ->assertSessionHasErrors('revision');

        $entry->refresh();
        $this->assertSame(['title' => 'Current'], $entry->draft_payload);
        $this->assertSame(2, $entry->revision);
    }

    public function test_admin_can_restore_history_into_new_draft_without_changing_live_snapshot(): void
    {
        $entry = $this->createDraft(['title' => 'A']);

        $this->withSession($this->session)
            ->post(route('admin.content.publish', ['content' => $entry->id]), ['revision' => 1])
            ->assertRedirect();

        $this->withSession($this->session)
            ->patch(route('admin.content.draft.update', ['content' => $entry->id]), [
                'revision' => 2,
                'payload_json' => '{"title":"B"}',
            ])
            ->assertRedirect();

        $this->withSession($this->session)
            ->post(route('admin.content.restore', ['content' => $entry->id]), [
                'revision' => 3,
                'source_revision' => 1,
            ])
            ->assertRedirect(route('admin.content.show', ['content' => $entry->id]));

        $entry->refresh();
        $this->assertSame(4, $entry->revision);
        $this->assertSame(['title' => 'A'], $entry->draft_payload);
        $this->assertSame(['title' => 'A'], $entry->published_payload);
        $this->assertSame(2, $entry->published_revision);

        $latest = ContentRevision::query()->latest('revision')->firstOrFail();
        $this->assertSame('draft_restored', $latest->action);
        $this->assertSame(1, $latest->source_revision);
    }

    private function createDraft(array $payload = ['title' => 'Draft A']): ContentEntry
    {
        $this->withSession($this->session)
            ->post(route('admin.content.store'), [
                'content_key' => 'home.hero',
                'content_type' => 'home.hero',
                'payload_json' => json_encode($payload, JSON_THROW_ON_ERROR),
            ])
            ->assertRedirect();

        return ContentEntry::query()->where('content_key', 'home.hero')->firstOrFail();
    }
}
