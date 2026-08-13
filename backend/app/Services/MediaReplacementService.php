<?php

namespace App\Services;

use App\Enums\MediaAssetLifecycle;
use App\Models\MediaAsset;
use App\Models\MediaReplacementEvent;
use App\Models\ProductMediaGalleryItem;
use App\Models\SurfaceMediaItem;
use App\Models\VariantMediaGalleryItem;
use Illuminate\Database\Eloquent\Collection as EloquentCollection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

final class MediaReplacementService
{
    /**
     * @return list<array{family:string,row_id:string,target_id:string,position:int,media_asset_id:string}>
     */
    public function assignmentsFor(MediaAsset|string $asset): array
    {
        $assetId = $asset instanceof MediaAsset ? $asset->id : $asset;

        return $this->snapshotAssignments([$assetId], false);
    }

    public function assignmentFingerprint(MediaAsset|string $asset): string
    {
        return self::fingerprint($this->assignmentsFor($asset));
    }

    /**
     * @return EloquentCollection<int, MediaAsset>
     */
    public function replacementCandidates(MediaAsset $source): EloquentCollection
    {
        return MediaAsset::query()
            ->whereKeyNot($source->id)
            ->where('purpose', $source->purpose->value)
            ->where('lifecycle', MediaAssetLifecycle::Admitted->value)
            ->whereHas('canonicalDerivative')
            ->with('canonicalDerivative')
            ->orderBy('semantic_label')
            ->orderBy('id')
            ->get();
    }

    public function replace(
        MediaAsset $source,
        MediaAsset $replacement,
        string $expectedFingerprint,
        string $actorFingerprint,
        ?string $reason = null,
    ): ?MediaReplacementEvent {
        $actor = $this->validateActorFingerprint($actorFingerprint);
        $expected = $this->validateFingerprint($expectedFingerprint);

        if ($source->is($replacement)) {
            return DB::transaction(function () use ($expected, $source): ?MediaReplacementEvent {
                $lockedSource = MediaAsset::query()
                    ->whereKey($source->id)
                    ->with('canonicalDerivative')
                    ->lockForUpdate()
                    ->first();
                if (! $lockedSource instanceof MediaAsset) {
                    throw ValidationException::withMessages([
                        'source_media_asset_id' => ['The current media asset no longer exists.'],
                    ]);
                }

                $this->assertEligible($lockedSource);
                $before = $this->snapshotAssignments([$lockedSource->id], true);
                if ($before === []) {
                    throw ValidationException::withMessages([
                        'source_media_asset_id' => ['The current media has no governed assignments.'],
                    ]);
                }
                if (! hash_equals($expected, self::fingerprint($before))) {
                    throw ValidationException::withMessages([
                        'assignment_fingerprint' => ['Source media assignments changed in another session. Reload before retrying.'],
                    ]);
                }

                return null;
            });
        }

        $validatedReason = $this->validateReason($reason);

        return DB::transaction(function () use (
            $actor,
            $expected,
            $replacement,
            $source,
            $validatedReason,
        ): MediaReplacementEvent {
            $assets = MediaAsset::query()
                ->whereIn('id', [$source->id, $replacement->id])
                ->with('canonicalDerivative')
                ->lockForUpdate()
                ->get()
                ->keyBy('id');
            $lockedSource = $assets->get($source->id);
            $lockedReplacement = $assets->get($replacement->id);

            if (! $lockedSource instanceof MediaAsset || ! $lockedReplacement instanceof MediaAsset) {
                throw ValidationException::withMessages([
                    'media_asset' => ['The source or replacement media asset no longer exists.'],
                ]);
            }

            $this->assertEligible($lockedSource);
            $this->assertEligible($lockedReplacement);
            if ($lockedSource->purpose !== $lockedReplacement->purpose) {
                throw ValidationException::withMessages([
                    'replacement_media_asset_id' => ['Replacement media must have the same governed purpose as the source media.'],
                ]);
            }

            $lockedAssignments = $this->snapshotAssignments(
                [$lockedSource->id, $lockedReplacement->id],
                true,
            );
            $before = array_values(array_filter(
                $lockedAssignments,
                fn (array $assignment): bool => $assignment['media_asset_id'] === $lockedSource->id,
            ));
            $replacementAssignments = array_values(array_filter(
                $lockedAssignments,
                fn (array $assignment): bool => $assignment['media_asset_id'] === $lockedReplacement->id,
            ));

            if ($before === []) {
                throw ValidationException::withMessages([
                    'source_media_asset_id' => ['The source media has no current governed assignments to replace.'],
                ]);
            }
            if (! hash_equals($expected, self::fingerprint($before))) {
                throw ValidationException::withMessages([
                    'assignment_fingerprint' => ['Source media assignments changed in another session. Reload before replacing.'],
                ]);
            }

            $replacementTargets = [];
            foreach ($replacementAssignments as $assignment) {
                $replacementTargets[$this->targetKey($assignment)] = true;
            }
            foreach ($before as $assignment) {
                if (isset($replacementTargets[$this->targetKey($assignment)])) {
                    throw ValidationException::withMessages([
                        'replacement_media_asset_id' => [
                            'Replacement media is already assigned to one of the affected targets. Replacement was not applied.',
                        ],
                    ]);
                }
            }

            foreach ($before as $assignment) {
                $updated = $this->assignmentQuery($assignment['family'])
                    ->whereKey($assignment['row_id'])
                    ->where('media_asset_id', $lockedSource->id)
                    ->update(['media_asset_id' => $lockedReplacement->id]);
                if ($updated !== 1) {
                    throw ValidationException::withMessages([
                        'assignment_fingerprint' => ['An affected assignment changed during replacement. No partial replacement was committed.'],
                    ]);
                }
            }

            $after = array_map(
                fn (array $assignment): array => [
                    ...$assignment,
                    'media_asset_id' => $lockedReplacement->id,
                ],
                $before,
            );
            $after = $this->sortSnapshot($after);

            return MediaReplacementEvent::query()->create([
                'operation' => 'replace',
                'source_media_asset_id' => $lockedSource->id,
                'replacement_media_asset_id' => $lockedReplacement->id,
                'rollback_of_event_id' => null,
                'before_assignments' => $before,
                'after_assignments' => $after,
                'before_fingerprint' => self::fingerprint($before),
                'after_fingerprint' => self::fingerprint($after),
                'reason' => $validatedReason,
                'actor_fingerprint' => $actor,
            ]);
        });
    }

