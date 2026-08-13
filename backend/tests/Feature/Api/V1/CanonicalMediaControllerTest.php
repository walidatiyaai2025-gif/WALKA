<?php

namespace Tests\Feature\Api\V1;

use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use App\Models\MediaAsset;
use App\Services\MediaLibraryService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

final class CanonicalMediaControllerTest extends TestCase
{
    use RefreshDatabase;

    private const DISK = 'cms035_canonical_test';

    private MediaLibraryService $media;

    private string $actor;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake(self::DISK);
        $this->media = app(MediaLibraryService::class);
        $this->actor = hash('sha256', 'cms-035-canonical-api-test');
    }

    public function test_admitted_canonical_bytes_are_integrity_verified_and_cacheable_without_private_metadata(): void
    {
        [$asset, $bytes, $sha] = $this->storedCanonicalAsset('good');
        $this->media->admit($asset, $this->actor);

        $response = $this->get('/api/v1/media/assets/'.$asset->id.'/canonical')
            ->assertOk()
            ->assertHeader('Content-Type', 'image/png')
            ->assertHeader('Content-Length', (string) strlen($bytes))
            ->assertHeader('ETag', '"sha256-'.$sha.'"')
            ->assertHeader('X-Content-Type-Options', 'nosniff');

        $this->assertSame($bytes, $response->getContent());
        $this->assertStringContainsString('max-age=300', (string) $response->headers->get('Cache-Control'));
        $this->assertStringNotContainsString(self::DISK, implode('\n', $response->headers->allPreserveCase()));
        $this->assertStringNotContainsString('private-source-good.png', $response->getContent());

        $this->withHeader('If-None-Match', '"sha256-'.$sha.'"')
            ->get('/api/v1/media/assets/'.$asset->id.'/canonical')
            ->assertStatus(304)
            ->assertHeader('ETag', '"sha256-'.$sha.'"');

        $this->call('HEAD', '/api/v1/media/assets/'.$asset->id.'/canonical')
            ->assertOk()
            ->assertHeader('Content-Type', 'image/png')
            ->assertHeader('Content-Length', (string) strlen($bytes))
            ->assertSee('', false);
    }

    public function test_draft_archived_missing_and_unknown_media_are_not_deliverable(): void
    {
        [$draft] = $this->storedCanonicalAsset('draft');
        $this->getJson('/api/v1/media/assets/'.$draft->id.'/canonical')
            ->assertNotFound()
            ->assertJsonPath('error.code', 'canonical_media_not_available');

        [$archived] = $this->storedCanonicalAsset('archived');
        $this->media->admit($archived, $this->actor);
        $this->media->archive($archived, $this->actor);
        $this->getJson('/api/v1/media/assets/'.$archived->id.'/canonical')
            ->assertNotFound()
            ->assertJsonPath('error.code', 'canonical_media_not_available');

        $missingCanonical = $this->draftAsset('missing-canonical');
        $missingCanonical->forceFill([
            'lifecycle' => 'admitted',
            'admitted_at' => now(),
        ])->save();
        $this->getJson('/api/v1/media/assets/'.$missingCanonical->id.'/canonical')
            ->assertNotFound()
            ->assertJsonPath('error.code', 'canonical_media_not_available');

        $this->getJson('/api/v1/media/assets/01ARZ3NDEKTSV4RRFFQ69G5FAV/canonical')
            ->assertNotFound()
            ->assertJsonPath('error.code', 'canonical_media_not_available');
    }

    public function test_missing_backing_file_is_not_deliverable_and_does_not_leak_storage_path(): void
    {
        [$asset, $bytes, $sha, $path] = $this->storedCanonicalAsset('missing-file');
        $this->media->admit($asset, $this->actor);
        Storage::disk(self::DISK)->delete($path);

        $response = $this->getJson('/api/v1/media/assets/'.$asset->id.'/canonical')
            ->assertNotFound()
            ->assertJsonPath('error.code', 'canonical_media_not_available');

        $raw = $response->getContent();
        $this->assertStringNotContainsString(self::DISK, $raw);
        $this->assertStringNotContainsString($path, $raw);
        $this->assertStringNotContainsString($sha, $raw);
        $this->assertStringNotContainsString((string) strlen($bytes), $raw);
    }

    public function test_byte_hash_size_mime_and_dimensions_are_reverified_before_delivery(): void
    {
        [$asset, , , $path] = $this->storedCanonicalAsset('tampered');
        $this->media->admit($asset, $this->actor);

        Storage::disk(self::DISK)->put($path, $this->pngBytes().'tamper');
        $this->getJson('/api/v1/media/assets/'.$asset->id.'/canonical')
            ->assertStatus(503)
            ->assertJsonPath('error.code', 'canonical_media_integrity_failed');

        [$wrongMime, $bytes, $sha, $mimePath] = $this->storedCanonicalAsset('wrong-mime');
        $wrongMime->canonicalDerivative()->firstOrFail()->forceFill([
            'mime' => 'image/jpeg',
        ])->save();
        $this->media->admit($wrongMime, $this->actor);
        $this->getJson('/api/v1/media/assets/'.$wrongMime->id.'/canonical')
            ->assertStatus(503)
            ->assertJsonPath('error.code', 'canonical_media_integrity_failed');
        $this->assertTrue(Storage::disk(self::DISK)->exists($mimePath));
        $this->assertSame($sha, hash('sha256', $bytes));

        [$wrongDimensions] = $this->storedCanonicalAsset('wrong-dimensions');
        $wrongDimensions->canonicalDerivative()->firstOrFail()->forceFill([
            'width' => 2,
        ])->save();
        $this->media->admit($wrongDimensions, $this->actor);
        $this->getJson('/api/v1/media/assets/'.$wrongDimensions->id.'/canonical')
            ->assertStatus(503)
            ->assertJsonPath('error.code', 'canonical_media_integrity_failed');
    }

    /**
     * @return array{MediaAsset,string,string,string}
     */
    private function storedCanonicalAsset(string $suffix): array
    {
        $asset = $this->draftAsset($suffix);
        $bytes = $this->pngBytes();
        $sha = hash('sha256', $bytes);
        $path = 'canonical/'.$asset->id.'/'.$sha.'.png';
        Storage::disk(self::DISK)->put($path, $bytes);
        $this->media->attachDerivative($asset, [
            'kind' => MediaDerivativeKind::Canonical->value,
            'storage_disk' => self::DISK,
            'storage_path' => $path,
            'mime' => 'image/png',
            'bytes' => strlen($bytes),
            'width' => 1,
            'height' => 1,
            'sha256' => $sha,
        ], $this->actor);

        return [$asset->refresh(), $bytes, $sha, $path];
    }

    private function draftAsset(string $suffix): MediaAsset
    {
        return $this->media->registerSource([
            'purpose' => MediaAssetPurpose::Product->value,
            'source_reference' => 'cms035-private-source-'.$suffix,
            'original_filename' => 'private-source-'.$suffix.'.png',
            'original_mime' => 'image/png',
            'original_bytes' => strlen($this->pngBytes()),
            'original_width' => 1,
            'original_height' => 1,
            'original_sha256' => hash('sha256', 'cms035-source-'.$suffix),
            'semantic_label' => 'CMS-035 canonical '.$suffix,
        ], $this->actor);
    }

    private function pngBytes(): string
    {
        return base64_decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
            true,
        ) ?: throw new \RuntimeException('Test PNG fixture is invalid.');
    }
}
