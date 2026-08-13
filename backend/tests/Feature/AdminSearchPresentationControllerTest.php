<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
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

    public function test_editor_is_protected_and_bootstraps_complete_released_variant_order(): void
    {
        $this->get('/admin/content/search')->assertRedirect(route('admin.login'));

        $this->withSession($this->session)
            ->get(route('admin.content.search.edit'))
            ->assertOk()
            ->assertSee('Search presentation')
            ->assertSee('drawer-organizer:white')
            ->assertSee('lunch-box:green');

        $entry = ContentEntry::query()
            ->where('content_key', 'search.presentation')
            ->firstOrFail();

        $this->assertSame(1, $entry->revision);
        $this->assertNull($entry->published_revision);
        $this->assertCount(5, $entry->draft_payload['featured_variant_ids']);
    }

    public function test_owner_can_edit_copy_reorder_every_variant_and_publish(): void
    {
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->patch(route('admin.content.search.update'), $this->payload([
                'lunch-box:green',
                'drawer-organizer:gray',
                'lunch-box:blue',
                'drawer-organizer:white',
                'lunch-box:pink',
            ]))
            ->assertRedirect(route('admin.content.search.edit'));

        $entry->refresh();
        $this->assertSame(2, $entry->revision);
        $this->assertSame('Find WALKA', $entry->draft_payload['heading']);
        $this->assertSame('lunch-box:green', $entry->draft_payload['featured_variant_ids'][0]);
        $this->assertCount(5, $entry->draft_payload['featured_variant_ids']);

        $this->withSession($this->session)
            ->post(route('admin.content.search.publish'), ['revision' => 2])
            ->assertRedirect(route('admin.content.search.edit'));

        $this->getJson('/api/v1/content/search')
            ->assertOk()
            ->assertJsonPath('data.payload.heading', 'Find WALKA')
            ->assertJsonPath('data.payload.featured_variant_ids.0', 'lunch-box:green')
            ->assertJsonCount(5, 'data.payload.featured_variant_ids');
    }

    public function test_missing_unknown_or_duplicate_variant_identity_is_blocked(): void
    {
        $entry = $this->bootstrap();

        $missing = $this->payload([
            'drawer-organizer:white',
            'drawer-organizer:gray',
            'lunch-box:blue',
            'lunch-box:pink',
        ]);
        $this->withSession($this->session)
            ->from(route('admin.content.search.edit'))
            ->patch(route('admin.content.search.update'), $missing)
            ->assertSessionHasErrors('featured_variant_ids');

        $unknown = $this->payload([
            'drawer-organizer:white',
            'drawer-organizer:gray',
            'lunch-box:blue',
            'lunch-box:pink',
            'lunch-box:purple',
        ]);
        $this->withSession($this->session)
            ->from(route('admin.content.search.edit'))
            ->patch(route('admin.content.search.update'), $unknown)
            ->assertSessionHasErrors('featured_variant_ids');

        $duplicate = $this->payload([
            'drawer-organizer:white',
            'drawer-organizer:gray',
            'lunch-box:blue',
            'lunch-box:pink',
            'lunch-box:pink',
        ]);
        $this->withSession($this->session)
            ->from(route('admin.content.search.edit'))
            ->patch(route('admin.content.search.update'), $duplicate)
            ->assertSessionHasErrors('variants.4.id');

        $entry->refresh();
        $this->assertSame(1, $entry->revision);
    }

    public function test_stale_revision_cannot_overwrite_newer_search_draft(): void
    {
        $entry = $this->bootstrap();
        $payload = $this->payload([
            'drawer-organizer:white',
            'drawer-organizer:gray',
            'lunch-box:blue',
            'lunch-box:pink',
            'lunch-box:green',
        ]);

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
            'supporting_copy' => 'Search the complete released WALKA catalog.',
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
            'filter_labels' => [
                ['id' => 'all', 'label' => 'Everything'],
                ['id' => 'drawer-organization', 'label' => 'Drawer'],
                ['id' => 'lunch', 'label' => 'Lunch'],
            ],
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
