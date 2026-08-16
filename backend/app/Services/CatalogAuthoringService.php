<?php

namespace App\Services;

use App\Exceptions\CatalogRevisionConflictException;
use App\Models\CatalogAudit;
use App\Models\CatalogCategory;
use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

final class CatalogAuthoringService
{
    public function createCategory(array $attributes, string $actorFingerprint): CatalogCategory
    {
        return DB::transaction(function () use ($attributes, $actorFingerprint): CatalogCategory {
            $category = CatalogCategory::query()->create([
                ...$attributes,
                'revision' => 1,
            ]);

            $this->audit(
                actorFingerprint: $actorFingerprint,
                targetType: 'category',
                targetId: $category->id,
                action: 'create',
                fromRevision: 0,
                toRevision: 1,
                changes: $this->creationChanges($category),
            );

            return $category->refresh();
        });
    }

    public function updateCategory(
        string $categoryId,
        array $attributes,
        int $expectedRevision,
        string $actorFingerprint,
    ): CatalogCategory {
        return DB::transaction(function () use ($categoryId, $attributes, $expectedRevision, $actorFingerprint): CatalogCategory {
            $category = CatalogCategory::query()->lockForUpdate()->findOrFail($categoryId);
            $this->assertRevision('category', $category->id, $expectedRevision, $category->revision);

            $changes = $this->changesFor($category, $attributes);
            if ($changes !== []) {
                $category->fill($attributes);
                $category->revision = $expectedRevision + 1;
                $category->save();

                $this->audit(
                    actorFingerprint: $actorFingerprint,
                    targetType: 'category',
                    targetId: $category->id,
                    action: 'update',
                    fromRevision: $expectedRevision,
                    toRevision: $category->revision,
                    changes: $changes,
                );
            }

            return $category->refresh();
        });
    }

    public function deleteCategory(string $categoryId, int $expectedRevision, string $actorFingerprint): void
    {
        DB::transaction(function () use ($categoryId, $expectedRevision, $actorFingerprint): void {
            $category = CatalogCategory::query()->lockForUpdate()->findOrFail($categoryId);
            $this->assertRevision('category', $category->id, $expectedRevision, $category->revision);

            if (Product::query()->where('category_id', $category->id)->exists()) {
                throw ValidationException::withMessages([
                    'category' => 'Move or delete products in this category before deleting it.',
                ]);
            }

            $before = $category->toArray();
            $category->delete();
            $this->audit(
                actorFingerprint: $actorFingerprint,
                targetType: 'category',
                targetId: $categoryId,
                action: 'delete',
                fromRevision: $expectedRevision,
                toRevision: $expectedRevision + 1,
                changes: ['deleted' => ['before' => $before, 'after' => null]],
            );
        });
    }

    public function createProduct(array $attributes, string $actorFingerprint): Product
    {
        return DB::transaction(function () use ($attributes, $actorFingerprint): Product {
            $categoryId = (string) $attributes['category_id'];
            $this->requireCategory($categoryId);

            $product = Product::query()->create([
                ...$attributes,
                'category' => $categoryId,
                'revision' => 1,
            ]);

            $this->audit(
                actorFingerprint: $actorFingerprint,
                targetType: 'product',
                targetId: $product->id,
                action: 'create',
                fromRevision: 0,
                toRevision: 1,
                changes: $this->creationChanges($product),
            );

            return $product->refresh()->load(['categoryEntity', 'variants']);
        });
    }

    public function updateProduct(
        string $productId,
        array $attributes,
        int $expectedRevision,
        string $actorFingerprint,
    ): Product {
        return DB::transaction(function () use ($productId, $attributes, $expectedRevision, $actorFingerprint): Product {
            $product = Product::query()->lockForUpdate()->findOrFail($productId);
            $this->assertRevision('product', $product->id, $expectedRevision, $product->revision);

            if (array_key_exists('category_id', $attributes)) {
                $categoryId = (string) $attributes['category_id'];
                $this->requireCategory($categoryId);
                $attributes['category'] = $categoryId;
            }

            $changes = $this->changesFor($product, $attributes);
            if ($changes !== []) {
                $product->fill($attributes);
                $product->revision = $expectedRevision + 1;
                $product->save();

                $this->audit(
                    actorFingerprint: $actorFingerprint,
                    targetType: 'product',
                    targetId: $product->id,
                    action: 'update',
                    fromRevision: $expectedRevision,
                    toRevision: $product->revision,
                    changes: $changes,
                );
            }

            return $product->refresh()->load(['categoryEntity', 'variants']);
        });
    }

