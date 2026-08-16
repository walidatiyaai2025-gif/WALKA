<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Services\CmsProductionSmokeService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class Cms055ProductionSmokeTest extends TestCase
{
    use RefreshDatabase;

    public function test_hermetic_smoke_matrix_covers_admin_api_flutter_and_is_read_only(): void
    {
        $this->seed(WalkaCatalogSeeder::class);

        $before = [
            'products' => Product::query()->count(),
            'variants' => ProductVariant::query()->count(),
            'content' => ContentEntry::query()->count(),
        ];

        $report = app(CmsProductionSmokeService::class)->run();

        $this->assertSame(0, $report['summary']['failed'], json_encode($report, JSON_PRETTY_PRINT));
        $this->assertGreaterThan(24, $report['summary']['passed']);

        $layers = collect($report['checks'])->pluck('layer')->unique()->sort()->values()->all();
        $this->assertSame(['API', 'Admin', 'Backend', 'Flutter'], $layers);

        $ids = collect($report['checks'])->pluck('id');
        $this->assertTrue($ids->contains('admin.route.admin.content.health'));
        $this->assertTrue($ids->contains('api.route.information'));
        $this->assertTrue($ids->contains('api.route.commerce.map'));
        $this->assertTrue($ids->contains('commerce.verification-contract'));
        $this->assertTrue($ids->contains('flutter.endpoint.app.config'));
        $this->assertTrue($ids->contains('flutter.purchase-mode'));
        $this->assertTrue($ids->contains('flutter.commerce.endpoint'));
        $this->assertTrue($ids->contains('flutter.commerce.verification'));
        $this->assertTrue($ids->contains('flutter.commerce.purchase-guard'));
        $this->assertTrue($ids->contains('metadata.backup-self-validation'));

        $this->assertSame($before['products'], Product::query()->count());
        $this->assertSame($before['variants'], ProductVariant::query()->count());
        $this->assertSame($before['content'], ContentEntry::query()->count());
    }

    public function test_smoke_command_emits_machine_readable_json_and_fail_closed_exit_contract(): void
    {
        $this->seed(WalkaCatalogSeeder::class);

        $this->artisan('walka:cms-smoke', ['--json' => true])
            ->expectsOutputToContain('"failed": 0')
            ->assertExitCode(0);
    }
}
