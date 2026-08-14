<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use App\Models\ContentRevision;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AdminRelatedProductsControllerTest extends TestCase
{
    use RefreshDatabase;

    private array $session;

    protected function setUp(): void
    {
        parent::setUp();

        config()->set('walka.dashboard_username', 'admin');
        config()->set('walka.dashboard_password', 'Walka-Admin-Test-Password-2026');
        $this->seed(WalkaCatalogSeeder::class);

        $this->session = [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_actor' => hash('sha256', 'cms-013-related-products-test'),
        ];
    }

    public function test_editor_is_protected_and_bootstraps_stable_id_only_default(): void
    {
        $this->get('/admin/content/pdp/related-products')
            ->assertRedirect(route('admin.login'));

        $this->withSession($this->session)
            ->get(route('admin.content.pdp.related-products.edit'))
            ->assertOk()
            ->assertSee('Related products')
            ->assertSee('Commerce boundary');

        $entry = ContentEntry::query()
            ->where('content_key', 'pdp.related_products')
            ->firstOrFail();

        $this->assertSame('pdp.related_products', $entry->content_type);
        $this->assertSame(1, $entry->revision);
        $this->assertNull($entry->published_revision);
        $this->assertSame(
            ['drawer-organizer', 'stainless-steel-bento-lunch-box'],
            array_column($entry->draft_payload['relationships'], 'product_id'),
        );
        $this->assertArrayNotHasKey('url', $entry->draft_payload['relationships'][0]);
        $this->assertArrayNotHasKey('asin', $entry->draft_payload['relationships'][0]);
    }

    public function test_owner_can_save_ordered_relationships_and_publish(): void
    {
        $this->bootstrap();

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

        $entry = ContentEntry::query()->where('content_key', 'pdp.related_products')->firstOrFail();
        $this->assertSame(2, $entry->revision);
        $this->assertSame(
            ['stainless-steel-bento-lunch-box'],
            $this->relationship($entry, 'drawer-organizer')['related_product_ids'],
        );
        $this->assertSame([], $this->relationship($entry, 'stainless-steel-bento-lunch-box')['related_product_ids']);

        $this->withSession($this->session)
            ->post(route('admin.content.pdp.related-products.publish'), ['revision' => 2])
            ->assertRedirect(route('admin.content.pdp.related-products.edit'));

        $entry->refresh();
        $this->assertSame(3, $entry->published_revision);
        $this->assertSame($entry->draft_payload, $entry->published_payload);
    }

    public function test_unknown_and_self_referencing_direct_requests_fail_closed(): void
    {
        $this->bootstrap();

        $this->withSession($this->session)
            ->from(route('admin.content.pdp.related-products.edit'))
            ->patch(route('admin.content.pdp.related-products.update'), [
                'revision' => 1,
                'related' => [
                    'server-authored-product' => [
                        'drawer-organizer' => 1,
                    ],
                ],
                'order' => [],
            ])
            ->assertRedirect(route('admin.content.pdp.related-products.edit'))
            ->assertSessionHasErrors('related');

        $this->withSession($this->session)
            ->from(route('admin.content.pdp.related-products.edit'))
            ->patch(route('admin.content.pdp.related-products.update'), [
                'revision' => 1,
                'related' => [
                    'drawer-organizer' => [
                        'drawer-organizer' => 1,
                    ],
                ],
                'order' => [],
            ])
            ->assertRedirect(route('admin.content.pdp.related-products.edit'))
            ->assertSessionHasErrors('related.drawer-organizer');

        $entry = ContentEntry::query()->where('content_key', 'pdp.related_products')->firstOrFail();
        $this->assertSame(1, $entry->revision);
    }

    public function test_stale_edit_is_blocked_and_restore_creates_draft_without_auto_publish(): void
    {
        $this->bootstrap();

        $this->withSession($this->session)
            ->post(route('admin.content.pdp.related-products.publish'), ['revision' => 1])
            ->assertRedirect();

        $published = ContentEntry::query()->where('content_key', 'pdp.related_products')->firstOrFail();
        $publishedAt = $published->published_at?->toISOString();

        $this->withSession($this->session)
            ->patch(route('admin.content.pdp.related-products.update'), [
                'revision' => 2,
                'related' => [],
                'order' => [],
            ])
            ->assertRedirect();

        $this->withSession($this->session)
            ->from(route('admin.content.pdp.related-products.edit'))
            ->patch(route('admin.content.pdp.related-products.update'), [
                'revision' => 2,
                'related' => [],
                'order' => [],
            ])
            ->assertRedirect(route('admin.content.pdp.related-products.edit'))
            ->assertSessionHasErrors('revision');

        $this->withSession($this->session)
            ->post(route('admin.content.pdp.related-products.restore'), [
                'revision' => 3,
                'source_revision' => 1,
            ])
            ->assertRedirect(route('admin.content.pdp.related-products.edit'));

        $entry = ContentEntry::query()->where('content_key', 'pdp.related_products')->firstOrFail();
        $this->assertSame(4, $entry->revision);
        $this->assertSame(2, $entry->published_revision);
        $this->assertSame($publishedAt, $entry->published_at?->toISOString());
        $this->assertSame($entry->published_payload, $entry->draft_payload);

        $latest = ContentRevision::query()
            ->where('content_entry_id', $entry->id)
            ->latest('revision')
            ->firstOrFail();
        $this->assertSame('draft_restored', $latest->action);
        $this->assertSame(1, $latest->source_revision);
    }

    private function bootstrap(): ContentEntry
    {
        $this->withSession($this->session)
            ->get(route('admin.content.pdp.related-products.edit'))
            ->assertOk();

        return ContentEntry::query()->where('content_key', 'pdp.related_products')->firstOrFail();
    }

    private function relationship(ContentEntry $entry, string $productId): array
    {
        foreach ($entry->draft_payload['relationships'] as $relationship) {
            if ($relationship['product_id'] === $productId) {
                return $relationship;
            }
        }

        $this->fail("Missing related-product source $productId");
    }
}