    public function rollback(
        MediaReplacementEvent $replacementEvent,
        string $expectedAfterFingerprint,
        string $actorFingerprint,
        ?string $reason = null,
    ): MediaReplacementEvent {
        $actor = $this->validateActorFingerprint($actorFingerprint);
        $expected = $this->validateFingerprint($expectedAfterFingerprint);
        $validatedReason = $this->validateReason($reason);

        return DB::transaction(function () use (
            $actor,
            $expected,
            $replacementEvent,
            $validatedReason,
        ): MediaReplacementEvent {
            $event = MediaReplacementEvent::query()
                ->whereKey($replacementEvent->id)
                ->with('rollbackEvent')
                ->lockForUpdate()
                ->firstOrFail();

            if (! $event->isReplacement()) {
                throw ValidationException::withMessages([
                    'replacement_event' => ['Only a replacement event can be rolled back.'],
                ]);
            }
            if ($event->rollbackEvent !== null) {
                throw ValidationException::withMessages([
                    'replacement_event' => ['This replacement event has already been rolled back.'],
                ]);
            }
            if (! hash_equals($event->after_fingerprint, $expected)) {
                throw ValidationException::withMessages([
                    'assignment_fingerprint' => ['The rollback request is stale. Reload replacement history before retrying.'],
                ]);
            }

            $source = MediaAsset::query()
                ->whereKey($event->source_media_asset_id)
                ->with('canonicalDerivative')
                ->lockForUpdate()
                ->first();
            if (! $source instanceof MediaAsset) {
                throw ValidationException::withMessages([
                    'source_media_asset_id' => ['The original source media no longer exists.'],
                ]);
            }
            $this->assertEligible($source);

            $expectedAfter = $this->sortSnapshot($event->after_assignments ?? []);
            $currentAfter = $this->snapshotRowsByIdentity($expectedAfter, true);
            if ($currentAfter !== $expectedAfter || ! hash_equals($event->after_fingerprint, self::fingerprint($currentAfter))) {
                throw ValidationException::withMessages([
                    'assignment_fingerprint' => [
                        'Affected assignments changed after replacement. Rollback was blocked to avoid overwriting newer owner work.',
                    ],
                ]);
            }

            $sourceAssignments = $this->snapshotAssignments([$source->id], true);
            $sourceTargets = [];
            foreach ($sourceAssignments as $assignment) {
                $sourceTargets[$this->targetKey($assignment)] = $assignment['row_id'];
            }
            foreach ($expectedAfter as $assignment) {
                $targetKey = $this->targetKey($assignment);
                if (isset($sourceTargets[$targetKey]) && $sourceTargets[$targetKey] !== $assignment['row_id']) {
                    throw ValidationException::withMessages([
                        'source_media_asset_id' => [
                            'Original source media is already assigned to an affected target. Rollback was not applied.',
                        ],
                    ]);
                }
            }

            foreach ($expectedAfter as $assignment) {
                $updated = $this->assignmentQuery($assignment['family'])
                    ->whereKey($assignment['row_id'])
                    ->where('media_asset_id', $event->replacement_media_asset_id)
                    ->update(['media_asset_id' => $event->source_media_asset_id]);
                if ($updated !== 1) {
                    throw ValidationException::withMessages([
                        'assignment_fingerprint' => ['An affected assignment changed during rollback. No partial rollback was committed.'],
                    ]);
                }
            }

            $restored = $this->sortSnapshot($event->before_assignments ?? []);

            return MediaReplacementEvent::query()->create([
                'operation' => 'rollback',
                'source_media_asset_id' => $event->replacement_media_asset_id,
                'replacement_media_asset_id' => $event->source_media_asset_id,
                'rollback_of_event_id' => $event->id,
                'before_assignments' => $expectedAfter,
                'after_assignments' => $restored,
                'before_fingerprint' => $event->after_fingerprint,
                'after_fingerprint' => $event->before_fingerprint,
                'reason' => $validatedReason,
                'actor_fingerprint' => $actor,
            ]);
        });
    }

