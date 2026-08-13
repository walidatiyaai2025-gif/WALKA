<?php

namespace Tests\Feature\Api\V1;

use App\Services\Content\CategoryPresentationContentDefinition;
use App\Services\ContentRevisionService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class PublishedCategoriesPresentationTest extends TestCase
{
    use RefreshDatabase;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        $this->actor = hash('sha256', 'cms-024-public-test');
    }

    public function test_categories_are_private_until_explicit_publish(): void
    {
        $this->getJson('/api/v1/content/categories')
            ->assertNotFound()
            ->assertJsonPath('error.code', 'content_not_published');

        $this->service()->saveDraft(
            CategoryPresentationContentDefinition::KEY,
            CategoryPresentationContentDefinition::TYPE,
            CategoryPresentationContentDefinition::defaultPayload(),
            0,
            $this->actor,
        );

        $this->getJson('/api/v1/content/categories')->assertNotFound();
    }

    public function test_public_categories_are_versioned_ordered_and_allowlisted(): void
    {
        $payload = [
            'categories' => [
                [
                    'id' => 'drawer-organization',
                    'display_name' => 'Drawer Edit',
                    'description' => 'Premium drawer organization.',
                    'visible' => true,
                    'internal_note' => 'never-public',
                ],
                [
                    'id' => 'lunch',
                    'display_name' => 'Lunch Edit',
                    'description' => 'Premium lunch organization.',
                    'visible' => false,
                    'target_url' => 'https://example.invalid',
                ],
            ],
            'html' => '<script>alert(1)</script>',
        ];

        $service = $this->service();
        $service->saveDraft(
            CategoryPresentationContentDefinition::KEY,
            CategoryPresentationContentDefinition::TYPE,
            $payload,
            0,
            $this->actor,
        );
        $service->publish(CategoryPresentationContentDefinition::KEY, 1, $this->actor);

        $response = $this->getJson('/api/v1/content/categories')
            ->assertOk()
            ->assertJsonPath('data.key', 'categories.presentation')
            ->assertJsonPath('data.schema_version', 1)
            ->assertJsonPath('data.revision', 2)
            ->assertJsonPath('data.payload.categories.0.id', 'drawer-organization')
            ->assertJsonPath('data.payload.categories.1.id', 'lunch')
            ->assertJsonPath('data.payload.categories.1.visible', false);

        $raw = $response->getContent();
        $this->assertStringNotContainsString('internal_note', $raw);
        $this->assertStringNotContainsString('never-public', $raw);
        $this->assertStringNotContainsString('target_url', $raw);
        $this->assertStringNotContainsString('example.invalid', $raw);
        $this->assertStringNotContainsString('<script>', $raw);
        $this->assertSame('"walka-categories-r2"', $response->headers->get('ETag'));

        $this->withHeader('If-None-Match', '"walka-categories-r2"')
            ->get('/api/v1/content/categories')
            ->assertStatus(304);
    }

    public function test_delivery_fails_closed_if_published_category_set_no_longer_matches_catalog(): void
    {
        $service = $this->service();
        $service->saveDraft(
            CategoryPresentationContentDefinition::KEY,
            CategoryPresentationContentDefinition::TYPE,
            CategoryPresentationContentDefinition::defaultPayload(),
            0,
            $this->actor,
        );
        $service->publish(CategoryPresentationContentDefinition::KEY, 1, $this->actor);

        \App\Models\Product::query()
            ->where('id', 'drawer-organizer')
            ->update(['category' => 'changed-protected-category']);

        $this->getJson('/api/v1/content/categories')
            ->assertStatus(503)
            ->assertJsonPath('error.code', 'content_invalid');
    }

    private function service(): ContentRevisionService
    {
        return app(ContentRevisionService::class);
    }
}
