<?php

namespace Tests\Feature;

use Tests\TestCase;

final class DashboardRoleSessionTest extends TestCase
{
    private const USERNAME = 'admin';

    private const PASSWORD = 'Walka-Admin-Test-Password-2026';

    protected function setUp(): void
    {
        parent::setUp();

        config()->set('walka.dashboard_username', self::USERNAME);
        config()->set('walka.dashboard_password', self::PASSWORD);
    }

    public function test_login_persists_only_the_stable_role_key_not_a_capability_list(): void
    {
        config()->set('walka_dashboard.role', 'media_editor');

        $this->post('/admin/login', [
            'username' => self::USERNAME,
            'password' => self::PASSWORD,
        ])
            ->assertRedirect(route('admin.dashboard'))
            ->assertSessionHas('walka_admin_dashboard_authenticated', true)
            ->assertSessionHas('walka_admin_dashboard_role', 'media_editor')
            ->assertSessionMissing('walka_admin_dashboard_capabilities');
    }

    public function test_unknown_configured_role_fails_closed_at_login(): void
    {
        config()->set('walka_dashboard.role', 'database_authored_superuser');

        $this->post('/admin/login', [
            'username' => self::USERNAME,
            'password' => self::PASSWORD,
        ])
            ->assertSessionHasErrors('password')
            ->assertSessionMissing('walka_admin_dashboard_authenticated')
            ->assertSessionMissing('walka_admin_dashboard_role');
    }
}
