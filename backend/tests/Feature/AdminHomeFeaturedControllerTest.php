<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use App\Models\ContentRevision;
use App\Models\Product;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AdminHomeFeaturedControllerTest extends TestCase
{
    use RefreshDatabase;

    private array $session;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);

        config()->set('walka.dashboard_username', 'admin');
        config()->set('walka.dashboard_password', 'Walka-Admin-Test-Password-2026');
        $this->session = [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_actor' => hash('sha256', 'cms-022-featured-test'),
        ];
    }

    public function test_editor_is_protected_and_bootstraps_current_dashboard_membership(): void
    {
        $this->get('/admin/content/home/featured')->assertRedirect(route('admin.login'));

        $this->withSession($this->session)
            ->get(route('admin.content.home.featured.edit'))
            ->assertOk()
            ->assertSee('Featured products');

        $entry = ContentEntry::query()->where('content_key', 'home.featured')->firstOrFail();
        $expected = $this->bootstrapCollection();
        $this->assertSame(1, $entry->revision);
        $this->assertNull($entry->published_revision);
        $this->assertSame($expected, $entry->draft_payload['collection_variant_ids']);
        $this->assertSame($expected[0], $entry->draft_payload['editorial_variant_id']);
    }

    public function test_owner_can_reorder_collection_variants_change_editorial_and_publish(): void
    {
        $entry = $this->bootstrap();
        $collection = array_reverse($this->alternateCollection());
        $editorial = $this->allVisibleVariantIds()[array_key_last($this->allVisibleVariantIds())];

        $this->withSession($this->session)
            ->patch(route('admin.content.home.featured.update'), [
                'revision' => 1,
                'collection_variant_ids' => $collection,
                'editorial_variant_id' => $editorial,
            ])
            ->assertRedirect(route('admin.content.home.featured.edit'));

        $entry->refresh();
        $this->assertSame(2, $entry->revision);
        $this->assertSame($collection, $entry->draft_payload['collection_variant_ids']);
        $this->assertSame($editorial, $entry->draft_payload['editorial_variant_id']);
        $this->assertNull($entry->published_payload);

        $this->withSession($this->session)
            ->post(route('admin.content.home.featured.publish'), ['revision' => 2])
            ->assertRedirect(route('admin.content.home.featured.edit'));

        $entry->refresh();
        $this->assertSame(3, $entry->published_revision);

        $this->getJson('/api/v1/content/home-featured')
            ->assertOk()
            ->assertJsonPath('data.revision', 3)
            ->assertJsonPath('data.payload.collection_variant_ids.0', $collection[0])
            ->assertJsonPath('data.payload.collection_variant_ids.1', $collection[1])
            ->assertJsonPath('data.payload.editorial_variant_id', $editorial);
    }

    public function test_duplicate_or_same_family_collection_membership_is_rejected(): void
    {
        $entry = $this->bootstrap();
        $families = $this->variantFamilies();
        $sameFamily = array_values($families[0]);
        $this->assertGreaterThanOrEqual(2, count($sameFamily));
        $otherFamily = array_values($families[1]);

        $this->withSession($this->session)
            ->from(route('admin.content.home.featured.edit'))
            ->patch(route('admin.content.home.featured.update'), [
                'revision' => 1,
                'collection_variant_ids' => [$sameFamily[0], $sameFamily[1]],
                'editorial_variant_id' => $otherFamily[0],
            ])
            ->assertRedirect(route('admin.content.home.featured.edit'))
            ->assertSessionHasErrors('collection_variant_ids');

        $entry->refresh();
        $this->assertSame(1, $entry->revision);

        $this->withSession($this->session)
            ->from(route('admin.content.home.featured.edit'))
            ->patch(route('admin.content.home.featured.update'), [
                'revision' => 1,
                'collection_variant_ids' => [$sameFamily[0], $sameFamily[0]],
                'editorial_variant_id' => $otherFamily[0],
            ])
            ->assertSessionHasErrors('collection_variant_ids');
    }

    public function test_unknown_variant_and_stale_revision_are_blocked(): void
    {
        $entry = $this->bootstrap();
        $collection = $this->alternateCollection();

        $this->withSession($this->session)
            ->from(route('admin.content.home.featured.edit'))
            ->patch(route('admin.content.home.featured.update'), [
                'revision' => 1,
                'collection_variant_ids' => $collection,
                'editorial_variant_id' => 'unknown:variant',
            ])
            ->assertSessionHasErrors('variant_ids');

        $this->withSession($this->session)
            ->patch(route('admin.content.home.featured.update'), [
                'revision' => 1,
                'collection_variant_ids' => $collection,
                'editorial_variant_id' => $collection[0],
            ])
            ->assertRedirect();

        $this->withSession($this->session)
            ->patch(route('admin.content.home.featured.update'), [
                'revision' => 1,
                'collection_variant_ids' => array_reverse($collection),
                'editorial_variant_id' => $collection[1],
            ])
            ->assertSessionHasErrors('revision');

        $entry->refresh();
        $this->assertSame(2, $entry->revision);
        $this->assertSame($collection[0], $entry->draft_payload['editorial_variant_id']);
    }

    public function test_restore_creates_new_private_draft_without_auto_publish(): void
    {
        $entry = $this->bootstrap();
        $initial = $this->bootstrapCollection();
        $changed = array_reverse($this->alternateCollection());

        $this->withSession($this->session)
            ->post(route('admin.content.home.featured.publish'), ['revision' => 1])
            ->assertRedirect();

        $this->withSession($this->session)
            ->patch(route('admin.content.home.featured.update'), [
                'revision' => 2,
                'collection_variant_ids' => $changed,
                'editorial_variant_id' => $changed[0],
            ])
            ->assertRedirect();

        $this->withSession($this->session)
            ->post(route('admin.content.home.featured.restore'), [
                'revision' => 3,
                'source_revision' => 1,
            ])
            ->assertRedirect(route('admin.content.home.featured.edit'));

        $entry->refresh();
        $this->assertSame(4, $entry->revision);
        $this->assertSame($initial, $entry->draft_payload['collection_variant_ids']);
        $this->assertSame($initial, $entry->published_payload['collection_variant_ids']);
        $this->assertSame(2, $entry->published_revision);

        $latest = ContentRevision::query()->latest('revision')->firstOrFail();
        $this->assertSame('draft_restored', $latest->action);
    }

    /** @return list<string> */
    private function bootstrapCollection(): array
    {
        return array_map(fn (array $ids): string => $ids[0], array_slice($this->variantFamilies(), 0, 2));
    }

    /** @return list<string> */
    private function alternateCollection(): array
    {
        return array_map(
            fn (array $ids): string => $ids[array_key_last($ids)],
            array_slice($this->variantFamilies(), 0, 2),
        );
    }

    /** @return list<list<string>> */
    private function variantFamilies(): array
    {
        return Product::query()
            ->where('is_visible', true)
            ->whereHas('categoryEntity', fn ($query) => $query->where('is_visible', true))
            ->whereHas('variants', fn ($query) => $query->where('is_visible', true))
            ->with(['variants' => fn ($query) => $query
                ->where('is_visible', true)
                ->orderBy('sort_order')
                ->orderBy('id')])
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get()
            ->map(fn (Product $product): array => $product->variants->pluck('id')->values()->all())
            ->values()
            ->all();
    }

    /** @return list<string> */
    private function allVisibleVariantIds(): array
    {
        return array_values(array_merge(...$this->variantFamilies()));
    }

    private function bootstrap(): ContentEntry
    {
        $this->withSession($this->session)
            ->get(route('admin.content.home.featured.edit'))
            ->assertOk();

        return ContentEntry::query()->where('content_key', 'home.featured')->firstOrFail();
    }
}
