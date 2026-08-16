<?php

namespace Tests\Feature\Api\V1;

use App\Models\CatalogAudit;
use App\Models\CatalogCategory;
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

    public function test_admin_can_author_dynamic_product_fields_and_public_catalog_reflects_them(): void
    {
        CatalogCategory::query()->create([
            'id' => 'workspace',
            'name' => 'Workspace',
            'is_visible' => true,
            'sort_order' => 9,
            'revision' => 1,
        ]);

        $response = $this->withToken(self::TOKEN)
            ->patchJson('/api/v1/admin/catalog/products/drawer-organizer', [
                'revision' => 1,
                'name' => 'WALKA Dynamic Drawer Organizer',
                'category_id' => 'workspace',
                'features' => ['Dashboard feature', 'Another feature'],
                'facts' => ['dashboard_fact' => 'dynamic'],
                'sort_order' => 17,
                'is_visible' => true,
            ])
            ->assertOk()
            ->assertJsonPath('data.revision', 2)
            ->assertJsonPath('data.name', 'WALKA Dynamic Drawer Organizer')
            ->assertJsonPath('data.category_id', 'workspace')
            ->assertJsonPath('data.facts.dashboard_fact', 'dynamic')
            ->assertJsonPath('data.sort_order', 17)
            ->assertJsonPath('data.is_visible', true);

        $this->assertSame(2, $response->json('data.revision'));

        $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonFragment([
                'id' => 'drawer-organizer',
                'name' => 'WALKA Dynamic Drawer Organizer',
                'category' => 'workspace',
            ])
            ->assertJsonFragment([
                'dashboard_fact' => 'dynamic',
            ])
            ->assertJsonMissingPath('data.0.revision');

        $this->assertSame(1, CatalogAudit::query()->count());
        $audit = CatalogAudit::query()->firstOrFail();
        $this->assertSame('product', $audit->target_type);
        $this->assertSame('drawer-organizer', $audit->target_id);
        $this->assertSame(1, $audit->from_revision);
        $this->assertSame(2, $audit->to_revision);
        $this->assertSame(hash('sha256', self::TOKEN), $audit->actor_fingerprint);
        $this->assertNotSame(self::TOKEN, $audit->actor_fingerprint);
        $this->assertArrayHasKey('category_id', $audit->changes);
        $this->assertArrayHasKey('facts', $audit->changes);
    }

    public function test_admin_can_author_dynamic_variant_color_and_commerce_fields(): void
    {
        $this->withToken(self::TOKEN)
            ->patchJson('/api/v1/admin/catalog/variants/lunch-box%3Ablue', [
                'revision' => 1,
                'color' => 'Ocean',
                'swatch_hex' => '#123ABC',
                'asin' => 'b012345679',
                'pantone' => 'PANTONE DYNAMIC U',
                'sort_order' => 11,
                'is_visible' => true,
            ])
            ->assertOk()
            ->assertJsonPath('data.id', 'lunch-box:blue')
            ->assertJsonPath('data.color', 'Ocean')
            ->assertJsonPath('data.swatch_hex', '#123ABC')
            ->assertJsonPath('data.asin', 'B012345679')
            ->assertJsonPath('data.pantone', 'PANTONE DYNAMIC U')
            ->assertJsonPath('data.sort_order', 11)
            ->assertJsonPath('data.is_visible', true)
            ->assertJsonPath('data.revision', 2);

        $variant = ProductVariant::query()->findOrFail('lunch-box:blue');
        $this->assertSame('Ocean', $variant->color);
        $this->assertSame('#123ABC', $variant->swatch_hex);
        $this->assertSame('B012345679', $variant->asin);
        $this->assertSame('PANTONE DYNAMIC U', $variant->pantone);
    }

    public function test_revision_only_product_patch_is_a_safe_noop_without_audit(): void
    {
        $before = Product::query()->findOrFail('drawer-organizer')->toArray();

        $this->withToken(self::TOKEN)
            ->patchJson('/api/v1/admin/catalog/products/drawer-organizer', [
                'revision' => 1,
            ])
            ->assertOk()
            ->assertJsonPath('data.revision', 1);

        $after = Product::query()->findOrFail('drawer-organizer')->toArray();
        $this->assertSame($before['name'], $after['name']);
        $this->assertSame($before['revision'], $after['revision']);
        $this->assertSame(0, CatalogAudit::query()->count());
    }

    public function test_only_stable_entity_keys_and_legacy_category_alias_are_prohibited_on_patch(): void
    {
        $this->withToken(self::TOKEN)
            ->patchJson('/api/v1/admin/catalog/products/drawer-organizer', [
                'revision' => 1,
                'id' => 'replacement-id',
                'category' => 'legacy-alias',
                'variants' => [],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['id', 'category', 'variants']);

        $this->withToken(self::TOKEN)
            ->patchJson('/api/v1/admin/catalog/variants/lunch-box%3Ablue', [
                'revision' => 1,
                'id' => 'replacement-variant',
                'product_id' => 'replacement-product',
                'purchase_url' => 'https://example.com/not-authoritative',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['id', 'product_id', 'purchase_url']);

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

    public function test_bootstrap_seed_does_not_restore_or_overwrite_dashboard_authored_fields(): void
    {
        CatalogCategory::query()->create([
            'id' => 'dashboard-category',
            'name' => 'Dashboard Category',
            'is_visible' => true,
            'sort_order' => 0,
            'revision' => 1,
        ]);

        $product = Product::query()->findOrFail('drawer-organizer');
        $product->name = 'Dashboard Authored Name';
        $product->features = ['Dashboard feature'];
        $product->facts = ['dashboard' => true];
        $product->category = 'dashboard-category';
        $product->category_id = 'dashboard-category';
        $product->sort_order = 41;
        $product->is_visible = false;
        $product->revision = 7;
        $product->save();

        $variant = ProductVariant::query()->findOrFail('lunch-box:blue');
        $variant->color = 'Dashboard Ocean';
        $variant->swatch_hex = '#654321';
        $variant->asin = 'B012345679';
        $variant->pantone = 'PANTONE DASHBOARD U';
        $variant->sort_order = 31;
        $variant->is_visible = false;
        $variant->revision = 4;
        $variant->save();

        $this->seed(WalkaCatalogSeeder::class);

        $product->refresh();
        $variant->refresh();

        $this->assertSame('Dashboard Authored Name', $product->name);
        $this->assertSame(['Dashboard feature'], $product->features);
        $this->assertSame(['dashboard' => true], $product->facts);
        $this->assertSame('dashboard-category', $product->category);
        $this->assertSame('dashboard-category', $product->category_id);
        $this->assertSame(41, $product->sort_order);
        $this->assertFalse($product->is_visible);
        $this->assertSame(7, $product->revision);

        $this->assertSame('Dashboard Ocean', $variant->color);
        $this->assertSame('#654321', $variant->swatch_hex);
        $this->assertSame('B012345679', $variant->asin);
        $this->assertSame('PANTONE DASHBOARD U', $variant->pantone);
        $this->assertSame(31, $variant->sort_order);
        $this->assertFalse($variant->is_visible);
        $this->assertSame(4, $variant->revision);
    }
}
