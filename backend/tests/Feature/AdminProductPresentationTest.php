<?php

namespace Tests\Feature;

use App\Models\CatalogAudit;
use App\Models\Product;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AdminProductPresentationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        config()->set('walka_dashboard.role', 'owner');
    }

    /** @return array<string, mixed> */
    private function session(): array
    {
        return [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_username' => 'admin',
            'walka_admin_dashboard_actor' => hash('sha256', 'cms-010-dashboard-test'),
        ];
    }

    public function test_catalog_page_exposes_governed_presentation_inputs_and_locked_truth(): void
    {
        $this->withSession($this->session())
            ->get('/admin/catalog')
            ->assertOk()
            ->assertSee('Short description')
            ->assertSee('Editorial highlights')
            ->assertSee('Presentation order')
            ->assertSee('Visible in public catalog')
            ->assertSee('Featured product')
            ->assertSee('Internal sort order')
            ->assertSee('Locked Product Master identity');
    }

    public function test_owner_can_update_presentation_and_public_catalog_reflects_it(): void
    {
        $product = Product::query()->findOrFail('drawer-organizer');
        $protectedFacts = $product->facts;
        $protectedSort = $product->sort_order;

        $this->withSession($this->session())
            ->patch('/admin/catalog/products/drawer-organizer', [
                'revision' => $product->revision,
                'name' => 'WALKA Drawer Organizer Premium',
                'features_text' => "8 compartments\nExpandable to 22.4 in",
                'short_description' => 'A premium expandable drawer organizer.',
                'highlights_text' => "Clean organization\nFlexible width",
                'presentation_controls' => '1',
                'is_visible' => '1',
                'is_featured' => '1',
                'presentation_order' => '9',
            ])
            ->assertRedirect(route('admin.catalog'));

        $product->refresh();
        $this->assertSame('A premium expandable drawer organizer.', $product->short_description);
        $this->assertSame(['Clean organization', 'Flexible width'], $product->highlights);
        $this->assertTrue($product->is_visible);
        $this->assertTrue($product->is_featured);
        $this->assertSame(9, $product->presentation_order);
        $this->assertSame($protectedFacts, $product->facts);
        $this->assertSame($protectedSort, $product->sort_order);
        $this->assertSame(2, $product->revision);
        $this->assertSame(1, CatalogAudit::query()->count());

        $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonPath('data.1.id', 'drawer-organizer')
            ->assertJsonPath('data.1.short_description', 'A premium expandable drawer organizer.')
            ->assertJsonPath('data.1.highlights.0', 'Clean organization')
            ->assertJsonPath('data.1.featured', true)
            ->assertJsonPath('data.1.presentation_order', 9);
    }

    public function test_unchecked_visibility_hides_product_without_deleting_identity(): void
    {
        $product = Product::query()->findOrFail('drawer-organizer');

        $this->withSession($this->session())
            ->patch('/admin/catalog/products/drawer-organizer', [
                'revision' => $product->revision,
                'name' => $product->name,
                'features_text' => implode("\n", $product->features),
                'presentation_controls' => '1',
                'presentation_order' => '0',
            ])
            ->assertRedirect(route('admin.catalog'));

        $this->assertDatabaseHas('products', [
            'id' => 'drawer-organizer',
            'is_visible' => false,
        ]);
        $this->assertDatabaseCount('products', 2);
        $this->assertDatabaseCount('product_variants', 5);

        $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', 'stainless-steel-bento-lunch-box');
    }
}
