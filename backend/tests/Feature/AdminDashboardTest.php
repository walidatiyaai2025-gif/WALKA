<?php

namespace Tests\Feature;

use App\Models\CatalogAudit;
use App\Models\Product;
use App\Models\ProductVariant;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AdminDashboardTest extends TestCase
{
    use RefreshDatabase;

    private const USERNAME = 'admin';
    private const PASSWORD = 'Walka-Admin-Test-Password-2026';

    protected function setUp(): void
    {
        parent::setUp();

        config()->set('walka.dashboard_username', self::USERNAME);
        config()->set('walka.dashboard_password', self::PASSWORD);
        config()->set('walka.admin_token', 'walka-test-admin-token-0123456789abcdef');
        $this->seed(WalkaCatalogSeeder::class);
    }

    public function test_guest_is_redirected_to_dashboard_login(): void
    {
        $this->get('/admin')
            ->assertRedirect(route('admin.login'));

        $this->get('/admin/catalog')
            ->assertRedirect(route('admin.login'));
    }

    public function test_valid_credentials_create_server_side_dashboard_session(): void
    {
        $this->post('/admin/login', [
            'username' => self::USERNAME,
            'password' => self::PASSWORD,
        ])
            ->assertRedirect(route('admin.dashboard'))
            ->assertSessionHas('walka_admin_dashboard_authenticated', true)
            ->assertSessionHas('walka_admin_dashboard_username', self::USERNAME);
    }

    public function test_invalid_credentials_do_not_authenticate(): void
    {
        $this->from('/admin/login')
            ->post('/admin/login', [
                'username' => self::USERNAME,
                'password' => 'wrong-password-value',
            ])
            ->assertRedirect('/admin/login')
            ->assertSessionHasErrors('password')
            ->assertSessionMissing('walka_admin_dashboard_authenticated');
    }

    public function test_dashboard_renders_seeded_catalog_and_api_contract_status(): void
    {
        $this->withSession(['walka_admin_dashboard_authenticated' => true])
            ->get('/admin')
            ->assertOk()
            ->assertSee('Storefront overview')
            ->assertSee('Backend readiness')
            ->assertSee('1.4.0')
            ->assertSee('AMAZON REDIRECT');
    }

    public function test_dashboard_product_edit_reuses_authoring_service_and_public_api_reflects_change(): void
    {
        $product = Product::query()->findOrFail('drawer-organizer');

        $this->withSession([
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_actor' => hash('sha256', 'dashboard-test'),
        ])->patch(route('admin.catalog.products.update', ['product' => $product->id]), [
            'revision' => $product->revision,
            'name' => 'WALKA Premium Expandable Drawer Organizer',
            'features_text' => "8 compartments\nExpandable width\nNon-slip base",
        ])->assertRedirect(route('admin.catalog'));

        $product->refresh();
        $this->assertSame('WALKA Premium Expandable Drawer Organizer', $product->name);
        $this->assertSame(['8 compartments', 'Expandable width', 'Non-slip base'], $product->features);
        $this->assertSame(2, $product->revision);
        $this->assertSame(1, CatalogAudit::query()->count());

        $this->getJson('/api/v1/catalog')
            ->assertOk()
            ->assertJsonPath('data.0.name', 'WALKA Premium Expandable Drawer Organizer')
            ->assertJsonMissingPath('data.0.revision');
    }

    public function test_dashboard_variant_edit_preserves_locked_commerce_identity(): void
    {
        $variant = ProductVariant::query()->findOrFail('lunch-box:blue');
        $asin = $variant->asin;
        $pantone = $variant->pantone;

        $this->withSession(['walka_admin_dashboard_authenticated' => true])
            ->patch(route('admin.catalog.variants.update', ['variant' => $variant->id]), [
                'revision' => $variant->revision,
                'color' => 'WALKA Blue',
            ])->assertRedirect(route('admin.catalog'));

        $variant->refresh();
        $this->assertSame('WALKA Blue', $variant->color);
        $this->assertSame($asin, $variant->asin);
        $this->assertSame($pantone, $variant->pantone);
        $this->assertSame(2, $variant->revision);
    }

    public function test_dashboard_can_sign_out(): void
    {
        $this->withSession(['walka_admin_dashboard_authenticated' => true])
            ->post('/admin/logout')
            ->assertRedirect(route('admin.login'));

        $this->get('/admin')->assertRedirect(route('admin.login'));
    }
}
