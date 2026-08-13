<?php

namespace App\Services;

use App\Enums\MediaAssetLifecycle;
use App\Enums\MediaAssetPurpose;
use App\Models\MediaAsset;
use App\Models\Product;
use App\Models\SurfaceMediaItem;
use Illuminate\Database\Eloquent\Collection as EloquentCollection;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

final class SurfaceMediaService
{
    /**
     * @return array<string, array{label:string,purpose:MediaAssetPurpose,max_items:int,category_id:string|null}>
     */
    public static function slotDefinitions(): array
    {
        return [
            'home.hero' => [
                'label' => 'Home Hero',
                'purpose' => MediaAssetPurpose::Home,
                'max_items' => 1,
                'category_id' => null,
            ],
            'home.editorial.small_changes' => [
                'label' => 'Home · Small Changes editorial',
                'purpose' => MediaAssetPurpose::Editorial,
                'max_items' => 1,
                'category_id' => null,
            ],
            'category:drawer-organization' => [
                'label' => 'Category · Drawer Organization',
                'purpose' => MediaAssetPurpose::Category,
                'max_items' => 1,
                'category_id' => 'drawer-organization',
            ],
            'category:lunch' => [
                'label' => 'Category · Lunch',
                'purpose' => MediaAssetPurpose::Category,
                'max_items' => 1,
                'category_id' => 'lunch',
            ],
        ];
    }

    /**
     * @return EloquentCollection<int, MediaAsset>
     */
    public function eligibleAssets(string $slotKey): EloquentCollection
    {
        $definition = $this->definition($slotKey);
        $this->assertCategoryIdentity($definition);

        return MediaAsset::query()
            ->with('canonicalDerivative')
            ->where('purpose', $definition['purpose']->value)
            ->where('lifecycle', MediaAssetLifecycle::Admitted->value)
            ->whereHas('canonicalDerivative')
            ->orderBy('created_at')
            ->get();
    }

