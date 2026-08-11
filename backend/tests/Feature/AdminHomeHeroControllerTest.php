<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use App\Models\ContentRevision;
use App\Services\ContentRevisionService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AdminHomeHeroControllerTest extends TestCase
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
            'walka_admin_dashboard_actor' => hash('sha256', 'cms-020-home-hero-test'),
        ];
    }

    public function test_home_hero_editor_is_protected_and_bootstraps_safe_bundled_copy(): void
    {
        $this->get('/admin/content/home/hero')->assertRedirect(route('admin.login'));

        $this->withSession($this->session)
            ->get(route('admin.content.home.hero.edit'))
            ->assertOk()
            ->assertSee('Home Hero')
            ->assertSee('Organize Better.')
            ->assertSee('SHOP PRODUCTS');

        $entry = ContentEntry::query()->where('content_key', 'home.hero')->firstOrFail();
        $this->assertSame('home.hero', $entry->content_type);
        $this->assertSame(1, $entry->revision);
        $this->assertNull($entry->published_revision);
        $this->assertSame("Organize Better.\nLive Better.", $entry->draft_payload['title']);

        $revision = ContentRevision::query()->firstOrFail();
        $this->assertSame('draft_created', $revision->action);
    }

    public function test_typed_editor_saves_and_publishes_home_copy_to_the_public_contract(): void
    {
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->patch(route('admin.content.home.hero.update'), [
                'revision' => 1,
                'eyebrow' => 'A BETTER WALKA HOME',
                'title' => 'Backend Controlled Home',
                'body' => 'Owner-edited copy delivered safely without a new app release.',
                'shop_label' => 'BROWSE WALKA',
                'search_label' => 'FIND PRODUCTS',
            ])
            ->assertRedirect(route('admin.content.home.hero.edit'));

        $entry->refresh();
        $this->assertSame(2, $entry->revision);
        $this->assertSame('Backend Controlled Home', $entry->draft_payload['title']);
        $this->assertNull($entry->published_payload);

        $this->withSession($this->session)
            ->post(route('admin.content.home.hero.publish'), ['revision' => 2])
            ->assertRedirect(route('admin.content.home.hero.edit'));

        $entry->refresh();
        $this->assertSame(3, $entry->published_revision);

        $this->getJson('/api/v1/content/home')
            ->assertOk()
            ->assertJsonPath('data.revision', 3)
            ->assertJsonPath('data.payload.title', 'Backend Controlled Home')
            ->assertJsonPath('data.payload.shop_label', 'BROWSE WALKA');
    }

    public function test_typed_editor_uses_the_same_limits_as_public_delivery_contract(): void
    {
        $this->bootstrap();

        $this->withSession($this->session)
            ->from(route('admin.content.home.hero.edit'))
            ->patch(route('admin.content.home.hero.update'), [
                'revision' => 1,
                'eyebrow' => str_repeat('E', 121),
                'title' => 'Valid title',
                'body' => 'Valid body',
                'shop_label' => 'SHOP',
                'search_label' => 'SEARCH',
            ])
            ->assertRedirect(route('admin.content.home.hero.edit'))
            ->assertSessionHasErrors('eyebrow');

        $entry = ContentEntry::query()->where('content_key', 'home.hero')->firstOrFail();
        $this->assertSame(1, $entry->revision);
    }

    public function test_stale_typed_edit_is_blocked_without_overwriting_current_draft(): void
    {
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->patch(route('admin.content.home.hero.update'), $this->payload(revision: 1, title: 'Current Hero'))
            ->assertRedirect();

        $this->withSession($this->session)
            ->patch(route('admin.content.home.hero.update'), $this->payload(revision: 1, title: 'Stale Hero'))
            ->assertRedirect(route('admin.content.home.hero.edit'))
            ->assertSessionHasErrors('revision');

        $entry->refresh();
        $this->assertSame(2, $entry->revision);
        $this->assertSame('Current Hero', $entry->draft_payload['title']);
    }

    public function test_history_restore_creates_a_new_private_draft_and_does_not_auto_publish(): void
    {
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->post(route('admin.content.home.hero.publish'), ['revision' => 1])
            ->assertRedirect();

        $this->withSession($this->session)
            ->patch(route('admin.content.home.hero.update'), $this->payload(revision: 2, title: 'Second Hero'))
            ->assertRedirect();

        $this->withSession($this->session)
            ->post(route('admin.content.home.hero.restore'), [
                'revision' => 3,
                'source_revision' => 1,
            ])
            ->assertRedirect(route('admin.content.home.hero.edit'));

        $entry->refresh();
        $this->assertSame(4, $entry->revision);
        $this->assertSame("Organize Better.\nLive Better.", $entry->draft_payload['title']);
        $this->assertSame("Organize Better.\nLive Better.", $entry->published_payload['title']);
        $this->assertSame(2, $entry->published_revision);

        $latest = ContentRevision::query()->latest('revision')->firstOrFail();
        $this->assertSame('draft_restored', $latest->action);
        $this->assertSame(1, $latest->source_revision);
    }

    public function test_public_home_contract_discards_unknown_generic_payload_keys(): void
    {
        $entry = $this->bootstrap();
        $payload = array_merge($entry->draft_payload, [
            'internal_note' => 'must never be public',
            'secret_like_value' => 'do-not-leak',
        ]);

        $service = app(ContentRevisionService::class);
        $service->saveDraft(
            'home.hero',
            'home.hero',
            $payload,
            1,
            $this->session['walka_admin_dashboard_actor'],
        );
        $service->publish(
            'home.hero',
            2,
            $this->session['walka_admin_dashboard_actor'],
        );

        $response = $this->getJson('/api/v1/content/home')->assertOk();
        $raw = $response->getContent();
        $this->assertStringNotContainsString('internal_note', $raw);
        $this->assertStringNotContainsString('secret_like_value', $raw);
        $this->assertStringNotContainsString('do-not-leak', $raw);
    }

    private function bootstrap(): ContentEntry
    {
        $this->withSession($this->session)
            ->get(route('admin.content.home.hero.edit'))
            ->assertOk();

        return ContentEntry::query()->where('content_key', 'home.hero')->firstOrFail();
    }

    private function payload(int $revision, string $title): array
    {
        return [
            'revision' => $revision,
            'eyebrow' => 'PREMIUM WALKA',
            'title' => $title,
            'body' => 'Typed Home Hero body.',
            'shop_label' => 'SHOP PRODUCTS',
            'search_label' => 'SEARCH COLLECTION',
        ];
    }
}
