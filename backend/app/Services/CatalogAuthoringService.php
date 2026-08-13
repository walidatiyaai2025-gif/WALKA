<?php

namespace App\Services;

use App\Exceptions\CatalogRevisionConflictException;
use App\Exceptions\LastVisibleVariantException;
use App\Models\CatalogAudit;
use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

final class CatalogAuthoringService
{
    public function updateProduct(
        string $productId,
        array $attributes,
        int $expectedRevision,
        string $actorFingerprint,
    ): Product {
        return DB::transaction(function () use ($productId, $attributes, $expectedRevision, $actorFingerprint): Product {
            $product = Product::query()->lockForUpdate()->findOrFail($productId);
            $this->assertRevision('product', $product->id, $expectedRevision, $product->revision);

            $changes = $this->changesFor($product, $attributes);
            if ($changes !== []) {
                $product->fill($attributes);
                $product->revision = $expectedRevision + 1;
                $product->save();

                $this->audit(
                    actorFingerprint: $actorFingerprint,
                    targetType: 'product',
                    targetId: $product->id,
                    fromRevision: $expectedRevision,
                    toRevision: $product->revision,
                    changes: $changes,
                );
            }

            return $product->refresh()->load('variants');
        });
    }

    public function updateVariant(
        string $variantId,
        array $attributes,
        int $expectedRevision,
        string $actorFingerprint,
    ): ProductVariant {
        return DB::transaction(function () use ($variantId, $attributes, $expectedRevision, $actorFingerprint): ProductVariant {
            $variant = ProductVariant::query()->lockForUpdate()->findOrFail($variantId);
            $this->assertRevision('variant', $variant->id, $expectedRevision, $variant->revision);

            $attributes = $this->variantPresentationAttributes($attributes);

            if (
                ($attributes['is_visible'] ?? true) === false
                && (bool) $variant->getAttribute('is_visible')
            ) {
                $hasAnotherVisibleVariant = ProductVariant::query()
                    ->where('product_id', $variant->product_id)
                    ->where('id', '!=', $variant->id)
                    ->where('is_visible', true)
                    ->exists();

                if (! $hasAnotherVisibleVariant) {
                    throw new LastVisibleVariantException($variant->product_id);
                }
            }

            $changes = $this->changesFor($variant, $attributes);
            if ($changes !== []) {
                $variant->forceFill($attributes);
                $variant->revision = $expectedRevision + 1;
                $variant->save();

                $this->audit(
                    actorFingerprint: $actorFingerprint,
                    targetType: 'variant',
                    targetId: $variant->id,
                    fromRevision: $expectedRevision,
                    toRevision: $variant->revision,
                    changes: $changes,
                );
            }

            return $variant->refresh();
        });
    }

    private function assertRevision(string $targetType, string $targetId, int $expected, int $current): void
    {
        if ($expected !== $current) {
            throw new CatalogRevisionConflictException($targetType, $targetId, $expected, $current);
        }
    }

    /** @return array<string, mixed> */
    private function variantPresentationAttributes(array $attributes): array
    {
        $allowed = ['color', 'is_visible', 'presentation_order'];
        $unsupported = array_diff(array_keys($attributes), $allowed);
        if ($unsupported !== []) {
            throw new InvalidArgumentException('Unsupported variant presentation field: '.implode(', ', $unsupported));
        }

        $normalized = [];
        if (array_key_exists('color', $attributes)) {
            $normalized['color'] = trim((string) $attributes['color']);
        }
        if (array_key_exists('is_visible', $attributes)) {
            $normalized['is_visible'] = (bool) $attributes['is_visible'];
        }
        if (array_key_exists('presentation_order', $attributes)) {
            $normalized['presentation_order'] = (int) $attributes['presentation_order'];
        }

        return $normalized;
    }

    private function changesFor(Product|ProductVariant $model, array $attributes): array
    {
        $changes = [];

        foreach ($attributes as $field => $value) {
            $before = $model->getAttribute($field);
            if ($model instanceof ProductVariant && $field === 'is_visible') {
                $before = (bool) $before;
            }
            if ($model instanceof ProductVariant && $field === 'presentation_order') {
                $before = (int) $before;
            }

            if ($before !== $value) {
                $changes[$field] = [
                    'before' => $before,
                    'after' => $value,
                ];
            }
        }

        return $changes;
    }

    private function audit(
        string $actorFingerprint,
        string $targetType,
        string $targetId,
        int $fromRevision,
        int $toRevision,
        array $changes,
    ): void {
        CatalogAudit::query()->create([
            'actor_fingerprint' => $actorFingerprint,
            'target_type' => $targetType,
            'target_id' => $targetId,
            'action' => 'update',
            'from_revision' => $fromRevision,
            'to_revision' => $toRevision,
            'changes' => $changes,
            'created_at' => now(),
        ]);
    }
}
