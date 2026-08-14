<?php

namespace App\Services;

use App\Models\ContentEntry;
use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Route;
use Throwable;

final class CmsProductionSmokeService
{
    /** @var array<string, string> */
    private const CONTENT_PATHS = [
        'home.hero' => '/api/v1/content/home',
        'home.layout' => '/api/v1/content/home-layout',
        'home.featured' => '/api/v1/content/home-featured',
        'home.banner' => '/api/v1/content/home-banner',
        'categories.presentation' => '/api/v1/content/categories',
        'search.presentation' => '/api/v1/content/search',
        'information' => '/api/v1/content/information',
        'app.maintenance_notice' => '/api/v1/content/maintenance-notice',
        'app.config' => '/api/v1/content/app-config',
        'pdp.layout' => '/api/v1/content/pdp-layout',
        'pdp.related_products' => '/api/v1/content/related-products',
    ];

    public function __construct(
        private readonly ContentHealthService $health,
        private readonly CmsMetadataBackupService $backups,
    ) {}

    /**
     * @return array{generated_at:string,summary:array{total:int,passed:int,failed:int},checks:list<array{id:string,layer:string,status:string,detail:string}>}
     */
    public function run(?string $liveBaseUrl = null, bool $requireFlutterSource = true): array
    {
        $checks = [];
        $check = function (string $id, string $layer, bool $ok, string $detail) use (&$checks): void {
            $checks[] = [
                'id' => $id,
                'layer' => $layer,
                'status' => $ok ? 'PASS' : 'FAIL',
                'detail' => $detail,
            ];
        };

        $this->runAdminChecks($check);
        $this->runBackendStateChecks($check);
        $this->runFlutterContractChecks($check, $requireFlutterSource);

        if ($liveBaseUrl !== null && trim($liveBaseUrl) !== '') {
            $this->runLiveApiChecks($check, rtrim(trim($liveBaseUrl), '/'));
        }

        $failed = count(array_filter($checks, fn (array $row): bool => $row['status'] === 'FAIL'));

        return [
            'generated_at' => now()->utc()->toIso8601ZuluString(),
            'summary' => [
                'total' => count($checks),
                'passed' => count($checks) - $failed,
                'failed' => $failed,
            ],
            'checks' => $checks,
        ];
    }

    private function runAdminChecks(callable $check): void
    {
        foreach ([
            'admin.login',
            'admin.dashboard',
            'admin.catalog',
            'admin.content.index',
            'admin.content.health',
            'admin.content.health.json',
            'admin.media.index',
            'admin.audits',
        ] as $routeName) {
            $check('admin.route.'.$routeName, 'Admin', Route::has($routeName), "route={$routeName}");
        }
    }

    private function runBackendStateChecks(callable $check): void
    {
        try {
            $products = Product::query()->count();
            $variants = ProductVariant::query()->count();
            $check('catalog.products', 'Backend', $products > 0, "products={$products}");
            $check('catalog.variants', 'Backend', $variants > 0, "variants={$variants}");

            $incoherent = ContentEntry::query()
                ->get()
                ->filter(fn (ContentEntry $entry): bool =>
                    ($entry->published_revision === null) !== ($entry->published_payload === null)
                )->count();
            $check('content.publication-coherence', 'Backend', $incoherent === 0, "incoherent_entries={$incoherent}");

            $health = $this->health->report();
            $check(
                'content.stale-schedules',
                'Backend',
                $health['summary']['stale_schedules'] === 0,
                'stale_schedules='.$health['summary']['stale_schedules'],
            );

            $backup = $this->backups->export();
            $validated = $this->backups->validatePackage($backup);
            $check(
                'metadata.backup-self-validation',
                'Backend',
                $validated['valid'] === true,
                'sha256='.$validated['sha256'],
            );
        } catch (Throwable $error) {
            $check('backend.exception', 'Backend', false, $error->getMessage());
        }

        foreach (self::CONTENT_PATHS as $key => $path) {
            $route = collect(Route::getRoutes()->getRoutes())
                ->first(fn ($route): bool => '/'.$route->uri() === $path && in_array('GET', $route->methods(), true));
            $check('api.route.'.$key, 'API', $route !== null, "GET {$path}");
        }
    }

    private function runFlutterContractChecks(callable $check, bool $required): void
    {
        $apiClientPath = base_path('../mobile/lib/core/api/walka_api_client.dart');
        $catalogPath = base_path('../mobile/lib/features/catalog/data/walka_bundled_catalog.dart');
        if (! is_file($apiClientPath) || ! is_file($catalogPath)) {
            $check(
                'flutter.source-present',
                'Flutter',
                ! $required,
                $required ? 'Required mobile source is missing from this deployment checkout.' : 'Mobile source not required in this mode.',
            );

            return;
        }

        $apiClient = file_get_contents($apiClientPath);
        $catalog = file_get_contents($catalogPath);
        if (! is_string($apiClient) || ! is_string($catalog)) {
            $check('flutter.source-readable', 'Flutter', false, 'Could not read mobile source contract files.');

            return;
        }

        $check('flutter.source-present', 'Flutter', true, 'Mobile API client and bundled catalog source are present.');
        foreach (self::CONTENT_PATHS as $key => $path) {
            $check(
                'flutter.endpoint.'.$key,
                'Flutter',
                str_contains($apiClient, $path),
                "client_path={$path}",
            );
        }
        $check(
            'flutter.purchase-mode',
            'Flutter',
            str_contains($catalog, 'amazon_redirect'),
            'Bundled storefront preserves amazon_redirect purchase architecture.',
        );
    }

    private function runLiveApiChecks(callable $check, string $baseUrl): void
    {
        if (! str_starts_with($baseUrl, 'https://') && ! str_starts_with($baseUrl, 'http://')) {
            $check('live.base-url', 'API', false, 'Live base URL must be absolute HTTP(S).');

            return;
        }

        foreach (['/api/v1/health', '/api/v1/catalog'] as $path) {
            try {
                $response = Http::acceptJson()->timeout(8)->get($baseUrl.$path);
                $check('live.'.str_replace('/', '.', trim($path, '/')), 'API', $response->successful(), "GET {$path} status={$response->status()}");
            } catch (Throwable $error) {
                $check('live.'.str_replace('/', '.', trim($path, '/')), 'API', false, $error->getMessage());
            }
        }

        $health = $this->health->report();
        foreach ($health['entries'] as $row) {
            $key = $row['key'];
            if ($row['delivery'] === null || ! isset(self::CONTENT_PATHS[$key])) {
                continue;
            }

            $path = self::CONTENT_PATHS[$key];
            try {
                $response = Http::acceptJson()->timeout(8)->get($baseUrl.$path);
                $etag = (string) $response->header('ETag');
                $cache = (string) $response->header('Cache-Control');
                $expectedEtag = $row['delivery']['etag'];
                $expectedCache = $row['delivery']['cache_control'];
                $ok = $response->successful() && $etag === $expectedEtag && $cache === $expectedCache;
                $check('live.content.'.$key, 'API', $ok, "GET {$path} status={$response->status()} etag={$etag}");

                if ($response->successful()) {
                    $conditional = Http::acceptJson()->withHeaders(['If-None-Match' => $expectedEtag])->timeout(8)->get($baseUrl.$path);
                    $check('live.cache.'.$key, 'API', $conditional->status() === 304, "conditional_status={$conditional->status()}");
                }
            } catch (Throwable $error) {
                $check('live.content.'.$key, 'API', false, $error->getMessage());
            }
        }
    }
}