    /**
     * @param  list<string>  $mediaAssetIds
     */
    public function replace(
        string $slotKey,
        array $mediaAssetIds,
        string $expectedFingerprint,
        string $actorFingerprint,
    ): void {
        $definition = $this->definition($slotKey);
        $this->assertCategoryIdentity($definition);
        $this->assertActorFingerprint($actorFingerprint);
        $this->assertGalleryFingerprint($expectedFingerprint);
        $mediaAssetIds = $this->normalizeMediaIds($mediaAssetIds, $definition['max_items']);

        DB::transaction(function () use (
            $actorFingerprint,
            $definition,
            $expectedFingerprint,
            $mediaAssetIds,
            $slotKey,
        ): void {
            $currentIds = SurfaceMediaItem::query()
                ->where('slot_key', $slotKey)
                ->orderBy('position')
                ->lockForUpdate()
                ->pluck('media_asset_id')
                ->all();
            if (! hash_equals($expectedFingerprint, self::fingerprint($currentIds))) {
                throw ValidationException::withMessages([
                    'gallery' => ['This media slot changed in another session. Reload before saving.'],
                ]);
            }

            $this->validatedAssignableAssets($mediaAssetIds, $definition['purpose']);

            SurfaceMediaItem::query()->where('slot_key', $slotKey)->delete();
            foreach ($mediaAssetIds as $index => $mediaAssetId) {
                SurfaceMediaItem::query()->create([
                    'slot_key' => $slotKey,
                    'media_asset_id' => $mediaAssetId,
                    'position' => $index + 1,
                    'created_by_fingerprint' => strtolower($actorFingerprint),
                ]);
            }
        });
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function publicPayload(): array
    {
        $definitions = self::slotDefinitions();
        $itemsBySlot = SurfaceMediaItem::query()
            ->with('mediaAsset.canonicalDerivative')
            ->orderBy('position')
            ->get()
            ->groupBy('slot_key');

        $payload = [];
        foreach ($definitions as $slotKey => $definition) {
            $this->assertCategoryIdentity($definition);
            $slotItems = $itemsBySlot->get($slotKey, collect());

            $payload[] = [
                'slot_key' => $slotKey,
                'purpose' => $definition['purpose']->value,
                'category_id' => $definition['category_id'],
                'items' => $this->serializeItems($slotItems, $definition['purpose']),
            ];
        }

        return $payload;
    }

    /**
     * @param  list<string>  $ids
     */
    public static function fingerprint(array $ids): string
    {
        return hash('sha256', json_encode(array_values($ids), JSON_THROW_ON_ERROR));
    }

    /**
     * @return array{label:string,purpose:MediaAssetPurpose,max_items:int,category_id:string|null}
     */
    public function definition(string $slotKey): array
    {
        $definitions = self::slotDefinitions();
        if (! array_key_exists($slotKey, $definitions)) {
            throw ValidationException::withMessages([
                'slot_key' => ['The requested media slot is not part of the compiled WALKA surface allowlist.'],
            ]);
        }

        return $definitions[$slotKey];
    }

    /**
     * @param  array{label:string,purpose:MediaAssetPurpose,max_items:int,category_id:string|null}  $definition
     */
    private function assertCategoryIdentity(array $definition): void
    {
        $categoryId = $definition['category_id'];
        if ($categoryId === null) {
            return;
        }

        if (! Product::query()->where('category', $categoryId)->exists()) {
            throw ValidationException::withMessages([
                'slot_key' => ["Category media slot references unknown protected category $categoryId."],
            ]);
        }
    }

    /**
     * @param  array<int, mixed>  $ids
     * @return list<string>
     */
    private function normalizeMediaIds(array $ids, int $maxItems): array
    {
        if (! array_is_list($ids)) {
            throw ValidationException::withMessages([
                'media_ids' => ['Surface media IDs must be an ordered list.'],
            ]);
        }
        if (count($ids) > $maxItems) {
            throw ValidationException::withMessages([
                'media_ids' => [sprintf('This media slot may contain at most %d item(s).', $maxItems)],
            ]);
        }

        $normalized = [];
        foreach ($ids as $index => $id) {
            if (! is_string($id) || trim($id) === '') {
                throw ValidationException::withMessages([
                    "media_ids.$index" => ['Surface media ID must be a non-empty string.'],
                ]);
            }
            $normalized[] = trim($id);
        }
        if (count(array_unique($normalized)) !== count($normalized)) {
            throw ValidationException::withMessages([
                'media_ids' => ['A media asset may appear only once in the same surface slot.'],
            ]);
        }

        return $normalized;
    }

    /**
     * @param  list<string>  $ids
     * @return EloquentCollection<int, MediaAsset>
     */
    private function validatedAssignableAssets(
        array $ids,
        MediaAssetPurpose $requiredPurpose,
    ): EloquentCollection {
        if ($ids === []) {
            return new EloquentCollection;
        }

        $assets = MediaAsset::query()
            ->with('canonicalDerivative')
            ->whereIn('id', $ids)
            ->lockForUpdate()
            ->get()
            ->keyBy('id');

        foreach ($ids as $id) {
            $asset = $assets->get($id);
            if ($asset instanceof MediaAsset === false) {
                throw ValidationException::withMessages([
                    'media_ids' => ["Media asset $id does not exist."],
                ]);
            }
            $this->assertAssignable($asset, $requiredPurpose);
        }

        return $assets->values();
    }

    private function assertAssignable(
        MediaAsset $asset,
        MediaAssetPurpose $requiredPurpose,
    ): void {
        if ($asset->purpose !== $requiredPurpose) {
            throw ValidationException::withMessages([
                'media_ids' => [
                    "Media asset {$asset->id} is not approved for {$requiredPurpose->value} presentation.",
                ],
            ]);
        }
        if ($asset->lifecycle !== MediaAssetLifecycle::Admitted) {
            throw ValidationException::withMessages([
                'media_ids' => ["Media asset {$asset->id} is not admitted."],
            ]);
        }
        if ($asset->canonicalDerivative === null) {
            throw ValidationException::withMessages([
                'media_ids' => ["Media asset {$asset->id} has no canonical derivative."],
            ]);
        }
    }

    /**
     * @param  iterable<SurfaceMediaItem>  $items
     * @return list<array<string, mixed>>
     */
    private function serializeItems(
        iterable $items,
        MediaAssetPurpose $requiredPurpose,
    ): array {
        $result = [];
        foreach ($items as $item) {
            $asset = $item->mediaAsset;
            if ($asset instanceof MediaAsset === false) {
                throw ValidationException::withMessages([
                    'gallery' => ['Published surface media references a missing media asset.'],
                ]);
            }
            $this->assertAssignable($asset, $requiredPurpose);
            $derivative = $asset->canonicalDerivative;

            $result[] = [
                'media_id' => $asset->id,
                'semantic_label' => $asset->semantic_label,
                'canonical' => [
                    'mime' => $derivative->mime,
                    'width' => $derivative->width,
                    'height' => $derivative->height,
                    'sha256' => $derivative->sha256,
                ],
            ];
        }

        return $result;
    }

    private function assertActorFingerprint(string $fingerprint): void
    {
        if (! preg_match('/^[a-f0-9]{64}$/i', $fingerprint)) {
            throw ValidationException::withMessages([
                'actor' => ['A valid actor fingerprint is required.'],
            ]);
        }
    }

    private function assertGalleryFingerprint(string $fingerprint): void
    {
        if (! preg_match('/^[a-f0-9]{64}$/i', $fingerprint)) {
            throw ValidationException::withMessages([
                'expected_fingerprint' => ['A valid media-slot fingerprint is required.'],
            ]);
        }
    }
}
