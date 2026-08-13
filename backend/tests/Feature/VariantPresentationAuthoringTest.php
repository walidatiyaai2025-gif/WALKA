<?php

namespace Tests\Feature;

use App\Exceptions\LastVisibleVariantException;
use App\Models\CatalogAudit;
use App\Models\ProductVariant;
use App\Services\CatalogAuthoringService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use InvalidArgumentException;
use Tests\TestCase;

final class VariantPresentationAuthoringTest extends TestCase
{
    use RefreshDatabase;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        $this->actor = hash('sha256', 'cms-011-variant-test');
    }

    public function test_variant_visibility_and_order_are_revisioned_and_audited(): void
    {
        $variant = ProductVariant::query()->findOrFail('lunch-box:green');
        $asin = $variant->asin;
        $pantone = $variant->pantone;
        $productId = $variant->product_id;
        $sortOrder = $variant->sort_order;

        $updated = app(CatalogAuthoringService::class)->updateVariant(
            variantId: $variant->id,
            attributes: [
                'color' => 'Green',
                'is_visible' => false,
                'presentation_order' => 9,
            ],
            expectedRevision: $variant->revision,
            actorFingerprint: $this->actor,
        );

        $this->assertFalse((bool) $updated->getAttribute('is_visible'));
        $this->assertSame(9, (int) $updated->getAttribute('presentation_order'));
        $this->assertSame($asin, $updated->asin);
        $this->assertSame($pantone, $updated->pantone);
        $this->assertSame($productId, $updated->product_id);
        $this->assertSame($sortOrder, $updated->sort_order);
        $this->assertSame(2, $updated->revision);

        $audit = CatalogAudit::query()->sole();
        $this->assertSame('variant', $audit->target_type);
        $this->assertSame('lunch-box:green', $audit->target_id);
        $this->assertArrayHasKey('is_visible', $audit->changes);
        $this->assertArrayHasKey('presentation_order', $audit->changes);
    }

    public function test_hiding_the_final_visible_variant_is_rejected_without_audit(): void
    {
        ProductVariant::query()
            ->where('product_id', 'drawer-organizer')
            ->where('id', '!=', 'drawer-organizer:white')
            ->update(['is_visible' => false]);

        $variant = ProductVariant::query()->findOrFail('drawer-organizer:white');

        try {
            app(CatalogAuthoringService::class)->updateVariant(
                variantId: $variant->id,
                attributes: ['is_visible' => false],
                expectedRevision: $variant->revision,
                actorFingerprint: $this->actor,
            );
            $this->fail('Expected final-visible-variant protection to reject the write.');
        } catch (LastVisibleVariantException $exception) {
            $this->assertSame('drawer-organizer', $exception->productId);
        }

        $variant->refresh();
        $this->assertTrue((bool) $variant->getAttribute('is_visible'));
        $this->assertSame(1, $variant->revision);
        $this->assertDatabaseCount('catalog_audits', 0);
    }

    public function test_protected_variant_master_fields_are_not_accepted_by_authoring_service(): void
    {
        $variant = ProductVariant::query()->findOrFail('lunch-box:blue');

        $this->expectException(InvalidArgumentException::class);
        app(CatalogAuthoringService::class)->updateVariant(
            variantId: $variant->id,
            attributes: ['asin' => 'SERVER-AUTHORED-ASIN'],
            expectedRevision: $variant->revision,
            actorFingerprint: $this->actor,
        );
    }
}
