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
use Tests\TestCase;

final class AdminMediaReplacementControllerTest extends TestCase
{
    use RefreshDatabase;

    private array $session;

    private string $actor;

    private MediaLibraryService $media;

    private ProductMediaGalleryService $galleries;

    private MediaReplacementService $replacements;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
        config()->set('walka.dashboard_username', 'admin');
        config()->set('walka.dashboard_password', 'Walka-Admin-Test-Password-2026');
        $this->actor = hash('sha256', 'cms-034-admin-test');
        $this->session = [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_actor' => $this->actor,
        ];
        $this->media = app(MediaLibraryService::class);
        $this->galleries = app(ProductMediaGalleryService::class);
        $this->replacements = app(MediaReplacementService::class);
    }

    public function test_replacement_workspace_and_mutations_are_dashboard_protected(): void
    {
        $source = $this->admittedAsset('protected-source', MediaAssetPurpose::Product);
        $replacement = $this->admittedAsset('protected-replacement', MediaAssetPurpose::Product);
        $this->galleries->replaceProductGallery(
            'drawer-organizer',
            [$source->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );
        $event = $this->replacements->replace(
            $source,
            $replacement,
            $this->replacements->assignmentFingerprint($source),
            $this->actor,
            'Create real event for route protection test',
        );
        $this->assertNotNull($event);

        $this->get('/admin/media/replacements')->assertRedirect(route('admin.login'));
        $this->post('/admin/media/replacements')->assertRedirect(route('admin.login'));
        $this->post(route('admin.media.replacements.rollback', ['event' => $event->id]))
            ->assertRedirect(route('admin.login'));
    }

    public function test_workspace_shows_only_assigned_sources_and_same_purpose_replacement_candidates(): void
    {
        $source = $this->admittedAsset('workspace-source', MediaAssetPurpose::Product);
        $candidate = $this->admittedAsset('workspace-candidate', MediaAssetPurpose::Product);
        $unassigned = $this->admittedAsset('workspace-unassigned', MediaAssetPurpose::Product);
        $home = $this->admittedAsset('workspace-home', MediaAssetPurpose::Home);
        $this->galleries->replaceProductGallery(
            'drawer-organizer',
            [$source->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );

        $response = $this->withSession($this->session)
            ->get(route('admin.media.replacements.index'))
            ->assertOk()
            ->assertSeeText('Replacement & rollback')
            ->assertSee($source->semantic_label)
            ->assertSee($candidate->semantic_label)
            ->assertSee($unassigned->semantic_label)
            ->assertDontSee($home->semantic_label)
            ->assertSeeText('Apply governed replacement')
            ->assertSeeText('CURRENT / NO-OP');

        $html = $response->getContent();
        $this->assertSame(1, substr_count($html, 'name="source_media_asset_id"'));
        $this->assertStringContainsString(
            'name="source_media_asset_id" value="'.$source->id.'"',
            $html,
        );
        $this->assertStringNotContainsString(
            'name="source_media_asset_id" value="'.$unassigned->id.'"',
            $html,
        );
    }

    public function test_owner_can_replace_then_rollback_through_dashboard_with_immutable_reasoned_history(): void
    {
        $source = $this->admittedAsset('workflow-source', MediaAssetPurpose::Product);
        $replacement = $this->admittedAsset('workflow-replacement', MediaAssetPurpose::Product);
        $this->galleries->replaceProductGallery(
            'drawer-organizer',
            [$source->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );
        $fingerprint = $this->replacements->assignmentFingerprint($source);

        $this->withSession($this->session)
            ->post(route('admin.media.replacements.store'), [
                'source_media_asset_id' => $source->id,
                'replacement_media_asset_id' => $replacement->id,
                'expected_fingerprint' => $fingerprint,
                'reason' => 'Owner approved refreshed product visual',
            ])
            ->assertRedirect(route('admin.media.replacements.index'))
            ->assertSessionHas('status');

        $event = MediaReplacementEvent::query()->where('operation', 'replace')->firstOrFail();
        $this->assertSame('Owner approved refreshed product visual', $event->reason);
        $this->assertDatabaseHas('product_media_gallery_items', [
            'product_id' => 'drawer-organizer',
            'media_asset_id' => $replacement->id,
            'position' => 1,
        ]);

        $this->withSession($this->session)
            ->get(route('admin.media.replacements.index'))
            ->assertOk()
            ->assertSee($event->id)
            ->assertSeeText('Owner approved refreshed product visual')
            ->assertSeeText('Rollback exact snapshot');

        $this->withSession($this->session)
            ->post(route('admin.media.replacements.rollback', ['event' => $event->id]), [
                'expected_after_fingerprint' => $event->after_fingerprint,
                'reason' => 'Owner requested previous visual',
            ])
            ->assertRedirect(route('admin.media.replacements.index'))
            ->assertSessionHas('status');

        $this->assertDatabaseHas('product_media_gallery_items', [
            'product_id' => 'drawer-organizer',
            'media_asset_id' => $source->id,
            'position' => 1,
        ]);
        $this->assertDatabaseHas('media_replacement_events', [
            'operation' => 'rollback',
            'rollback_of_event_id' => $event->id,
            'source_media_asset_id' => $replacement->id,
            'replacement_media_asset_id' => $source->id,
            'reason' => 'Owner requested previous visual',
        ]);

        $this->withSession($this->session)
            ->get(route('admin.media.replacements.index'))
            ->assertOk()
            ->assertSeeText('ROLLED BACK');
    }

    public function test_dashboard_same_current_selection_is_noop_without_audit_event(): void
    {
        $source = $this->admittedAsset('noop-source', MediaAssetPurpose::Product);
        $this->galleries->replaceProductGallery(
            'drawer-organizer',
            [$source->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );

        $this->withSession($this->session)
            ->post(route('admin.media.replacements.store'), [
                'source_media_asset_id' => $source->id,
                'replacement_media_asset_id' => $source->id,
                'expected_fingerprint' => $this->replacements->assignmentFingerprint($source),
            ])
            ->assertRedirect(route('admin.media.replacements.index'))
            ->assertSessionHas('status', 'Selected media is already current. No assignment or audit event was changed.');

        $this->assertSame(0, MediaReplacementEvent::query()->count());
        $this->assertSame($source->id, ProductMediaGalleryItem::query()->firstOrFail()->media_asset_id);
    }

    public function test_stale_dashboard_replace_is_rejected_without_changing_assignment_or_history(): void
    {
        $source = $this->admittedAsset('stale-source', MediaAssetPurpose::Product);
        $replacement = $this->admittedAsset('stale-replacement', MediaAssetPurpose::Product);
        $other = $this->admittedAsset('stale-other', MediaAssetPurpose::Product);
        $this->galleries->replaceProductGallery(
            'drawer-organizer',
            [$source->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );
        $stale = $this->replacements->assignmentFingerprint($source);
        $this->galleries->replaceVariantGallery(
            'drawer-organizer:white',
            [$source->id, $other->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );

        $this->withSession($this->session)
            ->from(route('admin.media.replacements.index'))
            ->post(route('admin.media.replacements.store'), [
                'source_media_asset_id' => $source->id,
                'replacement_media_asset_id' => $replacement->id,
                'expected_fingerprint' => $stale,
                'reason' => 'Attempt stale dashboard replacement',
            ])
            ->assertRedirect(route('admin.media.replacements.index'))
            ->assertSessionHasErrors('assignment_fingerprint');

        $this->assertDatabaseHas('product_media_gallery_items', ['media_asset_id' => $source->id]);
        $this->assertDatabaseHas('variant_media_gallery_items', ['media_asset_id' => $source->id]);
        $this->assertSame(0, MediaReplacementEvent::query()->count());
    }

    public function test_second_dashboard_rollback_is_rejected_and_current_restored_assignment_remains_untouched(): void
    {
        $source = $this->admittedAsset('second-source', MediaAssetPurpose::Product);
        $replacement = $this->admittedAsset('second-replacement', MediaAssetPurpose::Product);
        $this->galleries->replaceProductGallery(
            'drawer-organizer',
            [$source->id],
            ProductMediaGalleryService::fingerprint([]),
            $this->actor,
        );
        $event = $this->replacements->replace(
            $source,
            $replacement,
            $this->replacements->assignmentFingerprint($source),
            $this->actor,
            'Apply replacement before rollback test',
        );
        $this->assertNotNull($event);
        $this->replacements->rollback(
            $event,
            $event->after_fingerprint,
            $this->actor,
            'Restore original for rollback test',
        );

        $this->withSession($this->session)
            ->from(route('admin.media.replacements.index'))
            ->post(route('admin.media.replacements.rollback', ['event' => $event->id]), [
                'expected_after_fingerprint' => $event->after_fingerprint,
                'reason' => 'Attempt second rollback',
            ])
            ->assertRedirect(route('admin.media.replacements.index'))
            ->assertSessionHasErrors('replacement_event');

        $this->assertSame($source->id, ProductMediaGalleryItem::query()->firstOrFail()->media_asset_id);
        $this->assertSame(2, MediaReplacementEvent::query()->count());
    }

    private function admittedAsset(string $suffix, MediaAssetPurpose $purpose): MediaAsset
    {
        $asset = $this->media->registerSource([
            'purpose' => $purpose->value,
            'source_reference' => 'cms034-admin-source-'.$suffix,
            'original_filename' => 'admin-replacement-'.$suffix.'.png',
            'original_mime' => 'image/png',
            'original_bytes' => 480000 + strlen($suffix),
            'original_width' => 1800,
            'original_height' => 1500,
            'original_sha256' => hash('sha256', 'cms034-admin-source-'.$suffix),
            'semantic_label' => 'CMS-034 admin media '.$suffix,
        ], $this->actor);
        $this->media->attachDerivative($asset, [
            'kind' => MediaDerivativeKind::Canonical->value,
            'storage_disk' => 'private-media',
            'storage_path' => "cms034/admin/$suffix/canonical.png",
            'mime' => 'image/png',
            'bytes' => 260000 + strlen($suffix),
            'width' => 1400,
            'height' => 1200,
            'sha256' => hash('sha256', 'cms034-admin-canonical-'.$suffix),
        ], $this->actor);

        return $this->media->admit($asset, $this->actor);
    }
}
