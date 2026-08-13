<?php

namespace Database\Seeders;

use App\Data\WalkaCatalogSeed;
use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

final class WalkaCatalogSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function (): void {
            $productIds = [];

            foreach (WalkaCatalogSeed::products() as $productOrder => $productData) {
                $productIds[] = $productData['id'];
                $existingProduct = Product::query()->find($productData['id']);

                $product = Product::query()->updateOrCreate(
                    ['id' => $productData['id']],
                    [
                        'name' => $existingProduct?->name ?? $productData['name'],
                        'category' => $productData['category'],
                        'features' => $existingProduct?->features ?? $productData['features'],
                        'facts' => $productData['facts'],
                        'sort_order' => $productOrder,
                    ],
                );

                if ($existingProduct === null) {
                    $product->forceFill([
                        'is_visible' => true,
                        'is_featured' => false,
                        'presentation_order' => $productOrder,
                    ])->save();
                }

                $variantIds = [];
                foreach ($productData['variants'] as $variantOrder => $variantData) {
                    $variantIds[] = $variantData['id'];
                    $existingVariant = ProductVariant::query()->find($variantData['id']);

                    $variant = ProductVariant::query()->updateOrCreate(
                        ['id' => $variantData['id']],
                        [
                            'product_id' => $productData['id'],
                            'color' => $existingVariant?->color ?? $variantData['color'],
                            'pantone' => $variantData['pantone'] ?? null,
                            'asin' => $variantData['asin'],
                            'sort_order' => $variantOrder,
                        ],
                    );

                    if ($existingVariant === null) {
                        $variant->forceFill([
                            'is_visible' => true,
                            'presentation_order' => $variantOrder,
                        ])->save();
                    }
                }

                ProductVariant::query()
                    ->where('product_id', $productData['id'])
                    ->whereNotIn('id', $variantIds)
                    ->delete();
            }

            Product::query()->whereNotIn('id', $productIds)->delete();
        });
    }
}
