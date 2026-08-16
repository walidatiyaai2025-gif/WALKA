<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use App\Services\Content\StorefrontCopyContentDefinition;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class StorefrontCopyFavoritesContractTest extends TestCase
{
    use RefreshDatabase;

    public function test_default_contract_and_admin_editor_include_governed_favorites_copy(): void
    {
        $defaults = StorefrontCopyContentDefinition::defaultPayload();

        $this->assertSame('Favorites', $defaults['favorites_heading']);
        $this->assertSame('Explore products', $defaults['favorites_explore_label']);
        $this->assertSame('Save favorite', $defaults['pdp_favorite_add_label']);
        $this->assertSame('Remove favorite', $defaults['pdp_favorite_remove_label']);

        config()->set('walka.dashboard_username', 'admin');
        config()->set('walka.dashboard_password', 'Walka-Admin-Test-Password-2026');
        $session = [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_actor' => hash('sha256', 'favorites-copy-test'),
        ];

        $this->withSession($session)
            ->get(route('admin.content.storefront.copy.edit'))
            ->assertOk()
            ->assertSee('Favorites screen')
            ->assertSee('Favorite add label');

        $entry = ContentEntry::query()
            ->where('content_key', StorefrontCopyContentDefinition::KEY)
            ->firstOrFail();
        $this->assertSame(1, $entry->revision);
        $this->assertSame('Favorites', $entry->draft_payload['favorites_heading']);
    }

    public function test_old_identical_published_and_draft_payload_gets_one_audited_revision_bump(): void
    {
        $payload = $this->legacyPayload('Live categories');
        $entry = ContentEntry::query()->create([
            'content_key' => StorefrontCopyContentDefinition::KEY,
            'content_type' => StorefrontCopyContentDefinition::TYPE,
            'revision' => 2,
            'published_revision' => 2,
            'draft_payload' => $payload,
            'published_payload' => $payload,
            'published_at' => now()->subMinute(),
        ]);

        $this->runFavoritesMigration();
        $entry->refresh();

        $this->assertSame(3, $entry->revision);
        $this->assertSame(3, $entry->published_revision);
        $this->assertSame('Favorites', $entry->draft_payload['favorites_heading']);
        $this->assertSame($entry->draft_payload, $entry->published_payload);
        $this->assertDatabaseHas('content_revisions', [
            'content_entry_id' => $entry->id,
            'revision' => 3,
            'action' => 'publish_migrated',
            'source_revision' => 2,
        ]);

        $this->runFavoritesMigration();
        $entry->refresh();
        $this->assertSame(3, $entry->revision, 'Migration must be idempotent.');
    }

    public function test_divergent_unpublished_draft_is_preserved_with_separate_migration_revision(): void
    {
        $published = $this->legacyPayload('Published categories');
        $draft = $this->legacyPayload('Private draft categories');
        $entry = ContentEntry::query()->create([
            'content_key' => StorefrontCopyContentDefinition::KEY,
            'content_type' => StorefrontCopyContentDefinition::TYPE,
            'revision' => 5,
            'published_revision' => 4,
            'draft_payload' => $draft,
            'published_payload' => $published,
            'published_at' => now()->subMinute(),
        ]);

        $this->runFavoritesMigration();
        $entry->refresh();

        $this->assertSame(7, $entry->revision);
        $this->assertSame(6, $entry->published_revision);
        $this->assertSame('Private draft categories', $entry->draft_payload['categories_heading']);
        $this->assertSame('Published categories', $entry->published_payload['categories_heading']);
        $this->assertSame('Favorites', $entry->draft_payload['favorites_heading']);
        $this->assertSame('Favorites', $entry->published_payload['favorites_heading']);
        $this->assertDatabaseHas('content_revisions', [
            'content_entry_id' => $entry->id,
            'revision' => 6,
            'action' => 'publish_migrated',
            'source_revision' => 4,
        ]);
        $this->assertDatabaseHas('content_revisions', [
            'content_entry_id' => $entry->id,
            'revision' => 7,
            'action' => 'draft_migrated',
            'source_revision' => 5,
        ]);
    }

    /**
     * @return array<string, string>
     */
    private function legacyPayload(string $heading): array
    {
        return [
            'categories_heading' => $heading,
            'categories_body' => 'Legacy categories copy.',
            'pdp_unavailable' => 'Unavailable.',
            'pdp_colors_label' => 'Colors',
            'pdp_features_label' => 'Features',
            'pdp_details_label' => 'Details',
            'pdp_buy_label' => 'Buy on Amazon',
            'pdp_asin_label' => 'ASIN',
        ];
    }

    private function runFavoritesMigration(): void
    {
        $migration = require database_path(
            'migrations/2026_08_16_000002_upgrade_storefront_copy_with_favorites.php',
        );
        $migration->up();
    }
}
