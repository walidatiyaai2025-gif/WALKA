<?php

namespace App\Services;

use App\Exceptions\CatalogRevisionConflictException;
use App\Models\CatalogAudit;
use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Support\Facades\DB;

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

            $changes = $this->changesFor($variant, $attributes);
            if ($changes !== []) {
                $variant->fill($attributes);
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

    private function changesFor(Product|ProductVariant $model, array $attributes): array
    {
        $changes = [];

        foreach ($attributes as $field => $value) {
            $before = $model->getAttribute($field);
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
