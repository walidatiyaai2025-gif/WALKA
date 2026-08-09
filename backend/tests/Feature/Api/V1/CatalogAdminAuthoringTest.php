<?php

namespace Tests\Feature\Api\V1;

use App\Models\CatalogAudit;
use App\Models\Product;
use App\Models\ProductVariant;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class CatalogAdminAuthoringTest extends TestCase
{
    use RefreshDatabase;

    private const TOKEN = 'walka-test-admin-token-0123456789abcdef';

    protected function setUp(): void
    {
        parent::setUp();

        config()->set('walka.admin_token', self::TOKEN);
        $this->seed(WalkaCatalogSeeder::class);
    }

    public function test_admin_can_author_mutable_product_copy_and_public_catalog_reflects_it(): void
    {
        $response = $this->withToken(self::TOKEN)
            ->patchJson('/api/v1/admin/catalog/products/drawer-organizer', [
                'revision' => 1,
                'name' => 'WALKA Expandable Drawer Organizer',
                'features' => ['8 compartments', 'Expandable', 'Non-slip base'],
            ])
            ->assertOk()
            ->assertJsonPath('data.revision', 2)
            ->assertJsonPath('data.name', 'WALKA Expandable Drawer Organizer');

        $this->assertSame(2, $response->json('data.revision'));

        $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonPath('data.0.id', 'drawer-organizer')
            ->assertJsonPath('data.0.name', 'WALKA Expandable Drawer Organizer')
            ->assertJsonMissingPath('data.0.revision');

        $this->assertSame(1, CatalogAudit::query()->count());
        $audit = CatalogAudit::query()->firstOrFail();
        $this->assertSame('product', $audit->target_type);
        $this->assertSame('drawer-organizer', $audit->target_id);
        $this->assertSame(1, $audit->from_revision);
        $this->assertSame(2, $audit->to_revision);
        $this->assertSame(hash('sha256', self::TOKEN), $audit->actor_fingerprint);
        $this->assertNotSame(self::TOKEN, $audit->actor_fingerprint);
        $this->assertArrayHasKey('name', $audit->changes);
    }

    public function test_admin_can_author_variant_display_color_without_changing_commerce_identity(): void
    {
        $this->withToken(self::TOKEN)
            ->patchJson('/api/v1/admin/catalog/variants/lunch-box%3Ablue', [
                'revision' => 1,
                'color' => 'WALKA Blue',
            ])
            ->assertOk()
            ->assertJsonPath('data.id', 'lunch-box:blue')
            ->assertJsonPath('data.color', 'WALKA Blue')
            ->assertJsonPath('data.asin', 'B0FQN4L8MW')
            ->assertJsonPath('data.pantone', 'PANTONE 4155 U')
            ->assertJsonPath('data.revision', 2);

        $this->assertSame('B0FQN4L8MW', ProductVariant::query()->findOrFail('lunch-box:blue')->asin);
        $this->assertSame('PANTONE 4155 U', ProductVariant::query()->findOrFail('lunch-box:blue')->pantone);
    }

    public function test_product_patch_requires_at_least_one_authorable_field(): void
    {
        $this->withToken(self::TOKEN)
            ->patchJson('/api/v1/admin/catalog/products/drawer-organizer', [
                'revision' => 1,
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['name', 'features']);

        $this->assertSame(0, CatalogAudit::query()->count());
    }

    public function test_product_master_and_stable_identity_fields_are_explicitly_prohibited(): void
    {
        $this->withToken(self::TOKEN)
            ->patchJson('/api/v1/admin/catalog/products/drawer-organizer', [
                'revision' => 1,
                'name' => 'Attempted mutation',
                'category' => 'unsafe-category',
                'facts' => ['product_weight_lb' => 9.9],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['category', 'facts']);

        $this->withToken(self::TOKEN)
            ->patchJson('/api/v1/admin/catalog/variants/lunch-box%3Ablue', [
                'revision' => 1,
                'color' => 'Attempted mutation',
                'asin' => 'B000000000',
                'pantone' => 'PANTONE 0000 U',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['asin', 'pantone']);

        $this->assertSame('B0FQN4L8MW', ProductVariant::query()->findOrFail('lunch-box:blue')->asin);
        $this->assertArrayNotHasKey('product_weight_lb', Product::query()->findOrFail('drawer-organizer')->facts);
        $this->assertSame(0, CatalogAudit::query()->count());
    }

    public function test_stale_revision_is_rejected_with_conflict_and_no_second_audit(): void
    {
        $this->withToken(self::TOKEN)
            ->patchJson('/api/v1/admin/catalog/products/drawer-organizer', [
                'revision' => 1,
                'name' => 'First committed name',
            ])
            ->assertOk()
            ->assertJsonPath('data.revision', 2);

        $this->withToken(self::TOKEN)
            ->patchJson('/api/v1/admin/catalog/products/drawer-organizer', [
                'revision' => 1,
                'name' => 'Stale overwrite attempt',
            ])
            ->assertStatus(409)
            ->assertJsonPath('error.code', 'catalog_revision_conflict')
            ->assertJsonPath('error.details.current_revision', 2);

        $this->assertSame('First committed name', Product::query()->findOrFail('drawer-organizer')->name);
        $this->assertSame(1, CatalogAudit::query()->count());
    }

    public function test_audit_endpoint_is_protected_and_never_exposes_raw_token(): void
    {
        $this->withToken(self::TOKEN)
            ->patchJson('/api/v1/admin/catalog/products/drawer-organizer', [
                'revision' => 1,
                'name' => 'Audited name',
            ])
            ->assertOk();

        $payload = $this->withToken(self::TOKEN)
            ->getJson('/api/v1/admin/catalog/audits')
            ->assertOk()
            ->assertJsonPath('data.0.target_id', 'drawer-organizer')
            ->assertJsonPath('data.0.from_revision', 1)
            ->assertJsonPath('data.0.to_revision', 2)
            ->json();

        $this->assertStringNotContainsString(self::TOKEN, json_encode($payload, JSON_THROW_ON_ERROR));
    }

    public function test_product_master_seed_reconciliation_preserves_authored_copy_but_restores_locked_fields(): void
    {
        $product = Product::query()->findOrFail('drawer-organizer');
        $product->name = 'Authored name';
        $product->features = ['Authored feature'];
        $product->facts = ['unsafe' => true];
        $product->category = 'unsafe-category';
        $product->revision = 7;
        $product->save();

        $variant = ProductVariant::query()->findOrFail('lunch-box:blue');
        $variant->color = 'Authored Blue';
        $variant->asin = 'B000000000';
        $variant->pantone = 'PANTONE 0000 U';
        $variant->revision = 4;
        $variant->save();

        $this->seed(WalkaCatalogSeeder::class);

        $product->refresh();
        $variant->refresh();

        $this->assertSame('Authored name', $product->name);
        $this->assertSame(['Authored feature'], $product->features);
        $this->assertSame('drawer-organization', $product->category);
        $this->assertArrayNotHasKey('unsafe', $product->facts);
        $this->assertSame(7, $product->revision);

        $this->assertSame('Authored Blue', $variant->color);
        $this->assertSame('B0FQN4L8MW', $variant->asin);
        $this->assertSame('PANTONE 4155 U', $variant->pantone);
        $this->assertSame(4, $variant->revision);
    }
}
