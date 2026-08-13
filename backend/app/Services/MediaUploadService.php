<?php

namespace App\Services;

use App\Enums\MediaAssetPurpose;
use App\Models\MediaAsset;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;
use Throwable;

final class MediaUploadService
{
    public const QUARANTINE_DISK = 'media_quarantine';

    public const MAX_BYTES = 16 * 1024 * 1024;

    public const MIN_DIMENSION = 64;

    public const MAX_DIMENSION = 8192;

    public const MAX_PIXELS = 40_000_000;

    /** @var array<string, list<string>> */
    private const ALLOWED_EXTENSIONS = [
        'image/png' => ['png'],
        'image/jpeg' => ['jpg', 'jpeg'],
        'image/webp' => ['webp'],
    ];

    public function __construct(private readonly MediaLibraryService $library) {}

    /**
     * Validate uploaded bytes, quarantine the source privately, and register
     * CMS-030 source truth in Draft lifecycle only.
     *
     * @param  array<string, mixed>  $metadata
     */
    public function upload(
        UploadedFile $file,
        array $metadata,
        string $actorFingerprint,
    ): MediaAsset {
        $validatedMetadata = Validator::make($metadata, [
            'purpose' => ['required', Rule::enum(MediaAssetPurpose::class)],
            'source_reference' => ['required', 'string', 'max:255'],
            'semantic_label' => ['required', 'string', 'max:160'],
        ])->validate();

        if (! $file->isValid()) {
            throw ValidationException::withMessages([
                'file' => ['The media upload did not complete successfully.'],
            ]);
        }

        $realPath = $file->getRealPath();
        if (! is_string($realPath) || $realPath === '' || ! is_file($realPath)) {
            throw ValidationException::withMessages([
                'file' => ['The uploaded media bytes are not readable.'],
            ]);
        }

        $originalFilename = $this->normalizeOriginalFilename($file->getClientOriginalName());
        $bytes = filesize($realPath);
        if (! is_int($bytes) || $bytes < 1 || $bytes > self::MAX_BYTES) {
            throw ValidationException::withMessages([
                'file' => [sprintf(
                    'Media source size must be between 1 byte and %d MiB.',
                    intdiv(self::MAX_BYTES, 1024 * 1024),
                )],
            ]);
        }

        $detectedMime = (new \finfo(FILEINFO_MIME_TYPE))->file($realPath);
        if (! is_string($detectedMime) || ! array_key_exists($detectedMime, self::ALLOWED_EXTENSIONS)) {
            throw ValidationException::withMessages([
                'file' => ['Only validated PNG, JPEG, or WebP raster images are accepted.'],
            ]);
        }

        $imageInfo = @getimagesize($realPath);
        if (! is_array($imageInfo) || ! isset($imageInfo[0], $imageInfo[1])) {
            throw ValidationException::withMessages([
                'file' => ['The uploaded bytes are not a readable raster image.'],
            ]);
        }

        $width = (int) $imageInfo[0];
        $height = (int) $imageInfo[1];
        $imageMime = $imageInfo['mime'] ?? null;
        if ($imageMime !== $detectedMime) {
            throw ValidationException::withMessages([
                'file' => ['Image byte signatures and decoded MIME metadata disagree.'],
            ]);
        }

        if ($width < self::MIN_DIMENSION || $height < self::MIN_DIMENSION) {
            throw ValidationException::withMessages([
                'file' => [sprintf(
                    'Media dimensions must be at least %d×%d pixels.',
                    self::MIN_DIMENSION,
                    self::MIN_DIMENSION,
                )],
            ]);
        }
        if ($width > self::MAX_DIMENSION || $height > self::MAX_DIMENSION) {
            throw ValidationException::withMessages([
                'file' => [sprintf(
                    'Media width and height must each be no greater than %d pixels.',
                    self::MAX_DIMENSION,
                )],
            ]);
        }
        if ($width * $height > self::MAX_PIXELS) {
            throw ValidationException::withMessages([
                'file' => [sprintf(
                    'Media pixel count must not exceed %d megapixels.',
                    intdiv(self::MAX_PIXELS, 1_000_000),
                )],
            ]);
        }

        $extension = strtolower(pathinfo($originalFilename, PATHINFO_EXTENSION));
        if (! in_array($extension, self::ALLOWED_EXTENSIONS[$detectedMime], true)) {
            throw ValidationException::withMessages([
                'file' => ['The original filename extension does not match the detected image type.'],
            ]);
        }

        $contents = file_get_contents($realPath);
        if (! is_string($contents) || strlen($contents) !== $bytes) {
            throw ValidationException::withMessages([
                'file' => ['The uploaded media failed byte-integrity verification.'],
            ]);
        }
        $this->assertContainerIntegrity($detectedMime, $contents);

        $sha256 = hash('sha256', $contents);
        if (MediaAsset::query()->where('original_sha256', $sha256)->exists()) {
            throw ValidationException::withMessages([
                'file' => ['This exact media source is already registered.'],
            ]);
        }

        $canonicalExtension = self::ALLOWED_EXTENSIONS[$detectedMime][0];
        $storedPath = null;

        try {
            return DB::transaction(function () use (
                $actorFingerprint,
                $bytes,
                $canonicalExtension,
                $detectedMime,
                $height,
                $originalFilename,
                $realPath,
                $sha256,
                $validatedMetadata,
                $width,
                &$storedPath,
            ): MediaAsset {
                $asset = $this->library->registerSource([
                    'purpose' => $validatedMetadata['purpose'],
                    'source_reference' => trim($validatedMetadata['source_reference']),
                    'original_filename' => $originalFilename,
                    'original_mime' => $detectedMime,
                    'original_bytes' => $bytes,
                    'original_width' => $width,
                    'original_height' => $height,
                    'original_sha256' => $sha256,
                    'semantic_label' => trim($validatedMetadata['semantic_label']),
                ], $actorFingerprint);

                $storedPath = sprintf('%s/%s.%s', $asset->id, $sha256, $canonicalExtension);
                $stream = fopen($realPath, 'rb');
                if ($stream === false) {
                    throw ValidationException::withMessages([
                        'file' => ['The validated upload could not be reopened for quarantine storage.'],
                    ]);
                }

                try {
                    $stored = Storage::disk(self::QUARANTINE_DISK)->put($storedPath, $stream);
                } catch (Throwable) {
                    throw ValidationException::withMessages([
                        'file' => ['The validated upload could not be written to private quarantine storage.'],
                    ]);
                } finally {
                    fclose($stream);
                }

                if (! $stored) {
                    throw ValidationException::withMessages([
                        'file' => ['The validated upload could not be written to private quarantine storage.'],
                    ]);
                }

                $asset->forceFill([
                    'source_storage_disk' => self::QUARANTINE_DISK,
                    'source_storage_path' => $storedPath,
                ])->save();

                return $asset->refresh();
            });
        } catch (Throwable $error) {
            if (is_string($storedPath) && $storedPath !== '') {
                try {
                    Storage::disk(self::QUARANTINE_DISK)->delete($storedPath);
                } catch (Throwable) {
                    // Preserve the original failure. Operations can reconcile an
                    // exceptional filesystem cleanup failure by hash/path audit.
                }
            }

            throw $error;
        }
    }