    public function deleteProduct(string $productId, int $expectedRevision, string $actorFingerprint): void
    {
        DB::transaction(function () use ($productId, $expectedRevision, $actorFingerprint): void {
            $product = Product::query()->with('variants')->lockForUpdate()->findOrFail($productId);
            $this->assertRevision('product', $product->id, $expectedRevision, $product->revision);

            $before = $product->toArray();
            $product->delete();
            $this->audit(
                actorFingerprint: $actorFingerprint,
                targetType: 'product',
                targetId: $productId,
                action: 'delete',
                fromRevision: $expectedRevision,
                toRevision: $expectedRevision + 1,
                changes: ['deleted' => ['before' => $before, 'after' => null]],
            );
        });
    }

    public function createVariant(array $attributes, string $actorFingerprint): ProductVariant
    {
        return DB::transaction(function () use ($attributes, $actorFingerprint): ProductVariant {
            Product::query()->findOrFail((string) $attributes['product_id']);

            $variant = ProductVariant::query()->create([
                ...$attributes,
                'revision' => 1,
            ]);

            $this->audit(
                actorFingerprint: $actorFingerprint,
                targetType: 'variant',
                targetId: $variant->id,
                action: 'create',
                fromRevision: 0,
                toRevision: 1,
                changes: $this->creationChanges($variant),
            );

            return $variant->refresh();
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

            unset($attributes['product_id'], $attributes['id']);
            $changes = $this->changesFor($variant, $attributes);
            if ($changes !== []) {
                $variant->fill($attributes);
                $variant->revision = $expectedRevision + 1;
                $variant->save();

                $this->audit(
                    actorFingerprint: $actorFingerprint,
                    targetType: 'variant',
                    targetId: $variant->id,
                    action: 'update',
                    fromRevision: $expectedRevision,
                    toRevision: $variant->revision,
                    changes: $changes,
                );
            }

            return $variant->refresh();
        });
    }

    public function deleteVariant(string $variantId, int $expectedRevision, string $actorFingerprint): void
    {
        DB::transaction(function () use ($variantId, $expectedRevision, $actorFingerprint): void {
            $variant = ProductVariant::query()->lockForUpdate()->findOrFail($variantId);
            $this->assertRevision('variant', $variant->id, $expectedRevision, $variant->revision);

            $before = $variant->toArray();
            $variant->delete();
            $this->audit(
                actorFingerprint: $actorFingerprint,
                targetType: 'variant',
                targetId: $variantId,
                action: 'delete',
                fromRevision: $expectedRevision,
                toRevision: $expectedRevision + 1,
                changes: ['deleted' => ['before' => $before, 'after' => null]],
            );
        });
    }

    private function requireCategory(string $categoryId): void
    {
        if (! CatalogCategory::query()->whereKey($categoryId)->exists()) {
            throw ValidationException::withMessages([
                'category_id' => 'Select an existing Dashboard category.',
            ]);
        }
    }

    private function assertRevision(string $targetType, string $targetId, int $expected, int $current): void
    {
        if ($expected !== $current) {
            throw new CatalogRevisionConflictException($targetType, $targetId, $expected, $current);
        }
    }

    private function changesFor(Model $model, array $attributes): array
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

    private function creationChanges(Model $model): array
    {
        return collect($model->getAttributes())
            ->except(['created_at', 'updated_at'])
            ->mapWithKeys(fn (mixed $value, string $field): array => [
                $field => ['before' => null, 'after' => $value],
            ])
            ->all();
    }

    private function audit(
        string $actorFingerprint,
        string $targetType,
        string $targetId,
        string $action,
        int $fromRevision,
        int $toRevision,
        array $changes,
    ): void {
        CatalogAudit::query()->create([
            'actor_fingerprint' => $actorFingerprint,
            'target_type' => $targetType,
            'target_id' => $targetId,
            'action' => $action,
            'from_revision' => $fromRevision,
            'to_revision' => $toRevision,
            'changes' => $changes,
            'created_at' => now(),
        ]);
    }
}
