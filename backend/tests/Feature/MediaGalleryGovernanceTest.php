<?php

namespace Tests\Feature;

use App\Enums\MediaAssetLifecycle;
use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use App\Models\MediaAsset;
use App\Models\MediaDerivative;
use App\Models\MediaGallery;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Services\MediaGalleryService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class MediaGalleryGovernanceTest extends TestCase
{
    use RefreshDatabase;

    private MediaGalleryService $service;
    private Product $product;
    private ProductVariant $variant;
    private string $actor;
    private array $session;

    protected function setUp(): void
    {
        parent::setUp();

        $this->service = app(MediaGalleryService::class);
        $this->actor = hash('sha256', 'cms-032-gallery-test');
        $this->session = [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_actor' => $this->actor,
        ];

        $this->product = Product::query()->create([
            'id' => 'drawer-organizer',
            'name' => 'WALKA Drawer Organizer',
            'category' => 'drawer-organization',
            'features' => [],
            'facts' => [],
            'sort_order' => 1,
        ]);
        $this->variant = ProductVariant::query()->create([
            'id' => 'drawer-organizer:white',
            'product_id' => $this->product->id,
            'color' => 'White',
            'pantone' => null,
            'asin' => 'B0FQN4DCTG',
            'sort_order' => 1,
        ]);
    }

    public function test_gallery_admin_workspace_and_mutations_are_protected(): void
    {
        $this->get('/admin/media/galleries')->assertRedirect(route('admin.login'));
        $this->put('/admin/media/galleries/products/'.$this->product->id)->assertRedirect(route('admin.login'));
        $this->put('/admin/media/galleries/variants/'.$this->variant->id)->assertRedirect(route('admin.login'));
    }

    public function test_product_gallery_is_atomic_ordered_and_revision_guarded(): void
    {
        $first = $this->admittedAsset('Drawer White hero');
        $second = $this->admittedAsset('Drawer White detail');

        $gallery = $this->service->replaceProductGallery(
            $this->product,
            [
                ['media_asset_id' => $second->id, 'position' => 0],
                ['media_asset_id' => $first->id, 'position' => 1],
            ],
            0,
            $this->actor,
        );

        $this->assertSame(1, $gallery->revision);
        $this->assertSame(
            [$second->id, $first->id],
            $gallery->items->pluck('media_asset_id')->all(),
        );

        try {
            $this->service->replaceProductGallery(
                $this->product,
                [['media_asset_id' => $first->id, 'position' => 0]],
                0,
                $this->actor,
            );
            $this->fail('Expected stale revision rejection.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey('revision', $exception->errors());
        }

        $unchanged = MediaGallery::query()->with('items')->findOrFail($gallery->id);
        $this->assertSame(1, $unchanged->revision);
        $this->assertSame(
            [$second->id, $first->id],
            $unchanged->items->pluck('media_asset_id')->all(),
        );
    }

    public function test_non_admitted_wrong_purpose_missing_canonical_and_duplicate_media_fail_closed(): void
    {
        $admitted = $this->admittedAsset('Eligible product');
        $draft = $this->asset('Draft product', MediaAssetLifecycle::Draft, MediaAssetPurpose::Product, true);
        $wrongPurpose = $this->asset('Home visual', MediaAssetLifecycle::Admitted, MediaAssetPurpose::Home, true);
        $missingCanonical = $this->asset('No canonical', MediaAssetLifecycle::Admitted, MediaAssetPurpose::Product, false);

        foreach ([$draft, $wrongPurpose, $missingCanonical] as $invalid) {
            try {
                $this->service->replaceProductGallery(
                    $this->product,
                    [['media_asset_id' => $invalid->id, 'position' => 0]],
                    0,
                    $this->actor,
                );
                $this->fail('Expected media eligibility rejection.');
            } catch (ValidationException $exception) {
                $this->assertArrayHasKey('items', $exception->errors());
            }
            $this->assertSame(0, MediaGallery::query()->count());
        }

        try {
            $this->service->replaceProductGallery(
                $this->product,
                [
                    ['media_asset_id' => $admitted->id, 'position' => 0],
                    ['media_asset_id' => $admitted->id, 'position' => 1],
                ],
                0,
                $this->actor,
            );
            $this->fail('Expected duplicate media rejection.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey('items', $exception->errors());
        }

        $this->assertSame(0, MediaGallery::query()->count());
    }

    public function test_duplicate_or_non_contiguous_positions_and_over_limit_fail_before_mutation(): void
    {
        $assets = [];
        for ($index = 0; $index < MediaGalleryService::MAX_ITEMS + 1; $index++) {
            $assets[] = $this->admittedAsset('Product media '.$index);
        }

        $invalidSets = [
            [
                ['media_asset_id' => $assets[0]->id, 'position' => 0],
                ['media_asset_id' => $assets[1]->id, 'position' => 0],
            ],
            [
                ['media_asset_id' => $assets[0]->id, 'position' => 0],
                ['media_asset_id' => $assets[1]->id, 'position' => 2],
            ],
            array_map(
                fn (MediaAsset $asset, int $position): array => [
                    'media_asset_id' => $asset->id,
                    'position' => $position,
                ],
                $assets,
                array_keys($assets),
            ),
        ];

        foreach ($invalidSets as $items) {
            try {
                $this->service->replaceProductGallery(
                    $this->product,
                    $items,
                    0,
                    $this->actor,
                );
                $this->fail('Expected gallery position/count rejection.');
            } catch (ValidationException $exception) {
                $this->assertArrayHasKey('items', $exception->errors());
            }
        }

        $this->assertSame(0, MediaGallery::query()->count());
    }

    public function test_variant_public_gallery_uses_product_fallback_only_without_explicit_items(): void
    {
        $productAsset = $this->admittedAsset('Product fallback');
        $variantAsset = $this->admittedAsset('White variant primary');

        $this->service->replaceProductGallery(
            $this->product,
            [['media_asset_id' => $productAsset->id, 'position' => 0]],
            0,
            $this->actor,
        );

        $fallback = $this->getJson('/api/v1/media/galleries/variants/'.$this->variant->id)
            ->assertOk()
            ->assertJsonPath('data.source', 'product_fallback')
            ->assertJsonPath('data.items.0.media_id', $productAsset->id);
        $fallback->assertJsonMissingPath('data.items.0.canonical.storage_path');
        $fallback->assertJsonMissingPath('data.items.0.canonical.storage_disk');

        $this->service->replaceVariantGallery(
            $this->variant,
            [['media_asset_id' => $variantAsset->id, 'position' => 0]],
            0,
            $this->actor,
        );

        $this->getJson('/api/v1/media/galleries/variants/'.$this->variant->id)
            ->assertOk()
            ->assertJsonPath('data.source', 'variant')
            ->assertJsonPath('data.items.0.media_id', $variantAsset->id)
            ->assertJsonMissingPath('data.items.0.canonical.storage_path')
            ->assertJsonMissingPath('data.items.0.canonical.storage_disk');
    }

    public function test_archived_assigned_media_is_filtered_without_falling_back_over_explicit_variant_gallery(): void
    {
        $productAsset = $this->admittedAsset('Product fallback');
        $variantAsset = $this->admittedAsset('Variant assigned then archived');

        $this->service->replaceProductGallery(
            $this->product,
            [['media_asset_id' => $productAsset->id, 'position' => 0]],
            0,
            $this->actor,
        );
        $this->service->replaceVariantGallery(
            $this->variant,
            [['media_asset_id' => $variantAsset->id, 'position' => 0]],
            0,
            $this->actor,
        );

        $variantAsset->forceFill([
            'lifecycle' => MediaAssetLifecycle::Archived,
            'archived_at' => now(),
        ])->save();

        $this->getJson('/api/v1/media/galleries/variants/'.$this->variant->id)
            ->assertOk()
            ->assertJsonPath('data.source', 'variant')
            ->assertJsonCount(0, 'data.items');
    }

    public function test_admin_replace_reorders_and_stale_request_leaves_current_gallery_unchanged(): void
    {
        $first = $this->admittedAsset('First');
        $second = $this->admittedAsset('Second');

        $this->withSession($this->session)
            ->put(route('admin.media.galleries.products.update', $this->product), [
                'expected_revision' => 0,
                'media_asset_ids' => [$first->id, $second->id],
            ])
            ->assertRedirect(route('admin.media.galleries.index'))
            ->assertSessionHas('status');

        $gallery = MediaGallery::query()->with('items')->firstOrFail();
        $this->assertSame([$first->id, $second->id], $gallery->items->pluck('media_asset_id')->all());

        $this->withSession($this->session)
            ->from(route('admin.media.galleries.index'))
            ->put(route('admin.media.galleries.products.update', $this->product), [
                'expected_revision' => 0,
                'media_asset_ids' => [$second->id],
            ])
            ->assertRedirect(route('admin.media.galleries.index'))
            ->assertSessionHasErrors('revision');

        $gallery->refresh()->load('items');
        $this->assertSame(1, $gallery->revision);
        $this->assertSame([$first->id, $second->id], $gallery->items->pluck('media_asset_id')->all());
    }

    private function admittedAsset(string $label): MediaAsset
    {
        return $this->asset($label, MediaAssetLifecycle::Admitted, MediaAssetPurpose::Product, true);
    }

    private function asset(
        string $label,
        MediaAssetLifecycle $lifecycle,
        MediaAssetPurpose $purpose,
        bool $canonical,
    ): MediaAsset {
        $fingerprint = hash('sha256', 'asset|'.$label.'|'.$purpose->value.'|'.$lifecycle->value);
        $asset = MediaAsset::query()->create([
            'purpose' => $purpose,
            'lifecycle' => $lifecycle,
            'source_reference' => 'cms-032-test-source',
            'original_filename' => str($label)->slug()->append('.png')->toString(),
            'original_mime' => 'image/png',
            'original_bytes' => 1024,
            'original_width' => 1024,
            'original_height' => 1024,
            'original_sha256' => hash('sha256', 'source|'.$label.'|'.$purpose->value.'|'.$lifecycle->value),
            'semantic_label' => $label,
            'created_by_fingerprint' => $fingerprint,
            'updated_by_fingerprint' => $fingerprint,
            'admitted_at' => $lifecycle === MediaAssetLifecycle::Admitted ? now() : null,
            'archived_at' => $lifecycle === MediaAssetLifecycle::Archived ? now() : null,
        ]);

        if ($canonical) {
            MediaDerivative::query()->create([
                'media_asset_id' => $asset->id,
                'kind' => MediaDerivativeKind::Canonical,
                'storage_disk' => 'private-production-media',
                'storage_path' => 'canonical/'.$asset->id.'.png',
                'mime' => 'image/png',
                'bytes' => 2048,
                'width' => 1024,
                'height' => 1024,
                'sha256' => hash('sha256', 'canonical|'.$label.'|'.$purpose->value.'|'.$lifecycle->value),
                'created_by_fingerprint' => $fingerprint,
            ]);
        }

        return $asset->refresh()->load('canonicalDerivative');
    }
}
