<?php

namespace Tests\Feature\Api\V1;

use App\Models\Product;
use App\Models\ProductVariant;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class CatalogPersistenceTest extends TestCase
{
    use RefreshDatabase;

    public function test_catalog_seeder_is_idempotent_and_preserves_stable_order(): void
    {
        $this->seed(WalkaCatalogSeeder::class);
        $this->seed(WalkaCatalogSeeder::class);

        $this->assertSame(2, Product::query()->count());
        $this->assertSame(5, ProductVariant::query()->count());
        $this->assertSame(
            ['drawer-organizer', 'stainless-steel-bento-lunch-box'],
            Product::query()->orderBy('sort_order')->pluck('id')->all(),
        );
        $this->assertSame(
            [
                'drawer-organizer:white',
                'drawer-organizer:gray',
                'lunch-box:blue',
                'lunch-box:pink',
                'lunch-box:green',
            ],
            ProductVariant::query()
                ->orderBy('product_id')
                ->orderBy('sort_order')
                ->pluck('id')
                ->all(),
        );
        $this->assertSame(
            'PANTONE 6198 U',
            ProductVariant::query()->findOrFail('lunch-box:green')->pantone,
        );
    }

    public function test_unseeded_catalog_fails_safely_and_observably(): void
    {
        $this->getJson('/api/v1/catalog')
            ->assertStatus(503)
            ->assertExactJson([
                'error' => [
                    'code' => 'catalog_unavailable',
                    'message' => 'WALKA catalog is not seeded.',
                ],
            ]);
    }

    public function test_catalog_runtime_reads_database_not_seed_blueprint(): void
    {
        $this->seed(WalkaCatalogSeeder::class);

        Product::query()->whereKey('drawer-organizer')->update([
            'name' => 'Database-backed Drawer Organizer',
        ]);

        $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonPath('data.0.name', 'Database-backed Drawer Organizer');
    }
}
