<?php

namespace Tests\Feature;

use App\Models\CatalogCategory;
use App\Models\ContentEntry;
use App\Models\Product;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AdminSearchPresentationControllerTest extends TestCase
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
            'walka_admin_dashboard_actor' => hash('sha256', 'cms-025-search-test'),
        ];
    }

    public function test_editor_is_protected_and_bootstraps_current_dashboard_variant_order(): void
    {
        $this->get('/admin/content/search')->assertRedirect(route('admin.login'));

        $this->withSession($this->session)
            ->get(route('admin.content.search.edit'))
            ->assertOk()
            ->assertSee('Search presentation');

        $entry = ContentEntry::query()
            ->where('content_key', 'search.presentation')
            ->firstOrFail();

        $this->assertSame(1, $entry->revision);
        $this->assertNull($entry->published_revision);
        $this->assertSame($this->currentVariantIds(), $entry->draft_payload['featured_variant_ids']);
        $this->assertSame($this->currentFilterIds(), array_column($entry->draft_payload['filter_labels'], 'id'));
    }

    public function test_owner_can_edit_copy_reorder_current_variants_and_publish(): void
    {
        $entry = $this->bootstrap();
        $reordered = array_reverse($this->currentVariantIds());

        $this->withSession($this->session)
            ->patch(route('admin.content.search.update'), $this->payload($reordered))
            ->assertRedirect(route('admin.content.search.edit'));

        $entry->refresh();
        $this->assertSame(2, $entry->revision);
        $this->assertSame('Find WALKA', $entry->draft_payload['heading']);
        $this->assertSame($reordered, $entry->draft_payload['featured_variant_ids']);

        $this->withSession($this->session)
            ->post(route('admin.content.search.publish'), ['revision' => 2])
            ->assertRedirect(route('admin.content.search.edit'));

        $this->getJson('/api/v1/content/search')
            ->assertOk()
            ->assertJsonPath('data.payload.heading', 'Find WALKA')
            ->assertJsonPath('data.payload.featured_variant_ids.0', $reordered[0]);
    }

    public function test_safe_featured_subset_is_allowed_without_hiding_search_catalog(): void
    {
        $entry = $this->bootstrap();
        $subset = array_slice($this->currentVariantIds(), 0, 1);

        $this->withSession($this->session)
            ->patch(route('admin.content.search.update'), $this->payload($subset))
            ->assertRedirect(route('admin.content.search.edit'))
            ->assertSessionDoesntHaveErrors();

        $entry->refresh();
        $this->assertSame(2, $entry->revision);
        $this->assertSame($subset, $entry->draft_payload['featured_variant_ids']);
    }

    public function test_unknown_or_duplicate_variant_identity_is_blocked(): void
    {
        $entry = $this->bootstrap();
        $current = $this->currentVariantIds();

        $unknown = $current;
        $unknown[count($unknown) - 1] = 'dynamic-product:unknown-variant';
        $this->withSession($this->session)
            ->from(route('admin.content.search.edit'))
            ->patch(route('admin.content.search.update'), $this->payload($unknown))
            ->assertSessionHasErrors('featured_variant_ids');

        $duplicate = $current;
        $duplicate[count($duplicate) - 1] = $duplicate[0];
        $this->withSession($this->session)
            ->from(route('admin.content.search.edit'))
            ->patch(route('admin.content.search.update'), $this->payload($duplicate))
            ->assertSessionHasErrors('variants.'.(count($duplicate) - 1).'.id');

        $entry->refresh();
        $this->assertSame(1, $entry->revision);
    }

    public function test_stale_revision_cannot_overwrite_newer_search_draft(): void
    {
        $entry = $this->bootstrap();
        $payload = $this->payload($this->currentVariantIds());

        $this->withSession($this->session)
            ->patch(route('admin.content.search.update'), $payload)
            ->assertRedirect();
        $this->withSession($this->session)
            ->patch(route('admin.content.search.update'), $payload)
            ->assertSessionHasErrors('revision');

        $entry->refresh();
        $this->assertSame(2, $entry->revision);
    }

    /**
     * @param  list<string>  $variantIds
     * @return array<string, mixed>
     */
    private function payload(array $variantIds): array
    {
        return [
            'revision' => 1,
            'heading' => 'Find WALKA',
            'supporting_copy' => 'Search the current WALKA catalog.',
            'placeholder' => 'Search WALKA products…',
            'empty_title' => 'No matches',
            'empty_body' => 'Try another product detail.',
            'variants' => collect($variantIds)
                ->values()
                ->map(fn (string $id, int $index): array => [
                    'id' => $id,
                    'position' => $index + 1,
                ])
                ->all(),
            'filter_labels' => collect($this->currentFilterIds())
                ->map(fn (string $id): array => [
                    'id' => $id,
                    'label' => $id === 'all'
                        ? 'Everything'
                        : (string) CatalogCategory::query()->whereKey($id)->value('name'),
                ])
                ->all(),
        ];
    }

    /** @return list<string> */
    private function currentVariantIds(): array
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
            ->flatMap(fn (Product $product) => $product->variants->pluck('id'))
            ->values()
            ->all();
    }

    /** @return list<string> */
    private function currentFilterIds(): array
    {
        return [
            'all',
            ...CatalogCategory::query()
                ->where('is_visible', true)
                ->whereHas('products', fn ($query) => $query
                    ->where('is_visible', true)
                    ->whereHas('variants', fn ($variants) => $variants->where('is_visible', true)))
                ->orderBy('sort_order')
                ->orderBy('id')
                ->pluck('id')
                ->all(),
        ];
    }

    private function bootstrap(): ContentEntry
    {
        $this->withSession($this->session)
            ->get(route('admin.content.search.edit'))
            ->assertOk();

        return ContentEntry::query()
            ->where('content_key', 'search.presentation')
            ->firstOrFail();
    }
}
