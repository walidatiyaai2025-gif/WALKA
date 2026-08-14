<?php

namespace Tests\Feature;

use App\Models\Product;
use App\Models\ProductVariant;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class Cms014PdpEndToEndRegressionTest extends TestCase
{
    use RefreshDatabase;

    /** @var array<string, mixed> */
    private array $session;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(WalkaCatalogSeeder::class);
        config()->set('walka_dashboard.role', 'owner');
        config()->set('walka.dashboard_username', 'admin');
        config()->set('walka.dashboard_password', 'Walka-Admin-Test-Password-2026');

        $this->session = [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_username' => 'admin',
            'walka_admin_dashboard_actor' => hash('sha256', 'cms-014-pdp-e2e-regression'),
        ];
    }

    public function test_dashboard_edits_propagate_to_public_pdp_contracts_without_mutating_commerce_truth(): void
    {
        $product = Product::query()->findOrFail('drawer-organizer');
        $protectedFacts = $product->facts;
        $protectedSortOrder = $product->sort_order;
        $protectedVariants = ProductVariant::query()
            ->where('product_id', 'drawer-organizer')
            ->orderBy('id')
            ->get()
            ->mapWithKeys(fn (ProductVariant $variant): array => [
                $variant->id => [
                    'asin' => $variant->asin,
                    'pantone' => $variant->pantone,
                    'sort_order' => $variant->sort_order,
                ],
            ])
            ->all();

        $this->withSession($this->session)
            ->patch('/admin/catalog/products/drawer-organizer', [
                'revision' => $product->revision,
                'name' => 'WALKA Drawer Organizer · CMS 014',
                'features_text' => "8 compartments\nExpandable to 22.4 in",
                'short_description' => 'Dashboard-authored PDP copy propagated end to end.',
                'highlights_text' => "CMS-controlled highlight\nStable commerce identity",
                'presentation_controls' => '1',
                'is_visible' => '1',
                'is_featured' => '1',
                'presentation_order' => '7',
            ])
            ->assertRedirect(route('admin.catalog'));

        $this->withSession($this->session)
            ->get(route('admin.content.pdp.layout.edit'))
            ->assertOk();

        $this->withSession($this->session)
            ->patch(route('admin.content.pdp.layout.update'), [
                'revision' => 1,
                'order' => [
                    'gallery' => 2,
                    'identity' => 3,
                    'variants' => 1,
                    'usage' => 8,
                    'facts' => 4,
                    'editorial' => 7,
                    'specifications' => 5,
                    'amazon_trust' => 6,
                ],
                'visible' => [
                    'gallery' => 1,
                    'identity' => 1,
                    'variants' => 1,
                    'usage' => 0,
                    'facts' => 1,
                    'editorial' => 1,
                    'specifications' => 1,
                    'amazon_trust' => 1,
                ],
            ])
            ->assertRedirect(route('admin.content.pdp.layout.edit'));

        $this->withSession($this->session)
            ->post(route('admin.content.pdp.layout.publish'), ['revision' => 2])
            ->assertRedirect(route('admin.content.pdp.layout.edit'));

        $this->withSession($this->session)
            ->get(route('admin.content.pdp.related-products.edit'))
            ->assertOk();

        $this->withSession($this->session)
            ->patch(route('admin.content.pdp.related-products.update'), [
                'revision' => 1,
                'related' => [
                    'drawer-organizer' => [
                        'stainless-steel-bento-lunch-box' => 1,
                    ],
                    'stainless-steel-bento-lunch-box' => [
                        'drawer-organizer' => 0,
                    ],
                ],
                'order' => [
                    'drawer-organizer' => [
                        'stainless-steel-bento-lunch-box' => 1,
                    ],
                    'stainless-steel-bento-lunch-box' => [
                        'drawer-organizer' => 1,
                    ],
                ],
            ])
            ->assertRedirect(route('admin.content.pdp.related-products.edit'));

        $this->withSession($this->session)
            ->post(route('admin.content.pdp.related-products.publish'), ['revision' => 2])
            ->assertRedirect(route('admin.content.pdp.related-products.edit'));

        $catalogResponse = $this->getJson('/api/v1/catalog')->assertOk();
        $catalog = collect($catalogResponse->json('data'));
        $drawer = $catalog->firstWhere('id', 'drawer-organizer');

        $this->assertIsArray($drawer);
        $this->assertSame('WALKA Drawer Organizer · CMS 014', $drawer['name']);
        $this->assertSame(
            'Dashboard-authored PDP copy propagated end to end.',
            $drawer['short_description'],
        );
        $this->assertSame('CMS-controlled highlight', $drawer['highlights'][0]);
        $this->assertTrue($drawer['featured']);
        $this->assertSame(7, $drawer['presentation_order']);

        $this->getJson('/api/v1/content/pdp-layout')
            ->assertOk()
            ->assertJsonPath('data.revision', 3)
            ->assertJsonPath('data.payload.sections.0.id', 'variants')
            ->assertJsonPath('data.payload.sections.1.id', 'gallery')
            ->assertJsonPath('data.payload.sections.7.id', 'usage')
            ->assertJsonPath('data.payload.sections.7.visible', false);

        $relatedResponse = $this->getJson('/api/v1/content/related-products')
            ->assertOk()
            ->assertJsonPath('data.revision', 3)
            ->assertJsonPath('data.payload.relationships.0.product_id', 'drawer-organizer')
            ->assertJsonPath(
                'data.payload.relationships.0.related_product_ids.0',
                'stainless-steel-bento-lunch-box',
            )
            ->assertJsonPath(
                'data.payload.relationships.1.related_product_ids',
                [],
            );
        $firstRelationship = $relatedResponse->json('data.payload.relationships.0');
        $this->assertIsArray($firstRelationship);
        $this->assertSame(
            ['product_id', 'related_product_ids'],
            array_keys($firstRelationship),
        );

        $product->refresh();
        $this->assertSame($protectedFacts, $product->facts);
        $this->assertSame($protectedSortOrder, $product->sort_order);

        $currentVariants = ProductVariant::query()
            ->where('product_id', 'drawer-organizer')
            ->orderBy('id')
            ->get()
            ->mapWithKeys(fn (ProductVariant $variant): array => [
                $variant->id => [
                    'asin' => $variant->asin,
                    'pantone' => $variant->pantone,
                    'sort_order' => $variant->sort_order,
                ],
            ])
            ->all();

        $this->assertSame($protectedVariants, $currentVariants);
    }
}