    /**
     * @param  list<string>  $assetIds
     * @return list<array{family:string,row_id:string,target_id:string,position:int,media_asset_id:string}>
     */
    private function snapshotAssignments(array $assetIds, bool $lock): array
    {
        if ($assetIds === []) {
            return [];
        }

        $snapshot = [];
        $families = [
            'product' => [ProductMediaGalleryItem::class, 'product_id'],
            'variant' => [VariantMediaGalleryItem::class, 'product_variant_id'],
            'surface' => [SurfaceMediaItem::class, 'slot_key'],
        ];

        foreach ($families as $family => [$model, $targetColumn]) {
            $query = $model::query()
                ->whereIn('media_asset_id', $assetIds)
                ->orderBy($targetColumn)
                ->orderBy('position')
                ->orderBy('id');
            if ($lock) {
                $query->lockForUpdate();
            }

            foreach ($query->get() as $row) {
                $snapshot[] = [
                    'family' => $family,
                    'row_id' => (string) $row->id,
                    'target_id' => (string) $row->{$targetColumn},
                    'position' => (int) $row->position,
                    'media_asset_id' => (string) $row->media_asset_id,
                ];
            }
        }

        return $this->sortSnapshot($snapshot);
    }

    /**
     * @param  list<array{family:string,row_id:string,target_id:string,position:int,media_asset_id:string}>  $identity
     * @return list<array{family:string,row_id:string,target_id:string,position:int,media_asset_id:string}>
     */
    private function snapshotRowsByIdentity(array $identity, bool $lock): array
    {
        $result = [];
        foreach (['product', 'variant', 'surface'] as $family) {
            $rows = array_values(array_filter(
                $identity,
                fn (array $assignment): bool => $assignment['family'] === $family,
            ));
            if ($rows === []) {
                continue;
            }

            $query = $this->assignmentQuery($family)
                ->whereIn('id', array_column($rows, 'row_id'));
            if ($lock) {
                $query->lockForUpdate();
            }
            $models = $query->get()->keyBy('id');

            foreach ($rows as $expectedRow) {
                $row = $models->get($expectedRow['row_id']);
                if ($row === null) {
                    continue;
                }
                $targetColumn = $this->targetColumn($family);
                $result[] = [
                    'family' => $family,
                    'row_id' => (string) $row->id,
                    'target_id' => (string) $row->{$targetColumn},
                    'position' => (int) $row->position,
                    'media_asset_id' => (string) $row->media_asset_id,
                ];
            }
        }

        return $this->sortSnapshot($result);
    }

