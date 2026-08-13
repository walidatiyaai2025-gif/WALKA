<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class DashboardCapabilityTest extends TestCase
{
    use RefreshDatabase;

    /** @return array<string, mixed> */
    private function authenticatedSession(): array
    {
        return [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_username' => 'admin',
            'walka_admin_dashboard_actor' => hash('sha256', 'cms-004-test-actor'),
        ];
    }

    public function test_owner_keeps_current_dashboard_access(): void
    {
        config()->set('walka_dashboard.role', 'owner');

        $this->withSession($this->authenticatedSession())
            ->get('/admin')
            ->assertOk();
        $this->withSession($this->authenticatedSession())
            ->get('/admin/catalog')
            ->assertOk();
        $this->withSession($this->authenticatedSession())
            ->get('/admin/content')
            ->assertOk();
        $this->withSession($this->authenticatedSession())
            ->get('/admin/media')
            ->assertOk();
        $this->withSession($this->authenticatedSession())
            ->get('/admin/audits')
            ->assertOk();
    }

    public function test_viewer_can_read_but_cannot_mutate_catalog_content_or_media(): void
    {
        config()->set('walka_dashboard.role', 'viewer');

        $this->withSession($this->authenticatedSession())
            ->get('/admin/catalog')
            ->assertOk();
        $this->withSession($this->authenticatedSession())
            ->get('/admin/content')
            ->assertOk();
        $this->withSession($this->authenticatedSession())
            ->get('/admin/media')
            ->assertOk();

        $this->withSession($this->authenticatedSession())
            ->patch('/admin/catalog/products/drawer-organizer', [])
            ->assertForbidden();
        $this->withSession($this->authenticatedSession())
            ->post('/admin/content', [])
            ->assertForbidden();
        $this->withSession($this->authenticatedSession())
            ->post('/admin/media/uploads', [])
            ->assertForbidden();
    }

    public function test_content_editor_and_media_editor_have_separate_write_boundaries(): void
    {
        config()->set('walka_dashboard.role', 'content_editor');
        $this->withSession($this->authenticatedSession())
            ->patch('/admin/content/home/hero', [])
            ->assertSessionHasErrors();
        $this->withSession($this->authenticatedSession())
            ->post('/admin/media/uploads', [])
            ->assertForbidden();
        $this->withSession($this->authenticatedSession())
            ->patch('/admin/catalog/products/drawer-organizer', [])
            ->assertForbidden();

        config()->set('walka_dashboard.role', 'media_editor');
        $this->withSession($this->authenticatedSession())
            ->post('/admin/media/uploads', [])
            ->assertSessionHasErrors();
        $this->withSession($this->authenticatedSession())
            ->patch('/admin/content/home/hero', [])
            ->assertForbidden();
        $this->withSession($this->authenticatedSession())
            ->patch('/admin/catalog/products/drawer-organizer', [])
            ->assertForbidden();
    }

    public function test_unknown_role_fails_closed_for_authenticated_session(): void
    {
        config()->set('walka_dashboard.role', 'not-a-real-role');

        $this->withSession($this->authenticatedSession())
            ->get('/admin')
            ->assertForbidden();
    }

    public function test_unauthenticated_request_redirects_before_capability_check(): void
    {
        config()->set('walka_dashboard.role', 'not-a-real-role');

        $this->get('/admin/catalog')
            ->assertRedirect('/admin/login');
    }

    public function test_logout_remains_available_to_any_authenticated_dashboard_session(): void
    {
        config()->set('walka_dashboard.role', 'viewer');

        $this->withSession($this->authenticatedSession())
            ->post('/admin/logout')
            ->assertRedirect('/admin/login');
    }
}
