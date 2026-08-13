<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AdminCategoryPresentationControllerTest extends TestCase
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
            'walka_admin_dashboard_actor' => hash('sha256', 'cms-024-categories-test'),
        ];
    }

    public function test_editor_is_protected_and_bootstraps_released_category_order(): void
    {
        $this->get('/admin/content/categories')->assertRedirect(route('admin.login'));

        $this->withSession($this->session)
            ->get(route('admin.content.categories.edit'))
            ->assertOk()
            ->assertSee('Categories')
            ->assertSee('drawer-organization')
            ->assertSee('lunch');

        $entry = ContentEntry::query()
            ->where('content_key', 'categories.presentation')
            ->firstOrFail();
        $this->assertSame(1, $entry->revision);
        $this->assertNull($entry->published_revision);
        $this->assertSame('lunch', $entry->draft_payload['categories'][0]['id']);
        $this->assertSame('drawer-organization', $entry->draft_payload['categories'][1]['id']);
    }

    public function test_owner_can_reorder_rename_hide_and_publish_without_changing_membership(): void
    {
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->patch(route('admin.content.categories.update'), [
                'revision' => 1,
                'categories' => [
                    [
                        'id' => 'lunch',
                        'position' => 2,
                        'display_name' => 'Lunch Collection',
                        'description' => 'Refined stainless steel lunch organization.',
                        'visible' => '0',
                    ],
                    [
                        'id' => 'drawer-organization',
                        'position' => 1,
                        'display_name' => 'Drawer Organization',
                        'description' => 'Expandable organization for calm drawers.',
                        'visible' => '1',
                    ],
                ],
            ])
            ->assertRedirect(route('admin.content.categories.edit'));

        $entry->refresh();
        $this->assertSame(2, $entry->revision);
        $this->assertSame('drawer-organization', $entry->draft_payload['categories'][0]['id']);
        $this->assertSame('lunch', $entry->draft_payload['categories'][1]['id']);
        $this->assertFalse($entry->draft_payload['categories'][1]['visible']);

        $this->withSession($this->session)
            ->post(route('admin.content.categories.publish'), ['revision' => 2])
            ->assertRedirect(route('admin.content.categories.edit'));

        $this->getJson('/api/v1/content/categories')
            ->assertOk()
            ->assertJsonPath('data.payload.categories.0.id', 'drawer-organization')
            ->assertJsonPath('data.payload.categories.0.display_name', 'Drawer Organization')
            ->assertJsonPath('data.payload.categories.1.id', 'lunch')
            ->assertJsonPath('data.payload.categories.1.visible', false);
    }

    public function test_unknown_or_missing_category_identity_is_blocked(): void
    {
        $entry = $this->bootstrap();

        $this->withSession($this->session)
            ->from(route('admin.content.categories.edit'))
            ->patch(route('admin.content.categories.update'), [
                'revision' => 1,
                'categories' => [
                    [
                        'id' => 'lunch',
                        'position' => 1,
                        'display_name' => 'Lunch',
                        'description' => 'Lunch presentation.',
                        'visible' => '1',
                    ],
                    [
                        'id' => 'unknown-category',
                        'position' => 2,
                        'display_name' => 'Unknown',
                        'description' => 'Must fail closed.',
                        'visible' => '1',
                    ],
                ],
            ])
            ->assertSessionHasErrors('categories');

        $entry->refresh();
        $this->assertSame(1, $entry->revision);
    }

    public function test_hiding_every_category_and_duplicate_positions_are_blocked(): void
    {
        $this->bootstrap();
        $base = [
            'revision' => 1,
            'categories' => [
                [
                    'id' => 'lunch',
                    'position' => 1,
                    'display_name' => 'Lunch Boxes',
                    'description' => 'Lunch presentation.',
                    'visible' => '0',
                ],
                [
                    'id' => 'drawer-organization',
                    'position' => 2,
                    'display_name' => 'Drawer Organizers',
                    'description' => 'Drawer presentation.',
                    'visible' => '0',
                ],
            ],
        ];

        $this->withSession($this->session)
            ->from(route('admin.content.categories.edit'))
            ->patch(route('admin.content.categories.update'), $base)
            ->assertSessionHasErrors('categories');

        $base['categories'][1]['visible'] = '1';
        $base['categories'][1]['position'] = 1;
        $this->withSession($this->session)
            ->from(route('admin.content.categories.edit'))
            ->patch(route('admin.content.categories.update'), $base)
            ->assertSessionHasErrors('categories.1.position');
    }

    public function test_stale_revision_cannot_overwrite_newer_category_draft(): void
    {
        $entry = $this->bootstrap();
        $payload = [
            'revision' => 1,
            'categories' => [
                [
                    'id' => 'lunch',
                    'position' => 1,
                    'display_name' => 'Lunch Edit',
                    'description' => 'Current draft.',
                    'visible' => '1',
                ],
                [
                    'id' => 'drawer-organization',
                    'position' => 2,
                    'display_name' => 'Drawer Edit',
                    'description' => 'Current draft.',
                    'visible' => '1',
                ],
            ],
        ];

        $this->withSession($this->session)
            ->patch(route('admin.content.categories.update'), $payload)
            ->assertRedirect();
        $this->withSession($this->session)
            ->patch(route('admin.content.categories.update'), $payload)
            ->assertSessionHasErrors('revision');

        $entry->refresh();
        $this->assertSame(2, $entry->revision);
    }

    private function bootstrap(): ContentEntry
    {
        $this->withSession($this->session)
            ->get(route('admin.content.categories.edit'))
            ->assertOk();

        return ContentEntry::query()
            ->where('content_key', 'categories.presentation')
            ->firstOrFail();
    }
}