    /**
     * @param  list<array{family:string,row_id:string,target_id:string,position:int,media_asset_id:string}>  $snapshot
     * @return list<array{family:string,row_id:string,target_id:string,position:int,media_asset_id:string}>
     */
    private function sortSnapshot(array $snapshot): array
    {
        usort($snapshot, function (array $left, array $right): int {
            return [
                $left['family'],
                $left['target_id'],
                $left['position'],
                $left['row_id'],
            ] <=> [
                $right['family'],
                $right['target_id'],
                $right['position'],
                $right['row_id'],
            ];
        });

        return array_values($snapshot);
    }

    /**
     * @param  list<array<string, mixed>>  $snapshot
     */
    public static function fingerprint(array $snapshot): string
    {
        return hash('sha256', json_encode(array_values($snapshot), JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES));
    }

    /**
     * @param  array{family:string,target_id:string}  $assignment
     */
    private function targetKey(array $assignment): string
    {
        return $assignment['family'].'|'.$assignment['target_id'];
    }

    private function assignmentQuery(string $family)
    {
        return match ($family) {
            'product' => ProductMediaGalleryItem::query(),
            'variant' => VariantMediaGalleryItem::query(),
            'surface' => SurfaceMediaItem::query(),
            default => throw ValidationException::withMessages([
                'assignment' => ["Unknown media assignment family: $family."],
            ]),
        };
    }

    private function targetColumn(string $family): string
    {
        return match ($family) {
            'product' => 'product_id',
            'variant' => 'product_variant_id',
            'surface' => 'slot_key',
            default => throw ValidationException::withMessages([
                'assignment' => ["Unknown media assignment family: $family."],
            ]),
        };
    }

    private function assertEligible(MediaAsset $asset): void
    {
        if ($asset->lifecycle !== MediaAssetLifecycle::Admitted) {
            throw ValidationException::withMessages([
                'media_asset' => ["Media asset {$asset->id} is not admitted."],
            ]);
        }
        if ($asset->canonicalDerivative === null) {
            throw ValidationException::withMessages([
                'media_asset' => ["Media asset {$asset->id} has no canonical derivative."],
            ]);
        }
    }

    private function validateActorFingerprint(string $fingerprint): string
    {
        $validated = Validator::make(
            ['actor' => strtolower(trim($fingerprint))],
            ['actor' => ['required', 'string', 'regex:/^[a-f0-9]{64}$/']],
        )->validate();

        return $validated['actor'];
    }

    private function validateFingerprint(string $fingerprint): string
    {
        $validated = Validator::make(
            ['fingerprint' => strtolower(trim($fingerprint))],
            ['fingerprint' => ['required', 'string', 'regex:/^[a-f0-9]{64}$/']],
        )->validate();

        return $validated['fingerprint'];
    }

    private function validateReason(?string $reason): string
    {
        $validated = Validator::make(
            ['reason' => is_string($reason) ? trim($reason) : $reason],
            ['reason' => ['required', 'string', 'min:3', 'max:500']],
        )->validate();

        return $validated['reason'];
    }
}
