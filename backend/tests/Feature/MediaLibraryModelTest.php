<?php

namespace Tests\Feature;

use App\Enums\MediaAssetLifecycle;
use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use App\Models\MediaAsset;
use App\Services\MediaLibraryService;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class MediaLibraryModelTest extends TestCase
{
    use RefreshDatabase;

    private MediaLibraryService $media;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->media = app(MediaLibraryService::class);
        $this->actor = hash('sha256', 'cms-030-media-test');
    }

    public function test_source_registration_generates_stable_ulid_and_keeps_media_draft(): void
    {
        $asset = $this->media->registerSource($this->source(), $this->actor);

        $this->assertMatchesRegularExpression('/^[0-9A-HJKMNP-TV-Z]{26}$/', $asset->id);
        $this->assertSame(MediaAssetPurpose::Product, $asset->purpose);
        $this->assertSame(MediaAssetLifecycle::Draft, $asset->lifecycle);
        $this->assertSame('white-source.jpg', $asset->original_filename);
        $this->assertSame($this->actor, $asset->created_by_fingerprint);
        $this->assertSame($this->actor, $asset->updated_by_fingerprint);
        $this->assertNull($asset->admitted_at);
        $this->assertNull($asset->archived_at);
    }

    public function test_source_hash_is_unique_to_prevent_duplicate_media_truth(): void
    {
        $this->media->registerSource($this->source(), $this->actor);

        $this->expectException(QueryException::class);
        $this->media->registerSource($this->source(), $this->actor);
    }

    public function test_derivative_metadata_is_owned_by_source_and_path_hash_are_unique(): void
    {
        $asset = $this->media->registerSource($this->source(), $this->actor);
        $derivative = $this->media->attachDerivative(
            $asset,
            $this->derivative(),
            $this->actor,
        );

        $this->assertSame($asset->id, $derivative->media_asset_id);
        $this->assertSame(MediaDerivativeKind::Canonical, $derivative->kind);
        $this->assertSame('media/products/white/canonical.png', $derivative->storage_path);
        $this->assertSame($this->actor, $derivative->created_by_fingerprint);
        $this->assertSame(1, $asset->derivatives()->count());
    }

    public function test_file_metadata_presence_does_not_auto_admit_media(): void
    {
        $asset = $this->media->registerSource($this->source(), $this->actor);
        $this->media->attachDerivative($asset, $this->derivative(), $this->actor);

        $this->assertSame(MediaAssetLifecycle::Draft, $asset->refresh()->lifecycle);
        $this->assertNull($asset->admitted_at);
    }

    public function test_admission_requires_semantic_label_and_canonical_derivative(): void
    {
        $withoutLabel = $this->media->registerSource(
            $this->source(['original_sha256' => str_repeat('b', 64), 'semantic_label' => null]),
            $this->actor,
        );
        $this->media->attachDerivative(
            $withoutLabel,
            $this->derivative(['sha256' => str_repeat('c', 64), 'storage_path' => 'media/a.png']),
            $this->actor,
        );

        try {
            $this->media->admit($withoutLabel, $this->actor);
            $this->fail('Missing semantic label should block admission.');
        } catch (ValidationException $error) {
            $this->assertArrayHasKey('semantic_label', $error->errors());
        }

        $withoutCanonical = $this->media->registerSource(
            $this->source(['original_sha256' => str_repeat('d', 64)]),
            $this->actor,
        );
        $this->media->attachDerivative(
            $withoutCanonical,
            $this->derivative([
                'kind' => MediaDerivativeKind::Preview->value,
                'sha256' => str_repeat('e', 64),
                'storage_path' => 'media/preview.png',
            ]),
            $this->actor,
        );

        try {
            $this->media->admit($withoutCanonical, $this->actor);
            $this->fail('Missing canonical derivative should block admission.');
        } catch (ValidationException $error) {
            $this->assertArrayHasKey('canonical', $error->errors());
        }
    }

    public function test_explicit_admission_and_archive_transitions_are_auditable(): void
    {
        $asset = $this->media->registerSource($this->source(), $this->actor);
        $this->media->attachDerivative($asset, $this->derivative(), $this->actor);

        $admitted = $this->media->admit($asset, $this->actor);
        $this->assertSame(MediaAssetLifecycle::Admitted, $admitted->lifecycle);
        $this->assertNotNull($admitted->admitted_at);
        $this->assertTrue($admitted->isAdmitted());

        $archived = $this->media->archive($admitted, hash('sha256', 'archive-actor'));
        $this->assertSame(MediaAssetLifecycle::Archived, $archived->lifecycle);
        $this->assertNotNull($archived->archived_at);
        $this->assertFalse($archived->isAdmitted());
        $this->assertSame(hash('sha256', 'archive-actor'), $archived->updated_by_fingerprint);
    }

    public function test_archived_media_cannot_receive_derivatives_or_return_to_admitted(): void
    {
        $asset = $this->media->registerSource($this->source(), $this->actor);
        $asset = $this->media->archive($asset, $this->actor);

        foreach (['attach', 'admit'] as $action) {
            try {
                if ($action === 'attach') {
                    $this->media->attachDerivative($asset, $this->derivative(), $this->actor);
                } else {
                    $this->media->admit($asset, $this->actor);
                }
                $this->fail("Archived media action $action should be blocked.");
            } catch (ValidationException $error) {
                $this->assertNotEmpty($error->errors());
            }
        }
    }

    public function test_metadata_rejects_absolute_storage_paths_and_invalid_fingerprints(): void
    {
        $asset = $this->media->registerSource($this->source(), $this->actor);

        try {
            $this->media->attachDerivative(
                $asset,
                $this->derivative(['storage_path' => '/tmp/media.png']),
                $this->actor,
            );
            $this->fail('Absolute storage path should fail.');
        } catch (ValidationException $error) {
            $this->assertArrayHasKey('storage_path', $error->errors());
        }

        $this->expectException(ValidationException::class);
        $this->media->registerSource(
            $this->source(['original_sha256' => str_repeat('f', 64)]),
            'not-a-fingerprint',
        );
    }

    /** @return array<string, mixed> */
    private function source(array $overrides = []): array
    {
        return [
            'purpose' => MediaAssetPurpose::Product->value,
            'source_reference' => 'SRC-DRAWER-WHITE-001',
            'original_filename' => 'white-source.jpg',
            'original_mime' => 'image/jpeg',
            'original_bytes' => 345678,
            'original_width' => 1500,
            'original_height' => 1200,
            'original_sha256' => str_repeat('a', 64),
            'semantic_label' => 'WALKA white expandable drawer organizer',
            ...$overrides,
        ];
    }

    /** @return array<string, mixed> */
    private function derivative(array $overrides = []): array
    {
        return [
            'kind' => MediaDerivativeKind::Canonical->value,
            'storage_disk' => 'public',
            'storage_path' => 'media/products/white/canonical.png',
            'mime' => 'image/png',
            'bytes' => 220000,
            'width' => 1024,
            'height' => 1024,
            'sha256' => str_repeat('1', 64),
            ...$overrides,
        ];
    }
}
