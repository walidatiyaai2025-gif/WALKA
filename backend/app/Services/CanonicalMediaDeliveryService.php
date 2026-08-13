<?php

namespace App\Services;

use App\Enums\MediaAssetLifecycle;
use App\Models\MediaAsset;
use App\Models\MediaDerivative;
use Illuminate\Contracts\Filesystem\Filesystem;
use Illuminate\Support\Facades\Storage;
use RuntimeException;
use Throwable;

final class CanonicalMediaDeliveryService
{
    public const MAX_DELIVERY_BYTES = 16 * 1024 * 1024;

    /** @var list<string> */
    private const ALLOWED_MIME = [
        'image/png',
        'image/jpeg',
        'image/webp',
    ];

    /**
     * @return array{bytes:string,mime:string,width:int,height:int,sha256:string,etag:string}
     */
    public function verifiedBytes(string $mediaAssetId): array
    {
        $asset = MediaAsset::query()
            ->whereKey($mediaAssetId)
            ->where('lifecycle', MediaAssetLifecycle::Admitted->value)
            ->with('canonicalDerivative')
            ->first();

        if (! $asset instanceof MediaAsset || ! $asset->canonicalDerivative instanceof MediaDerivative) {
            throw new CanonicalMediaUnavailableException;
        }

        $derivative = $asset->canonicalDerivative;
        if (! $this->metadataIsDeliverable($derivative)) {
            throw new CanonicalMediaIntegrityException;
        }

        $diskConfig = config('filesystems.disks.'.$derivative->storage_disk);
        if (! is_array($diskConfig)) {
            throw new CanonicalMediaUnavailableException;
        }

        try {
            $disk = Storage::disk($derivative->storage_disk);
            $this->assertStoredSize($disk, $derivative);
            $bytes = $disk->get($derivative->storage_path);
        } catch (CanonicalMediaIntegrityException $error) {
            throw $error;
        } catch (Throwable) {
            throw new CanonicalMediaUnavailableException;
        }

        if (! is_string($bytes)) {
            throw new CanonicalMediaUnavailableException;
        }
        if (strlen($bytes) !== $derivative->bytes) {
            throw new CanonicalMediaIntegrityException;
        }
        if (! hash_equals($derivative->sha256, hash('sha256', $bytes))) {
            throw new CanonicalMediaIntegrityException;
        }

        $detectedMime = (new \finfo(FILEINFO_MIME_TYPE))->buffer($bytes);
        if (! is_string($detectedMime) || $detectedMime !== $derivative->mime) {
            throw new CanonicalMediaIntegrityException;
        }

        $imageInfo = @getimagesizefromstring($bytes);
        if (! is_array($imageInfo) || ! isset($imageInfo[0], $imageInfo[1])) {
            throw new CanonicalMediaIntegrityException;
        }
        $imageMime = $imageInfo['mime'] ?? null;
        if (
            (int) $imageInfo[0] !== $derivative->width
            || (int) $imageInfo[1] !== $derivative->height
            || $imageMime !== $derivative->mime
        ) {
            throw new CanonicalMediaIntegrityException;
        }

        return [
            'bytes' => $bytes,
            'mime' => $derivative->mime,
            'width' => $derivative->width,
            'height' => $derivative->height,
            'sha256' => $derivative->sha256,
            'etag' => '"sha256-'.$derivative->sha256.'"',
        ];
    }

    private function metadataIsDeliverable(MediaDerivative $derivative): bool
    {
        return in_array($derivative->mime, self::ALLOWED_MIME, true)
            && $derivative->bytes > 0
            && $derivative->bytes <= self::MAX_DELIVERY_BYTES
            && $derivative->width > 0
            && $derivative->height > 0
            && preg_match('/^[a-f0-9]{64}$/', $derivative->sha256) === 1
            && trim($derivative->storage_disk) !== ''
            && $this->storagePathIsDeliverable($derivative->storage_path);
    }

    private function storagePathIsDeliverable(string $storagePath): bool
    {
        $path = trim($storagePath);

        return $path !== ''
            && ! str_contains($path, "\0")
            && ! str_contains($path, '\\')
            && ! str_contains($path, '://')
            && ! str_starts_with($path, '/')
            && preg_match('#(?:^|/)\.\.?(?:/|$)#', $path) !== 1;
    }

    private function assertStoredSize(Filesystem $disk, MediaDerivative $derivative): void
    {
        try {
            if (! $disk->exists($derivative->storage_path)) {
                throw new CanonicalMediaUnavailableException;
            }
            $storedSize = $disk->size($derivative->storage_path);
        } catch (CanonicalMediaUnavailableException $error) {
            throw $error;
        } catch (Throwable) {
            throw new CanonicalMediaUnavailableException;
        }

        if (
            ! is_int($storedSize)
            || $storedSize < 1
            || $storedSize > self::MAX_DELIVERY_BYTES
            || $storedSize !== $derivative->bytes
        ) {
            throw new CanonicalMediaIntegrityException;
        }
    }
}

final class CanonicalMediaUnavailableException extends RuntimeException {}

final class CanonicalMediaIntegrityException extends RuntimeException {}
