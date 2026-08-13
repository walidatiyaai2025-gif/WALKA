<?php

namespace Tests\Feature;

use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use App\Models\MediaAsset;
use App\Models\MediaReplacementEvent;
use App\Models\ProductMediaGalleryItem;
use App\Services\MediaLibraryService;
use App\Services\MediaReplacementService;
use App\Services\ProductMediaGalleryService;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class MediaReplacementReasonNoOpTest extends TestCase
{
    use RefreshDatabase;

    private string $actor;

    private int $assetCounter = 0;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        $this->actor = hash('sha256', 'cms-034-reason-noop-test');
    }

    public function test_selecting_the_current_asset_is_a_verified_no_op_but_stale_no_op_is_rejected(): void
    {
        $current = $this->admittedProductAsset('Current drawer media');
        $second = $this->admittedProductAsset('Second drawer media');
        $gallery = app(ProductMediaGalleryService::class);
        $replacements = app(MediaReplacementService::class);

        $gallery->replaceProductGallery(
            'drawer-organizer',
            [$current->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );
        $originalFingerprint = $replacements->assignmentFingerprint($current);

        $this->assertNull($replacements->replace(
            source: $current,
            replacement: $current,
            expectedFingerprint: $originalFingerprint,
            actorFingerprint: $this->actor,
        ));
        $this->assertSame(0, MediaReplacementEvent::query()->count());
        $this->assertSame(
            [$current->id],
            ProductMediaGalleryItem::query()
                ->where('product_id', 'drawer-organizer')
                ->orderBy('position')
                ->pluck('media_asset_id')
                ->all(),
        );

        $gallery->replaceProductGallery(
            'drawer-organizer',
            [$current->id, $second->id],
            ProductMediaGalleryService::fingerprint([$current->id]),
            $this->actor,
        );

        try {
            $replacements->replace(
                source: $current,
                replacement: $current,
                expectedFingerprint: $originalFingerprint,
                actorFingerprint: $this->actor,
            );
            $this->fail('A stale no-op request must not bypass assignment concurrency.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey('assignment_fingerprint', $exception->errors());
        }

        $this->assertSame(0, MediaReplacementEvent::query()->count());
        $this->assertSame(
            [$current->id, $second->id],
            ProductMediaGalleryItem::query()
                ->where('product_id', 'drawer-organizer')
                ->orderBy('position')
                ->pluck('media_asset_id')
                ->all(),
        );
    }

    public function test_effective_replacement_and_rollback_persist_trimmed_immutable_reasons(): void
    {
        $source = $this->admittedProductAsset('Original drawer media');
        $replacement = $this->admittedProductAsset('Replacement drawer media');
        $gallery = app(ProductMediaGalleryService::class);
        $replacements = app(MediaReplacementService::class);

        $gallery->replaceProductGallery(
            'drawer-organizer',
            [$source->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );

        $event = $replacements->replace(
            source: $source,
            replacement: $replacement,
            expectedFingerprint: $replacements->assignmentFingerprint($source),
            actorFingerprint: $this->actor,
            reason: '  Updated approved studio image  ',
        );

        $this->assertNotNull($event);
        $this->assertSame('replace', $event->operation);
        $this->assertSame('Updated approved studio image', $event->reason);
        $this->assertSame($this->actor, $event->actor_fingerprint);
        $this->assertSame(
            [$replacement->id],
            ProductMediaGalleryItem::query()
                ->where('product_id', 'drawer-organizer')
                ->pluck('media_asset_id')
                ->all(),
        );

        $rollback = $replacements->rollback(
            replacementEvent: $event,
            expectedAfterFingerprint: $event->after_fingerprint,
            actorFingerprint: $this->actor,
            reason: '  Owner requested previous approved image  ',
        );

        $this->assertSame('rollback', $rollback->operation);
        $this->assertSame('Owner requested previous approved image', $rollback->reason);
        $this->assertSame($event->id, $rollback->rollback_of_event_id);
        $this->assertSame(2, MediaReplacementEvent::query()->count());
        $this->assertSame(
            [$source->id],
            ProductMediaGalleryItem::query()
                ->where('product_id', 'drawer-organizer')
                ->pluck('media_asset_id')
                ->all(),
        );
    }

    public function test_effective_replacement_without_reason_fails_before_any_assignment_or_audit_mutation(): void
    {
        $source = $this->admittedProductAsset('Source requiring reason');
        $replacement = $this->admittedProductAsset('Replacement requiring reason');
        $gallery = app(ProductMediaGalleryService::class);
        $replacements = app(MediaReplacementService::class);

        $gallery->replaceProductGallery(
            'drawer-organizer',
            [$source->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );

        try {
            $replacements->replace(
                source: $source,
                replacement: $replacement,
                expectedFingerprint: $replacements->assignmentFingerprint($source),
                actorFingerprint: $this->actor,
            );
            $this->fail('An effective replacement must require an audit reason.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey('reason', $exception->errors());
        }

        $this->assertSame(0, MediaReplacementEvent::query()->count());
        $this->assertSame(
            [$source->id],
            ProductMediaGalleryItem::query()
                ->where('product_id', 'drawer-organizer')
                ->pluck('media_asset_id')
                ->all(),
        );
    }

    private function admittedProductAsset(string $label): MediaAsset
    {
        $this->assetCounter++;
        $counter = $this->assetCounter;
        $media = app(MediaLibraryService::class);
        $asset = $media->registerSource([
            'purpose' => MediaAssetPurpose::Product,
            'source_reference' => "cms-034-reason-$counter",
            'original_filename' => "cms-034-reason-$counter.png",
            'original_mime' => 'image/png',
            'original_bytes' => 4000 + $counter,
            'original_width' => 1600,
            'original_height' => 1600,
            'original_sha256' => hash('sha256', "cms-034-reason-source-$counter"),
            'semantic_label' => $label,
        ], $this->actor);
        $media->attachDerivative($asset, [
            'kind' => MediaDerivativeKind::Canonical,
            'storage_disk' => 'media-test',
            'storage_path' => "cms-034/reason/$counter.png",
            'mime' => 'image/png',
            'bytes' => 2000 + $counter,
            'width' => 1200,
            'height' => 1200,
            'sha256' => hash('sha256', "cms-034-reason-canonical-$counter"),
        ], $this->actor);

        return $media->admit($asset, $this->actor);
    }
}
