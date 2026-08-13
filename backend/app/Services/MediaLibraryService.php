<?php

namespace App\Services;

use App\Enums\MediaAssetLifecycle;
use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use App\Models\MediaAsset;
use App\Models\MediaDerivative;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

final class MediaLibraryService
{
    /**
     * @param  array<string, mixed>  $metadata
     */
    public function registerSource(array $metadata, string $actorFingerprint): MediaAsset
    {
        $actor = $this->validateFingerprint($actorFingerprint);
        $validated = Validator::make($metadata, [
            'purpose' => ['required', Rule::enum(MediaAssetPurpose::class)],
            'source_reference' => ['nullable', 'string', 'max:255'],
            'original_filename' => ['required', 'string', 'max:255'],
            'original_mime' => ['required', 'string', 'max:100'],
            'original_bytes' => ['required', 'integer', 'min:1'],
            'original_width' => ['required', 'integer', 'min:1'],
            'original_height' => ['required', 'integer', 'min:1'],
            'original_sha256' => ['required', 'string', 'regex:/^[a-f0-9]{64}$/'],
            'semantic_label' => ['nullable', 'string', 'max:160'],
        ])->validate();

        return MediaAsset::query()->create([
            ...$validated,
            'lifecycle' => MediaAssetLifecycle::Draft,
            'created_by_fingerprint' => $actor,
            'updated_by_fingerprint' => $actor,
        ]);
    }

    /**
     * @param  array<string, mixed>  $metadata
     */
    public function attachDerivative(
        MediaAsset $asset,
        array $metadata,
        string $actorFingerprint,
    ): MediaDerivative {
        $actor = $this->validateFingerprint($actorFingerprint);
        if ($asset->lifecycle === MediaAssetLifecycle::Archived) {
            throw ValidationException::withMessages([
                'media_asset' => ['Archived media cannot receive new derivatives.'],
            ]);
        }

        $validated = Validator::make($metadata, [
            'kind' => ['required', Rule::enum(MediaDerivativeKind::class)],
            'storage_disk' => ['required', 'string', 'max:64', 'regex:/^[a-z0-9][a-z0-9._-]*$/i'],
            'storage_path' => ['required', 'string', 'max:512', 'not_regex:/^(?:\/|[A-Za-z]:\\\\)/'],
            'mime' => ['required', 'string', 'max:100'],
            'bytes' => ['required', 'integer', 'min:1'],
            'width' => ['required', 'integer', 'min:1'],
            'height' => ['required', 'integer', 'min:1'],
            'sha256' => ['required', 'string', 'regex:/^[a-f0-9]{64}$/'],
        ])->validate();

        return $asset->derivatives()->create([
            ...$validated,
            'created_by_fingerprint' => $actor,
        ]);
    }

    public function admit(MediaAsset $asset, string $actorFingerprint): MediaAsset
    {
        $actor = $this->validateFingerprint($actorFingerprint);
        $asset->loadMissing('derivatives');

        if ($asset->lifecycle === MediaAssetLifecycle::Archived) {
            throw ValidationException::withMessages([
                'lifecycle' => ['Archived media cannot be admitted.'],
            ]);
        }
        if ($asset->semantic_label === null || trim($asset->semantic_label) === '') {
            throw ValidationException::withMessages([
                'semantic_label' => ['A semantic label is required before media admission.'],
            ]);
        }
        if (! $asset->derivatives->contains(
            fn (MediaDerivative $derivative): bool => $derivative->kind === MediaDerivativeKind::Canonical,
        )) {
            throw ValidationException::withMessages([
                'canonical' => ['A validated canonical derivative is required before media admission.'],
            ]);
        }

        $asset->forceFill([
            'lifecycle' => MediaAssetLifecycle::Admitted,
            'admitted_at' => now(),
            'archived_at' => null,
            'updated_by_fingerprint' => $actor,
        ])->save();

        return $asset->refresh();
    }

    public function archive(MediaAsset $asset, string $actorFingerprint): MediaAsset
    {
        $actor = $this->validateFingerprint($actorFingerprint);

        return DB::transaction(function () use ($asset, $actor): MediaAsset {
            $asset->forceFill([
                'lifecycle' => MediaAssetLifecycle::Archived,
                'archived_at' => now(),
                'updated_by_fingerprint' => $actor,
            ])->save();

            return $asset->refresh();
        });
    }

    private function validateFingerprint(string $actorFingerprint): string
    {
        $validated = Validator::make(
            ['actor' => strtolower(trim($actorFingerprint))],
            ['actor' => ['required', 'string', 'regex:/^[a-f0-9]{64}$/']],
        )->validate();

        return $validated['actor'];
    }
}
