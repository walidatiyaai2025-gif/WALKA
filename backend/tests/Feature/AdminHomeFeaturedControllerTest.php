<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use App\Models\ContentRevision;
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

    public function test_editor_is_protected_and_bootstraps_current_safe_membership(): void
    {
        $this->get('/admin/content/home/featured')->assertRedirect(route('admin.login'));

        $this->withSession($this->session)
            ->get(route('admin.content.home.featured.edit'))
            ->assertOk()
            ->assertSee('Featured products')
            ->assertSee('lunch-box:blue')
            ->assertSee('drawer-organizer:white');

        $entry = ContentEntry::query()->where('content_key', 'home.featured')->firstOrFail();
        $this->assertSame(1, $entry->revision);
        $this->assertNull($entry->published_revision);
        $this->assertSame(
            ['lunch-box:blue', 'drawer-organizer:white'],
            $entry->draft_payload['collection_variant_ids'],
        );
    }

    public function test_owner_can_reorder_collection_variants_change_editorial_and_publish(): void
    {
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->patch(route('admin.content.home.featured.update'), [
                'revision' => 1,
                'collection_variant_ids' => ['drawer-organizer:gray', 'lunch-box:green'],
                'editorial_variant_id' => 'lunch-box:pink',
            ])
            ->assertRedirect(route('admin.content.home.featured.edit'));

        $entry->refresh();
        $this->assertSame(2, $entry->revision);
        $this->assertSame(
            ['drawer-organizer:gray', 'lunch-box:green'],
            $entry->draft_payload['collection_variant_ids'],
        );
        $this->assertSame('lunch-box:pink', $entry->draft_payload['editorial_variant_id']);
        $this->assertNull($entry->published_payload);

        $this->withSession($this->session)
            ->post(route('admin.content.home.featured.publish'), ['revision' => 2])
            ->assertRedirect(route('admin.content.home.featured.edit'));

        $entry->refresh();
        $this->assertSame(3, $entry->published_revision);

        $this->getJson('/api/v1/content/home-featured')
            ->assertOk()
            ->assertJsonPath('data.revision', 3)
            ->assertJsonPath('data.payload.collection_variant_ids.0', 'drawer-organizer:gray')
            ->assertJsonPath('data.payload.collection_variant_ids.1', 'lunch-box:green')
            ->assertJsonPath('data.payload.editorial_variant_id', 'lunch-box:pink');
    }

    public function test_duplicate_or_same_family_collection_membership_is_rejected(): void
    {
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->from(route('admin.content.home.featured.edit'))
            ->patch(route('admin.content.home.featured.update'), [
                'revision' => 1,
                'collection_variant_ids' => ['lunch-box:blue', 'lunch-box:green'],
                'editorial_variant_id' => 'drawer-organizer:white',
            ])
            ->assertRedirect(route('admin.content.home.featured.edit'))
            ->assertSessionHasErrors('collection_variant_ids');

        $entry->refresh();
        $this->assertSame(1, $entry->revision);

        $this->withSession($this->session)
            ->from(route('admin.content.home.featured.edit'))
            ->patch(route('admin.content.home.featured.update'), [
                'revision' => 1,
                'collection_variant_ids' => ['lunch-box:blue', 'lunch-box:blue'],
                'editorial_variant_id' => 'drawer-organizer:white',
            ])
            ->assertSessionHasErrors('collection_variant_ids');
    }

    public function test_unknown_variant_and_stale_revision_are_blocked(): void
    {
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->from(route('admin.content.home.featured.edit'))
            ->patch(route('admin.content.home.featured.update'), [
                'revision' => 1,
                'collection_variant_ids' => ['lunch-box:blue', 'drawer-organizer:white'],
                'editorial_variant_id' => 'unknown:variant',
            ])
            ->assertSessionHasErrors('variant_ids');

        $this->withSession($this->session)
            ->patch(route('admin.content.home.featured.update'), [
                'revision' => 1,
                'collection_variant_ids' => ['drawer-organizer:gray', 'lunch-box:green'],
                'editorial_variant_id' => 'drawer-organizer:white',
            ])
            ->assertRedirect();

        $this->withSession($this->session)
            ->patch(route('admin.content.home.featured.update'), [
                'revision' => 1,
                'collection_variant_ids' => ['drawer-organizer:white', 'lunch-box:pink'],
                'editorial_variant_id' => 'lunch-box:green',
            ])
            ->assertSessionHasErrors('revision');

        $entry->refresh();
        $this->assertSame(2, $entry->revision);
        $this->assertSame('drawer-organizer:white', $entry->draft_payload['editorial_variant_id']);
    }

    public function test_restore_creates_new_private_draft_without_auto_publish(): void
    {
        $entry = $this->bootstrap();
        $this->withSession($this->session)
            ->post(route('admin.content.home.featured.publish'), ['revision' => 1])
            ->assertRedirect();

        $this->withSession($this->session)
            ->patch(route('admin.content.home.featured.update'), [
                'revision' => 2,
                'collection_variant_ids' => ['drawer-organizer:gray', 'lunch-box:green'],
                'editorial_variant_id' => 'lunch-box:pink',
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
        $this->assertSame(
            ['lunch-box:blue', 'drawer-organizer:white'],
            $entry->draft_payload['collection_variant_ids'],
        );
        $this->assertSame(
            ['lunch-box:blue', 'drawer-organizer:white'],
            $entry->published_payload['collection_variant_ids'],
        );
        $this->assertSame(2, $entry->published_revision);

        $latest = ContentRevision::query()->latest('revision')->firstOrFail();
        $this->assertSame('draft_restored', $latest->action);
    }

    private function bootstrap(): ContentEntry
    {
        $this->withSession($this->session)
            ->get(route('admin.content.home.featured.edit'))
            ->assertOk();

        return ContentEntry::query()->where('content_key', 'home.featured')->firstOrFail();
    }
}
