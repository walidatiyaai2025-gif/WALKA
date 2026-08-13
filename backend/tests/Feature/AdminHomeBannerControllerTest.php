<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AdminHomeBannerControllerTest extends TestCase
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
            'walka_admin_dashboard_actor' => hash('sha256', 'cms-023-banner-test'),
        ];
    }

    protected function tearDown(): void
    {
        CarbonImmutable::setTestNow();
        parent::tearDown();
    }

    public function test_editor_is_protected_and_bootstraps_disabled_private_draft(): void
    {
        $this->get('/admin/content/home/banner')->assertRedirect(route('admin.login'));

        $this->withSession($this->session)
            ->get(route('admin.content.home.banner.edit'))
            ->assertOk()
            ->assertSee('Home Banner')
            ->assertSee('SCHEDULED ANNOUNCEMENT');

        $entry = ContentEntry::query()->where('content_key', 'home.banner')->firstOrFail();
        $this->assertSame(1, $entry->revision);
        $this->assertFalse($entry->draft_payload['enabled']);
        $this->assertNull($entry->published_revision);
    }

    public function test_owner_can_save_utc_schedule_publish_and_get_active_public_banner(): void
    {
        CarbonImmutable::setTestNow('2026-08-13T10:30:00Z');
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->patch(route('admin.content.home.banner.update'), [
                'revision' => 1,
                'enabled' => '1',
                'eyebrow' => 'WALKA WEEK',
                'title' => 'A calmer week starts here',
                'body' => 'Explore organization designed to make everyday routines feel simpler.',
                'cta_label' => 'BROWSE COLLECTION',
                'cta_action' => 'browse',
                'starts_at' => '2026-08-13T10:00',
                'ends_at' => '2026-08-13T12:00',
            ])
            ->assertRedirect(route('admin.content.home.banner.edit'));

        $entry->refresh();
        $this->assertSame(2, $entry->revision);
        $this->assertSame('2026-08-13T10:00:00Z', $entry->draft_payload['starts_at']);
        $this->assertSame('2026-08-13T12:00:00Z', $entry->draft_payload['ends_at']);

        $this->withSession($this->session)
            ->post(route('admin.content.home.banner.publish'), ['revision' => 2])
            ->assertRedirect(route('admin.content.home.banner.edit'));

        $response = $this->getJson('/api/v1/content/home-banner')
            ->assertOk()
            ->assertJsonPath('data.payload.enabled', true)
            ->assertJsonPath('data.payload.cta_action', 'browse')
            ->assertJsonPath('meta.active', true);

        $this->assertStringNotContainsString('amazon', strtolower($response->getContent()));
    }

    public function test_invalid_schedule_and_unapproved_action_are_rejected(): void
    {
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->from(route('admin.content.home.banner.edit'))
            ->patch(route('admin.content.home.banner.update'), [
                'revision' => 1,
                'enabled' => '1',
                'eyebrow' => 'WALKA NOTE',
                'title' => 'Bad schedule',
                'body' => 'This draft must fail closed.',
                'cta_label' => 'BROWSE',
                'cta_action' => 'browse',
                'starts_at' => '2026-08-13T12:00',
                'ends_at' => '2026-08-13T10:00',
            ])
            ->assertSessionHasErrors('ends_at');

        $this->withSession($this->session)
            ->from(route('admin.content.home.banner.edit'))
            ->patch(route('admin.content.home.banner.update'), [
                'revision' => 1,
                'enabled' => '1',
                'eyebrow' => 'WALKA NOTE',
                'title' => 'Bad action',
                'body' => 'This draft must also fail closed.',
                'cta_label' => 'OPEN',
                'cta_action' => 'https://example.invalid',
                'starts_at' => '',
                'ends_at' => '',
            ])
            ->assertSessionHasErrors('cta_action');

        $entry->refresh();
        $this->assertSame(1, $entry->revision);
    }

    public function test_none_action_discards_cta_label_and_stale_revision_is_blocked(): void
    {
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->patch(route('admin.content.home.banner.update'), [
                'revision' => 1,
                'enabled' => '1',
                'eyebrow' => 'SERVICE NOTE',
                'title' => 'Informational announcement',
                'body' => 'No CTA is required for this informational message.',
                'cta_label' => 'SHOULD DISAPPEAR',
                'cta_action' => 'none',
                'starts_at' => '',
                'ends_at' => '',
            ])
            ->assertRedirect();

        $entry->refresh();
        $this->assertSame(2, $entry->revision);
        $this->assertNull($entry->draft_payload['cta_label']);

        $this->withSession($this->session)
            ->patch(route('admin.content.home.banner.update'), [
                'revision' => 1,
                'enabled' => '0',
                'eyebrow' => 'STALE',
                'title' => 'Stale edit',
                'body' => 'This cannot overwrite the newer draft.',
                'cta_label' => null,
                'cta_action' => 'none',
                'starts_at' => '',
                'ends_at' => '',
            ])
            ->assertSessionHasErrors('revision');
    }

    private function bootstrap(): ContentEntry
    {
        $this->withSession($this->session)
            ->get(route('admin.content.home.banner.edit'))
            ->assertOk();

        return ContentEntry::query()->where('content_key', 'home.banner')->firstOrFail();
    }
}
