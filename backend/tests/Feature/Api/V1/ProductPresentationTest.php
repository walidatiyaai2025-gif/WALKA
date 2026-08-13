<?php

namespace Tests\Feature\Api\V1;

use App\Exceptions\CatalogRevisionConflictException;
use App\Models\CatalogAudit;
use App\Models\Product;
use App\Services\CatalogAuthoringService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class ProductPresentationTest extends TestCase
{
    use RefreshDatabase;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        $this->actor = hash('sha256', 'cms-010-product-presentation-test');
    }

    public function test_public_catalog_filters_hidden_products_and_uses_presentation_order(): void
    {
        Product::query()->findOrFail('drawer-organizer')->forceFill([
            'presentation_order' => 20,
        ])->save();
        Product::query()->findOrFail('stainless-steel-bento-lunch-box')->forceFill([
            'short_description' => 'Office-ready lunch organization.',
            'highlights' => ['Large adult capacity', 'SUS304 tray'],
            'is_featured' => true,
            'presentation_order' => 10,
        ])->save();

        $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonPath('data.0.id', 'stainless-steel-bento-lunch-box')
            ->assertJsonPath('data.0.short_description', 'Office-ready lunch organization.')
            ->assertJsonPath('data.0.highlights.0', 'Large adult capacity')
            ->assertJsonPath('data.0.featured', true)
            ->assertJsonPath('data.0.presentation_order', 10)
            ->assertJsonPath('data.1.id', 'drawer-organizer');

        Product::query()->findOrFail('drawer-organizer')->forceFill([
            'is_visible' => false,
        ])->save();

        $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', 'stainless-steel-bento-lunch-box');
    }

    public function test_authoring_uses_revision_and_audit_without_mutating_product_master_truth(): void
    {
        $product = Product::query()->findOrFail('drawer-organizer');
        $facts = $product->facts;
        $category = $product->category;
        $sortOrder = $product->sort_order;

        $updated = app(CatalogAuthoringService::class)->updateProduct(
            productId: $product->id,
            attributes: [
                'short_description' => 'A clean expandable drawer solution.',
                'highlights' => ['8 compartments', 'Expandable layout'],
                'is_visible' => true,
                'is_featured' => true,
                'presentation_order' => 7,
            ],
            expectedRevision: $product->revision,
            actorFingerprint: $this->actor,
        );

        $this->assertSame(2, $updated->revision);
        $this->assertSame($facts, $updated->facts);
        $this->assertSame($category, $updated->category);
        $this->assertSame($sortOrder, $updated->sort_order);
        $this->assertTrue($updated->is_featured);
        $this->assertSame(7, $updated->presentation_order);

        $audit = CatalogAudit::query()->sole();
        $this->assertSame('product', $audit->target_type);
        $this->assertArrayHasKey('short_description', $audit->changes);
        $this->assertArrayHasKey('highlights', $audit->changes);
        $this->assertArrayHasKey('is_featured', $audit->changes);
        $this->assertArrayHasKey('presentation_order', $audit->changes);

        $this->expectException(CatalogRevisionConflictException::class);
        app(CatalogAuthoringService::class)->updateProduct(
            productId: $product->id,
            attributes: ['is_featured' => false],
            expectedRevision: 1,
            actorFingerprint: $this->actor,
        );
    }
}
