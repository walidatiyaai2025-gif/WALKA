<?php

namespace Tests\Feature;

use App\Models\Product;
use App\Models\ProductVariant;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class CatalogPresentationReconciliationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        config()->set('walka.dashboard_username', 'admin');
        config()->set('walka.dashboard_password', 'Walka-Admin-Test-Password-2026');
        config()->set('walka_dashboard.role', 'owner');
        $this->seed(WalkaCatalogSeeder::class);
    }

    public function test_dashboard_short_description_and_swatch_round_trip_to_public_catalog(): void
    {
        $session = [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_role' => 'owner',
            'walka_admin_dashboard_actor' => hash('sha256', 'presentation-reconcile'),
        ];

        $drawer = Product::query()->findOrFail('drawer-organizer');
        $this->withSession($session)
            ->patch(route('admin.catalog.products.update', ['product' => $drawer->id]), [
                'revision' => $drawer->revision,
                'name' => $drawer->name,
                'short_description' => '  Premium drawer organization for everyday spaces.  ',
                'category_id' => $drawer->category_id ?? $drawer->category,
                'features_text' => implode("\n", $drawer->features ?? []),
                'facts_json' => json_encode($drawer->facts ?? [], JSON_THROW_ON_ERROR),
                'sort_order' => $drawer->sort_order,
                'is_visible' => '1',
            ])
            ->assertRedirect(route('admin.catalog'));

        $white = ProductVariant::query()->findOrFail('drawer-organizer:white');
        $this->withSession($session)
            ->patch(route('admin.catalog.variants.update', ['variant' => $white->id]), [
                'revision' => $white->revision,
                'color' => $white->color,
                'swatch_hex' => '#aabbcc',
                'pantone' => $white->pantone,
                'asin' => $white->asin,
                'sort_order' => $white->sort_order,
                'is_visible' => '1',
            ])
            ->assertRedirect(route('admin.catalog'));

        $this->assertDatabaseHas('products', [
            'id' => 'drawer-organizer',
            'short_description' => 'Premium drawer organization for everyday spaces.',
        ]);
        $this->assertDatabaseHas('product_variants', [
            'id' => 'drawer-organizer:white',
            'swatch_hex' => '#AABBCC',
        ]);

        $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonFragment([
                'id' => 'drawer-organizer',
                'short_description' => 'Premium drawer organization for everyday spaces.',
            ])
            ->assertJsonFragment([
                'id' => 'drawer-organizer:white',
                'swatch_hex' => '#AABBCC',
            ]);
    }

    public function test_product_short_description_is_bounded_and_optional(): void
    {
        $session = [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_role' => 'owner',
        ];
        $drawer = Product::query()->findOrFail('drawer-organizer');

        $this->withSession($session)
            ->patch(route('admin.catalog.products.update', ['product' => $drawer->id]), [
                'revision' => $drawer->revision,
                'name' => $drawer->name,
                'short_description' => str_repeat('x', 501),
                'category_id' => $drawer->category_id ?? $drawer->category,
                'features_text' => implode("\n", $drawer->features ?? []),
                'facts_json' => json_encode($drawer->facts ?? [], JSON_THROW_ON_ERROR),
                'sort_order' => $drawer->sort_order,
                'is_visible' => '1',
            ])
            ->assertSessionHasErrors('short_description');

        $drawer->refresh();
        $this->withSession($session)
            ->patch(route('admin.catalog.products.update', ['product' => $drawer->id]), [
                'revision' => $drawer->revision,
                'name' => $drawer->name,
                'short_description' => '   ',
                'category_id' => $drawer->category_id ?? $drawer->category,
                'features_text' => implode("\n", $drawer->features ?? []),
                'facts_json' => json_encode($drawer->facts ?? [], JSON_THROW_ON_ERROR),
                'sort_order' => $drawer->sort_order,
                'is_visible' => '1',
            ])
            ->assertRedirect(route('admin.catalog'));

        $this->assertDatabaseHas('products', [
            'id' => 'drawer-organizer',
            'short_description' => null,
        ]);
    }
}
