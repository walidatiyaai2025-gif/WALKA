<?php

namespace Tests\Feature;

use App\Enums\MediaAssetLifecycle;
use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use App\Models\CatalogCategory;
use App\Models\MediaAsset;
use App\Models\Product;
use App\Models\SurfaceMediaItem;
use App\Services\MediaLibraryService;
use App\Services\SurfaceMediaService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class SurfaceMediaServiceTest extends TestCase
{
    use RefreshDatabase;

    private SurfaceMediaService $surfaceMedia;

    private MediaLibraryService $media;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        $this->surfaceMedia = app(SurfaceMediaService::class);
        $this->media = app(MediaLibraryService::class);
        $this->actor = hash('sha256', 'cms-033-surface-service-test');
    }

    public function test_structural_slots_plus_dashboard_category_slots_are_purpose_bound(): void
    {
        $definitions = SurfaceMediaService::slotDefinitions();

        $this->assertSame([
            'home.hero',
            'home.editorial.small_changes',
            'category:drawer-organization',
            'category:lunch',
        ], array_keys($definitions));
        $this->assertSame(MediaAssetPurpose::Home, $definitions['home.hero']['purpose']);
        $this->assertSame(MediaAssetPurpose::Editorial, $definitions['home.editorial.small_changes']['purpose']);
        $this->assertSame(MediaAssetPurpose::Category, $definitions['category:lunch']['purpose']);
        $this->assertSame(1, $definitions['home.hero']['max_items']);

        CatalogCategory::query()->create([
            'id' => 'travel',
            'name' => 'Travel',
            'sort_order' => 50,
            'is_visible' => true,
            'revision' => 1,
        ]);
        $this->assertArrayHasKey('category:travel', SurfaceMediaService::slotDefinitions());

        $this->expectException(ValidationException::class);
        $this->surfaceMedia->definition('home.remote-widget-from-server');
    }

    public function test_each_slot_accepts_only_admitted_purpose_correct_canonical_media(): void
    {
        $home = $this->admittedAsset('home', MediaAssetPurpose::Home);
        $editorial = $this->admittedAsset('editorial', MediaAssetPurpose::Editorial);
        $category = $this->admittedAsset('category', MediaAssetPurpose::Category);

        $this->surfaceMedia->replace(
            'home.hero',
            [$home->id],
            SurfaceMediaService::fingerprint([]),
            $this->actor,
        );
        $this->surfaceMedia->replace(
            'home.editorial.small_changes',
            [$editorial->id],
            SurfaceMediaService::fingerprint([]),
            $this->actor,
        );
        $this->surfaceMedia->replace(
            'category:lunch',
            [$category->id],
            SurfaceMediaService::fingerprint([]),
            $this->actor,
        );

        $this->assertDatabaseHas('surface_media_items', [
            'slot_key' => 'home.hero',
            'media_asset_id' => $home->id,
            'position' => 1,
        ]);
        $this->assertDatabaseHas('surface_media_items', [
            'slot_key' => 'home.editorial.small_changes',
            'media_asset_id' => $editorial->id,
            'position' => 1,
        ]);
        $this->assertDatabaseHas('surface_media_items', [
            'slot_key' => 'category:lunch',
            'media_asset_id' => $category->id,
            'position' => 1,
        ]);
    }

    public function test_wrong_purpose_draft_missing_canonical_and_archived_media_fail_before_mutation(): void
    {
        $valid = $this->admittedAsset('valid-home', MediaAssetPurpose::Home);
        $wrongPurpose = $this->admittedAsset('wrong-category', MediaAssetPurpose::Category);
        $draft = $this->draftAsset('draft-home', MediaAssetPurpose::Home);
        $missingCanonical = $this->draftAsset('missing-canonical', MediaAssetPurpose::Home);
        $missingCanonical->forceFill([
            'lifecycle' => MediaAssetLifecycle::Admitted,
            'admitted_at' => now(),
        ])->save();
        $archived = $this->admittedAsset('archived-home', MediaAssetPurpose::Home);
        $this->media->archive($archived, $this->actor);

        $this->surfaceMedia->replace(
            'home.hero',
            [$valid->id],
            SurfaceMediaService::fingerprint([]),
            $this->actor,
        );
        $currentFingerprint = SurfaceMediaService::fingerprint([$valid->id]);

        foreach ([$wrongPurpose, $draft, $missingCanonical, $archived] as $invalid) {
            try {
                $this->surfaceMedia->replace(
                    'home.hero',
                    [$invalid->id],
                    $currentFingerprint,
                    $this->actor,
                );
                $this->fail('Invalid surface media must fail.');
            } catch (ValidationException) {
                $this->assertDatabaseHas('surface_media_items', [
                    'slot_key' => 'home.hero',
                    'media_asset_id' => $valid->id,
                    'position' => 1,
                ]);
                $this->assertDatabaseMissing('surface_media_items', [
                    'slot_key' => 'home.hero',
                    'media_asset_id' => $invalid->id,
                ]);
            }
        }
    }

    public function test_stale_fingerprint_and_cardinality_violation_are_atomic(): void
    {
        $first = $this->admittedAsset('first', MediaAssetPurpose::Home);
        $second = $this->admittedAsset('second', MediaAssetPurpose::Home);

        $this->surfaceMedia->replace(
            'home.hero',
            [$first->id],
            SurfaceMediaService::fingerprint([]),
            $this->actor,
        );

        try {
            $this->surfaceMedia->replace(
                'home.hero',
                [$second->id],
                SurfaceMediaService::fingerprint([]),
                $this->actor,
            );
            $this->fail('Stale fingerprint must fail.');
        } catch (ValidationException) {
            $this->assertSame(
                [$first->id],
                SurfaceMediaItem::query()
                    ->where('slot_key', 'home.hero')
                    ->orderBy('position')
                    ->pluck('media_asset_id')
                    ->all(),
            );
        }

        try {
            $this->surfaceMedia->replace(
                'home.hero',
                [$first->id, $second->id],
                SurfaceMediaService::fingerprint([$first->id]),
                $this->actor,
            );
            $this->fail('Slot cardinality must fail.');
        } catch (ValidationException) {
            $this->assertSame(
                [$first->id],
                SurfaceMediaItem::query()
                    ->where('slot_key', 'home.hero')
                    ->orderBy('position')
                    ->pluck('media_asset_id')
                    ->all(),
            );
        }
    }

    public function test_category_slot_is_owned_by_category_entity_and_publication_follows_catalog_eligibility(): void
    {
        $asset = $this->admittedAsset('category-lunch', MediaAssetPurpose::Category);

        Product::query()->where('category_id', 'lunch')->delete();

        $this->surfaceMedia->replace(
            'category:lunch',
            [$asset->id],
            SurfaceMediaService::fingerprint([]),
            $this->actor,
        );
        $this->assertDatabaseHas('surface_media_items', [
            'slot_key' => 'category:lunch',
            'media_asset_id' => $asset->id,
        ]);
        $this->assertNull(
            collect($this->surfaceMedia->publicPayload())->firstWhere('slot_key', 'category:lunch'),
        );

        CatalogCategory::query()->whereKey('lunch')->delete();
        $this->expectException(ValidationException::class);
        $this->surfaceMedia->replace(
            'category:lunch',
            [$asset->id],
            SurfaceMediaService::fingerprint([$asset->id]),
            $this->actor,
        );
    }

    public function test_archived_assigned_media_fails_closed_at_public_delivery(): void
    {
        $asset = $this->admittedAsset('delivery-home', MediaAssetPurpose::Home);
        $this->surfaceMedia->replace(
            'home.hero',
            [$asset->id],
            SurfaceMediaService::fingerprint([]),
            $this->actor,
        );
        $this->media->archive($asset, $this->actor);

        $this->expectException(ValidationException::class);
        $this->surfaceMedia->publicPayload();
    }

    private function admittedAsset(string $suffix, MediaAssetPurpose $purpose): MediaAsset
    {
        $asset = $this->draftAsset($suffix, $purpose);
        $this->media->attachDerivative($asset, [
            'kind' => MediaDerivativeKind::Canonical->value,
            'storage_disk' => 'private-media',
            'storage_path' => "cms033/$suffix/canonical.png",
            'mime' => 'image/png',
            'bytes' => 220000 + strlen($suffix),
            'width' => 1400,
            'height' => 1000,
            'sha256' => hash('sha256', 'cms033-canonical-'.$suffix),
        ], $this->actor);

        return $this->media->admit($asset, $this->actor);
    }

    private function draftAsset(string $suffix, MediaAssetPurpose $purpose): MediaAsset
    {
        return $this->media->registerSource([
            'purpose' => $purpose->value,
            'source_reference' => 'cms033-source-'.$suffix,
            'original_filename' => 'surface-'.$suffix.'.png',
            'original_mime' => 'image/png',
            'original_bytes' => 420000 + strlen($suffix),
            'original_width' => 1800,
            'original_height' => 1400,
            'original_sha256' => hash('sha256', 'cms033-source-'.$suffix),
            'semantic_label' => 'CMS-033 surface asset '.$suffix,
        ], $this->actor);
    }
}
