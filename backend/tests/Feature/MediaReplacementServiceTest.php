<?php

namespace Tests\Feature;

use App\Enums\MediaAssetLifecycle;
use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use App\Models\MediaAsset;
use App\Models\MediaReplacementEvent;
use App\Models\ProductMediaGalleryItem;
use App\Models\SurfaceMediaItem;
use App\Models\VariantMediaGalleryItem;
use App\Services\MediaLibraryService;
use App\Services\MediaReplacementService;
use App\Services\ProductMediaGalleryService;
use App\Services\SurfaceMediaService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use LogicException;
use Tests\TestCase;

final class MediaReplacementServiceTest extends TestCase
{
    use RefreshDatabase;

    private MediaLibraryService $media;

    private ProductMediaGalleryService $galleries;

    private SurfaceMediaService $surfaces;

    private MediaReplacementService $replacements;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        $this->media = app(MediaLibraryService::class);
        $this->galleries = app(ProductMediaGalleryService::class);
        $this->surfaces = app(SurfaceMediaService::class);
        $this->replacements = app(MediaReplacementService::class);
        $this->actor = hash('sha256', 'cms-034-service-test');
    }

    public function test_product_replacement_updates_product_and_variant_rows_atomically_without_changing_target_position_or_row_identity(): void
    {
        $source = $this->admittedAsset('product-source', MediaAssetPurpose::Product);
        $replacement = $this->admittedAsset('product-replacement', MediaAssetPurpose::Product);
        $other = $this->admittedAsset('product-other', MediaAssetPurpose::Product);

        $this->galleries->replaceProductGallery(
            'drawer-organizer',
            [$other->id, $source->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );
        $this->galleries->replaceVariantGallery(
            'drawer-organizer:white',
            [$source->id, $other->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );

        $beforeProduct = ProductMediaGalleryItem::query()
            ->where('media_asset_id', $source->id)
            ->firstOrFail();
        $beforeVariant = VariantMediaGalleryItem::query()
            ->where('media_asset_id', $source->id)
            ->firstOrFail();
        $expectedFingerprint = $this->replacements->assignmentFingerprint($source);

        $event = $this->replacements->replace(
            $source,
            $replacement,
            $expectedFingerprint,
            $this->actor,
        );

        $afterProduct = ProductMediaGalleryItem::query()->findOrFail($beforeProduct->id);
        $afterVariant = VariantMediaGalleryItem::query()->findOrFail($beforeVariant->id);
        $this->assertSame($replacement->id, $afterProduct->media_asset_id);
        $this->assertSame($replacement->id, $afterVariant->media_asset_id);
        $this->assertSame('drawer-organizer', $afterProduct->product_id);
        $this->assertSame(2, $afterProduct->position);
        $this->assertSame('drawer-organizer:white', $afterVariant->product_variant_id);
        $this->assertSame(1, $afterVariant->position);
        $this->assertDatabaseMissing('product_media_gallery_items', ['media_asset_id' => $source->id]);
        $this->assertDatabaseMissing('variant_media_gallery_items', ['media_asset_id' => $source->id]);

        $this->assertTrue($event->isReplacement());
        $this->assertSame($source->id, $event->source_media_asset_id);
        $this->assertSame($replacement->id, $event->replacement_media_asset_id);
        $this->assertCount(2, $event->before_assignments);
        $this->assertCount(2, $event->after_assignments);
        $this->assertNotSame($event->before_fingerprint, $event->after_fingerprint);
        $this->assertSame(
            [$beforeProduct->id, $beforeVariant->id],
            collect($event->before_assignments)->pluck('row_id')->sort()->values()->all(),
        );

        $payload = $this->galleries->publicPayload();
        $drawer = collect($payload)->firstWhere('product_id', 'drawer-organizer');
        $white = collect($drawer['variants'])->firstWhere('variant_id', 'drawer-organizer:white');
        $this->assertSame([$other->id, $replacement->id], collect($drawer['gallery'])->pluck('media_id')->all());
        $this->assertSame([$replacement->id, $other->id], collect($white['gallery'])->pluck('media_id')->all());
    }

    public function test_surface_replacement_preserves_slot_and_position_and_public_surface_payload_reflects_current_reference(): void
    {
        $source = $this->admittedAsset('home-source', MediaAssetPurpose::Home);
        $replacement = $this->admittedAsset('home-replacement', MediaAssetPurpose::Home);

        $this->surfaces->replace(
            'home.hero',
            [$source->id],
            SurfaceMediaService::fingerprint([]),
            $this->actor,
        );
        $row = SurfaceMediaItem::query()->where('slot_key', 'home.hero')->firstOrFail();

        $event = $this->replacements->replace(
            $source,
            $replacement,
            $this->replacements->assignmentFingerprint($source),
            $this->actor,
        );

        $after = SurfaceMediaItem::query()->findOrFail($row->id);
        $this->assertSame('home.hero', $after->slot_key);
        $this->assertSame(1, $after->position);
        $this->assertSame($replacement->id, $after->media_asset_id);
        $this->assertCount(1, $event->after_assignments);

        $home = collect($this->surfaces->publicPayload())->firstWhere('slot_key', 'home.hero');
        $this->assertSame($replacement->id, $home['items'][0]['media_id']);
    }

    public function test_replace_rejects_same_asset_wrong_purpose_ineligible_destination_and_source_without_assignments_without_mutation(): void
    {
        $source = $this->admittedAsset('guard-source', MediaAssetPurpose::Product);
        $validReplacement = $this->admittedAsset('guard-valid', MediaAssetPurpose::Product);
        $wrongPurpose = $this->admittedAsset('guard-home', MediaAssetPurpose::Home);
        $draft = $this->draftAsset('guard-draft', MediaAssetPurpose::Product);
        $archived = $this->admittedAsset('guard-archived', MediaAssetPurpose::Product);
        $this->media->archive($archived, $this->actor);
        $missingCanonical = $this->draftAsset('guard-no-canonical', MediaAssetPurpose::Product);
        $missingCanonical->forceFill([
            'lifecycle' => MediaAssetLifecycle::Admitted,
            'admitted_at' => now(),
        ])->save();

        $this->galleries->replaceProductGallery(
            'drawer-organizer',
            [$source->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );
        $fingerprint = $this->replacements->assignmentFingerprint($source);

        foreach ([$source, $wrongPurpose, $draft, $archived, $missingCanonical] as $invalid) {
            try {
                $this->replacements->replace($source, $invalid, $fingerprint, $this->actor);
                $this->fail('Invalid replacement must fail.');
            } catch (ValidationException) {
                $this->assertDatabaseHas('product_media_gallery_items', [
                    'product_id' => 'drawer-organizer',
                    'media_asset_id' => $source->id,
                    'position' => 1,
                ]);
                $this->assertSame(0, MediaReplacementEvent::query()->count());
            }
        }

        $unassigned = $this->admittedAsset('guard-unassigned', MediaAssetPurpose::Product);
        try {
            $this->replacements->replace(
                $unassigned,
                $validReplacement,
                $this->replacements->assignmentFingerprint($unassigned),
                $this->actor,
            );
            $this->fail('Unassigned source must fail.');
        } catch (ValidationException) {
            $this->assertSame(0, MediaReplacementEvent::query()->count());
        }
    }

    public function test_stale_fingerprint_and_destination_already_in_affected_target_are_rejected_atomically(): void
    {
        $source = $this->admittedAsset('conflict-source', MediaAssetPurpose::Product);
        $replacement = $this->admittedAsset('conflict-replacement', MediaAssetPurpose::Product);
        $other = $this->admittedAsset('conflict-other', MediaAssetPurpose::Product);

        $this->galleries->replaceProductGallery(
            'drawer-organizer',
            [$source->id, $other->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );
        $stale = $this->replacements->assignmentFingerprint($source);
        $this->galleries->replaceVariantGallery(
            'drawer-organizer:white',
            [$source->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );

        try {
            $this->replacements->replace($source, $replacement, $stale, $this->actor);
            $this->fail('Stale assignment fingerprint must fail.');
        } catch (ValidationException) {
            $this->assertDatabaseHas('product_media_gallery_items', ['media_asset_id' => $source->id]);
            $this->assertDatabaseHas('variant_media_gallery_items', ['media_asset_id' => $source->id]);
            $this->assertSame(0, MediaReplacementEvent::query()->count());
        }

        $this->galleries->replaceProductGallery(
            'drawer-organizer',
            [$source->id, $replacement->id],
            ProductMediaGalleryService::fingerprint([$source->id, $other->id]),
            $this->actor,
        );
        try {
            $this->replacements->replace(
                $source,
                $replacement,
                $this->replacements->assignmentFingerprint($source),
                $this->actor,
            );
            $this->fail('Replacement already in affected target must fail.');
        } catch (ValidationException) {
            $this->assertSame(
                [$source->id, $replacement->id],
                ProductMediaGalleryItem::query()
                    ->where('product_id', 'drawer-organizer')
                    ->orderBy('position')
                    ->pluck('media_asset_id')
                    ->all(),
            );
            $this->assertDatabaseHas('variant_media_gallery_items', ['media_asset_id' => $source->id]);
            $this->assertSame(0, MediaReplacementEvent::query()->count());
        }
    }

    public function test_replacement_event_is_immutable_and_rollback_restores_exact_rows_and_creates_linked_history(): void
    {
        $source = $this->admittedAsset('rollback-source', MediaAssetPurpose::Product);
        $replacement = $this->admittedAsset('rollback-replacement', MediaAssetPurpose::Product);
        $other = $this->admittedAsset('rollback-other', MediaAssetPurpose::Product);
        $this->galleries->replaceProductGallery(
            'drawer-organizer',
            [$other->id, $source->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );
        $originalRow = ProductMediaGalleryItem::query()
            ->where('product_id', 'drawer-organizer')
            ->where('media_asset_id', $source->id)
            ->firstOrFail();

        $event = $this->replacements->replace(
            $source,
            $replacement,
            $this->replacements->assignmentFingerprint($source),
            $this->actor,
        );

        try {
            $event->forceFill(['operation' => 'tampered'])->save();
            $this->fail('Audit event updates must be rejected.');
        } catch (LogicException) {
            $this->assertSame('replace', $event->fresh()->operation);
        }
        try {
            $event->fresh()->delete();
            $this->fail('Audit event deletion must be rejected.');
        } catch (LogicException) {
            $this->assertDatabaseHas('media_replacement_events', ['id' => $event->id]);
        }

        $rollback = $this->replacements->rollback(
            $event,
            $event->after_fingerprint,
            $this->actor,
        );

        $restored = ProductMediaGalleryItem::query()->findOrFail($originalRow->id);
        $this->assertSame($source->id, $restored->media_asset_id);
        $this->assertSame('drawer-organizer', $restored->product_id);
        $this->assertSame(2, $restored->position);
        $this->assertTrue($rollback->isRollback());
        $this->assertSame($event->id, $rollback->rollback_of_event_id);
        $this->assertSame($replacement->id, $rollback->source_media_asset_id);
        $this->assertSame($source->id, $rollback->replacement_media_asset_id);
        $this->assertSame($event->after_assignments, $rollback->before_assignments);
        $this->assertSame($event->before_assignments, $rollback->after_assignments);
        $this->assertSame(2, MediaReplacementEvent::query()->count());

        $this->expectException(ValidationException::class);
        $this->replacements->rollback($event, $event->after_fingerprint, $this->actor);
    }

    public function test_rollback_is_blocked_after_intervening_assignment_edit_and_newer_owner_work_is_preserved(): void
    {
        $source = $this->admittedAsset('intervening-source', MediaAssetPurpose::Product);
        $replacement = $this->admittedAsset('intervening-replacement', MediaAssetPurpose::Product);
        $other = $this->admittedAsset('intervening-other', MediaAssetPurpose::Product);
        $this->galleries->replaceProductGallery(
            'drawer-organizer',
            [$source->id, $other->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );
        $event = $this->replacements->replace(
            $source,
            $replacement,
            $this->replacements->assignmentFingerprint($source),
            $this->actor,
        );

        $this->galleries->replaceProductGallery(
            'drawer-organizer',
            [$other->id, $replacement->id],
            ProductMediaGalleryService::fingerprint([$replacement->id, $other->id]),
            $this->actor,
        );

        try {
            $this->replacements->rollback($event, $event->after_fingerprint, $this->actor);
            $this->fail('Intervening assignment edit must block rollback.');
        } catch (ValidationException) {
            $this->assertSame(
                [$other->id, $replacement->id],
                ProductMediaGalleryItem::query()
                    ->where('product_id', 'drawer-organizer')
                    ->orderBy('position')
                    ->pluck('media_asset_id')
                    ->all(),
            );
            $this->assertSame(1, MediaReplacementEvent::query()->count());
        }
    }

    public function test_archived_original_source_blocks_rollback_without_implicit_unarchive(): void
    {
        $source = $this->admittedAsset('archive-source', MediaAssetPurpose::Home);
        $replacement = $this->admittedAsset('archive-replacement', MediaAssetPurpose::Home);
        $this->surfaces->replace(
            'home.hero',
            [$source->id],
            SurfaceMediaService::fingerprint([]),
            $this->actor,
        );
        $event = $this->replacements->replace(
            $source,
            $replacement,
            $this->replacements->assignmentFingerprint($source),
            $this->actor,
        );
        $this->media->archive($source, $this->actor);

        try {
            $this->replacements->rollback($event, $event->after_fingerprint, $this->actor);
            $this->fail('Archived original source must block rollback.');
        } catch (ValidationException) {
            $this->assertSame(MediaAssetLifecycle::Archived, $source->fresh()->lifecycle);
            $this->assertDatabaseHas('surface_media_items', [
                'slot_key' => 'home.hero',
                'media_asset_id' => $replacement->id,
            ]);
            $this->assertSame(1, MediaReplacementEvent::query()->count());
        }
    }

    private function admittedAsset(string $suffix, MediaAssetPurpose $purpose): MediaAsset
    {
        $asset = $this->draftAsset($suffix, $purpose);
        $this->media->attachDerivative($asset, [
            'kind' => MediaDerivativeKind::Canonical->value,
            'storage_disk' => 'private-media',
            'storage_path' => "cms034/$suffix/canonical.png",
            'mime' => 'image/png',
            'bytes' => 250000 + strlen($suffix),
            'width' => 1400,
            'height' => 1200,
            'sha256' => hash('sha256', 'cms034-canonical-'.$suffix),
        ], $this->actor);

        return $this->media->admit($asset, $this->actor);
    }

    private function draftAsset(string $suffix, MediaAssetPurpose $purpose): MediaAsset
    {
        return $this->media->registerSource([
            'purpose' => $purpose->value,
            'source_reference' => 'cms034-source-'.$suffix,
            'original_filename' => 'replacement-'.$suffix.'.png',
            'original_mime' => 'image/png',
            'original_bytes' => 470000 + strlen($suffix),
            'original_width' => 1800,
            'original_height' => 1500,
            'original_sha256' => hash('sha256', 'cms034-source-'.$suffix),
            'semantic_label' => 'CMS-034 media '.$suffix,
        ], $this->actor);
    }
}
