<?php

namespace Tests\Feature;

use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Artisan;
use Tests\TestCase;

final class ProductionReadinessCommandTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(WalkaCatalogSeeder::class);
    }

    public function test_production_check_passes_when_required_runtime_controls_are_configured(): void
    {
        config()->set('app.env', 'production');
        config()->set('app.debug', false);
        config()->set('app.url', 'https://api.walka.example');
        config()->set('app.key', 'base64:walka-production-readiness-test-key');
        config()->set('walka.dashboard_username', 'admin');
        config()->set('walka.dashboard_password', 'Walka-Strong-Production-Password');
        config()->set('walka_dashboard.role', 'owner');
        config()->set('walka.admin_token', '0123456789abcdef0123456789abcdef');
        config()->set('session.secure', true);
        config()->set('session.encrypt', true);
        config()->set('session.http_only', true);
        config()->set('session.same_site', 'lax');
        config()->set('session.driver', 'database');

        $exitCode = Artisan::call('walka:production-check');

        $this->assertSame(0, $exitCode);
        $this->assertStringContainsString('WALKA production readiness: PASS', Artisan::output());
        $this->assertStringContainsString('Dashboard role', Artisan::output());
    }

    public function test_production_check_fails_closed_for_insecure_or_missing_configuration(): void
    {
        config()->set('app.env', 'local');
        config()->set('app.debug', true);
        config()->set('app.url', 'http://localhost');
        config()->set('app.key', '');
        config()->set('walka.dashboard_password', 'short');
        config()->set('walka_dashboard.role', 'unknown_role');
        config()->set('walka.admin_token', 'short');
        config()->set('session.secure', false);
        config()->set('session.encrypt', false);
        config()->set('session.http_only', true);
        config()->set('session.same_site', 'lax');
        config()->set('session.driver', 'array');

        $exitCode = Artisan::call('walka:production-check');

        $this->assertSame(1, $exitCode);
        $this->assertStringContainsString('production readiness failed', Artisan::output());
        $this->assertStringContainsString('unknown_role', Artisan::output());
    }
}
