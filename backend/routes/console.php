<?php

use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('walka:production-check', function () {
    $rows = [];
    $failed = 0;

    $check = function (string $name, bool $ok, string $detail) use (&$rows, &$failed): void {
        $rows[] = [$ok ? 'PASS' : 'FAIL', $name, $detail];
        if (! $ok) {
            $failed++;
        }
    };

    $environment = (string) config('app.env');
    $appUrl = rtrim((string) config('app.url'), '/');
    $appKey = (string) config('app.key');
    $dashboardUsername = trim((string) config('walka.dashboard_username'));
    $dashboardPassword = (string) config('walka.dashboard_password');
    $adminToken = (string) config('walka.admin_token');
    $sessionDriver = (string) config('session.driver');
    $sessionSameSite = (string) config('session.same_site');

    $check('Application environment', $environment === 'production', "APP_ENV={$environment}");
    $check('Debug disabled', config('app.debug') === false, 'APP_DEBUG must be false');
    $check('HTTPS application URL', str_starts_with($appUrl, 'https://'), "APP_URL={$appUrl}");
    $check('Application key', $appKey !== '', $appKey === '' ? 'APP_KEY is missing' : 'APP_KEY is configured');
    $check('Dashboard username', $dashboardUsername !== '', 'WALKA_ADMIN_DASHBOARD_USERNAME is configured');
    $check(
        'Dashboard password',
        strlen($dashboardPassword) >= 12,
        strlen($dashboardPassword) >= 12 ? 'Dashboard password length is acceptable' : 'Use at least 12 characters'
    );
    $check(
        'Catalog admin token',
        strlen($adminToken) >= 32,
        strlen($adminToken) >= 32 ? 'WALKA_ADMIN_TOKEN length is acceptable' : 'Use a random token of at least 32 characters'
    );
    $check('Secure session cookie', config('session.secure') === true, 'SESSION_SECURE_COOKIE=true');
    $check('Encrypted sessions', config('session.encrypt') === true, 'SESSION_ENCRYPT=true');
    $check('HTTP-only session cookie', config('session.http_only') === true, 'SESSION_HTTP_ONLY=true');
    $check(
        'SameSite session cookie',
        in_array($sessionSameSite, ['lax', 'strict'], true),
        "SESSION_SAME_SITE={$sessionSameSite}"
    );
    $check(
        'Persistent session driver',
        ! in_array($sessionDriver, ['array', 'cookie'], true),
        "SESSION_DRIVER={$sessionDriver}"
    );

    try {
        $products = Product::query()->count();
        $variants = ProductVariant::query()->count();
        $check('Catalog products seeded', $products > 0, "products={$products}");
        $check('Catalog variants seeded', $variants > 0, "variants={$variants}");
    } catch (\Throwable $error) {
        $check('Database/catalog readiness', false, $error->getMessage());
    }

    $this->table(['Status', 'Check', 'Detail'], $rows);

    if ($failed > 0) {
        $this->error("WALKA production readiness failed: {$failed} check(s) need attention.");

        return 1;
    }

    $this->info('WALKA production readiness: PASS. Dashboard and public API prerequisites are configured.');

    return 0;
})->purpose('Validate WALKA production deployment prerequisites before exposing /admin');
