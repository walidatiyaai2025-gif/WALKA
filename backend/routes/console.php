<?php

use App\Enums\DashboardRole;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Services\CmsMetadataBackupService;
use App\Services\CmsProductionSmokeService;
use App\Services\ContentScheduleService;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('walka:content-schedule-run', function () {
    /** @var ContentScheduleService $service */
    $service = app(ContentScheduleService::class);
    $result = $service->runDue();
    $this->info(sprintf(
        'WALKA content schedule run: published=%d unpublished=%d stale=%d',
        $result['published'],
        $result['unpublished'],
        $result['stale'],
    ));

    return 0;
})->purpose('Apply due governed CMS publish/unpublish transitions idempotently');

Schedule::command('walka:content-schedule-run')->everyMinute()->withoutOverlapping();

Artisan::command('walka:cms-backup {path? : Private JSON output path; defaults under storage/app/private/backups}', function () {
    /** @var CmsMetadataBackupService $service */
    $service = app(CmsMetadataBackupService::class);
    $package = $service->export();
    $path = trim((string) ($this->argument('path') ?? ''));
    if ($path === '') {
        $path = storage_path('app/private/backups/walka-cms-'.now()->utc()->format('Ymd-His').'.json');
    }

    File::ensureDirectoryExists(dirname($path));
    try {
        $json = json_encode($package, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR);
    } catch (JsonException $error) {
        $this->error('Could not encode metadata backup: '.$error->getMessage());

        return 1;
    }
    File::put($path, $json."\n");
    $this->info('WALKA metadata backup written.');
    $this->line('path='.$path);
    $this->line('sha256='.$package['sha256']);

    return 0;
})->purpose('Export a canonical private CMS/catalog/media metadata backup; no binary media or secrets');

Artisan::command('walka:cms-backup-validate {path : Candidate metadata backup JSON path}', function () {
    $path = (string) $this->argument('path');
    if (! File::isFile($path)) {
        $this->error('Backup file does not exist.');

        return 1;
    }

    try {
        $decoded = json_decode(File::get($path), true, 128, JSON_THROW_ON_ERROR);
    } catch (JsonException $error) {
        $this->error('Backup JSON is invalid: '.$error->getMessage());

        return 1;
    }
    if (! is_array($decoded)) {
        $this->error('Backup root must be a JSON object.');

        return 1;
    }

    /** @var CmsMetadataBackupService $service */
    $service = app(CmsMetadataBackupService::class);
    try {
        $result = $service->validatePackage($decoded);
    } catch (Throwable $error) {
        $this->error('WALKA metadata restore validation FAILED: '.$error->getMessage());

        return 1;
    }

    $this->info('WALKA metadata restore validation: PASS (zero mutations).');
    $this->line('sha256='.$result['sha256']);

    return 0;
})->purpose('Dry-run validate a WALKA metadata restore package without writing production state');

Artisan::command('walka:cms-smoke {--live-base-url= : Optional live HTTP(S) API base URL} {--no-flutter-source : Allow backend-only deployment checkout} {--json : Emit machine-readable JSON}', function () {
    /** @var CmsProductionSmokeService $service */
    $service = app(CmsProductionSmokeService::class);
    $report = $service->run(
        liveBaseUrl: ($this->option('live-base-url') ?: null),
        requireFlutterSource: ! (bool) $this->option('no-flutter-source'),
    );

    if ((bool) $this->option('json')) {
        try {
            $this->line(json_encode($report, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR));
        } catch (JsonException $error) {
            $this->error('Could not encode smoke report: '.$error->getMessage());

            return 1;
        }
    } else {
        $this->table(
            ['Status', 'Layer', 'Check', 'Detail'],
            array_map(fn (array $row): array => [$row['status'], $row['layer'], $row['id'], $row['detail']], $report['checks']),
        );
        $this->line(sprintf(
            'summary: passed=%d failed=%d total=%d',
            $report['summary']['passed'],
            $report['summary']['failed'],
            $report['summary']['total'],
        ));
    }

    if ($report['summary']['failed'] > 0) {
        $this->error('WALKA CMS production smoke: FAIL.');

        return 1;
    }

    $this->info('WALKA CMS production smoke: PASS.');

    return 0;
})->purpose('Run the read-only Admin/API/Flutter CMS production smoke matrix');

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
    $dashboardRole = trim((string) config('walka_dashboard.role', ''));
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
        'Dashboard role',
        DashboardRole::tryFrom($dashboardRole) !== null,
        $dashboardRole === '' ? 'WALKA_ADMIN_DASHBOARD_ROLE is missing' : "WALKA_ADMIN_DASHBOARD_ROLE={$dashboardRole}"
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
    } catch (Throwable $error) {
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