    private function normalizeOriginalFilename(string $name): string
    {
        $normalized = basename(str_replace('\\', '/', trim($name)));
        if ($normalized === '' || strlen($normalized) > 255 || preg_match('/[\x00-\x1F\x7F]/', $normalized)) {
            throw ValidationException::withMessages([
                'file' => ['The original media filename is invalid.'],
            ]);
        }

        return $normalized;
    }

    private function assertContainerIntegrity(string $mime, string $contents): void
    {
        match ($mime) {
            'image/png' => $this->assertPngIntegrity($contents),
            'image/jpeg' => $this->assertJpegIntegrity($contents),
            'image/webp' => $this->assertWebpIntegrity($contents),
            default => throw ValidationException::withMessages([
                'file' => ['Unsupported image container.'],
            ]),
        };
    }

    private function assertPngIntegrity(string $contents): void
    {
        if (! str_starts_with($contents, "\x89PNG\r\n\x1a\n")) {
            throw ValidationException::withMessages(['file' => ['PNG signature is invalid.']]);
        }

        $length = strlen($contents);
        $offset = 8;
        $seenHeader = false;
        $seenEnd = false;

        while ($offset + 12 <= $length) {
            $chunkLength = unpack('Nlength', substr($contents, $offset, 4))['length'] ?? null;
            if (! is_int($chunkLength) || $chunkLength < 0) {
                break;
            }
            $type = substr($contents, $offset + 4, 4);
            $chunkEnd = $offset + 12 + $chunkLength;
            if ($chunkEnd > $length) {
                break;
            }
            if (! $seenHeader) {
                if ($type !== 'IHDR') {
                    break;
                }
                $seenHeader = true;
            }
            if ($type === 'acTL') {
                throw ValidationException::withMessages([
                    'file' => ['Animated PNG files are not accepted for production media.'],
                ]);
            }
            if ($type === 'IEND') {
                $seenEnd = true;
                $offset = $chunkEnd;
                break;
            }
            $offset = $chunkEnd;
        }

        if (! $seenHeader || ! $seenEnd || $offset !== $length) {
            throw ValidationException::withMessages([
                'file' => ['PNG container structure is incomplete or malformed.'],
            ]);
        }
    }

    private function assertJpegIntegrity(string $contents): void
    {
        if (strlen($contents) < 4 ||
            ! str_starts_with($contents, "\xFF\xD8") ||
            ! str_ends_with($contents, "\xFF\xD9")) {
            throw ValidationException::withMessages([
                'file' => ['JPEG container structure is incomplete or malformed.'],
            ]);
        }
    }

    private function assertWebpIntegrity(string $contents): void
    {
        $length = strlen($contents);
        if ($length < 12 || substr($contents, 0, 4) !== 'RIFF' || substr($contents, 8, 4) !== 'WEBP') {
            throw ValidationException::withMessages([
                'file' => ['WebP container signature is invalid.'],
            ]);
        }

        $declaredSize = unpack('Vsize', substr($contents, 4, 4))['size'] ?? null;
        if (! is_int($declaredSize) || $declaredSize + 8 !== $length) {
            throw ValidationException::withMessages([
                'file' => ['WebP container size does not match uploaded bytes.'],
            ]);
        }

        $offset = 12;
        while ($offset + 8 <= $length) {
            $type = substr($contents, $offset, 4);
            $chunkSize = unpack('Vsize', substr($contents, $offset + 4, 4))['size'] ?? null;
            if (! is_int($chunkSize) || $chunkSize < 0) {
                break;
            }
            if ($type === 'ANIM' || $type === 'ANMF') {
                throw ValidationException::withMessages([
                    'file' => ['Animated WebP files are not accepted for production media.'],
                ]);
            }
            $offset += 8 + $chunkSize + ($chunkSize % 2);
        }

        if ($offset !== $length) {
            throw ValidationException::withMessages([
                'file' => ['WebP container structure is incomplete or malformed.'],
            ]);
        }
    }
}
