<?php

namespace Database\Seeders;

use App\Data\WalkaCatalogSeed;
use App\Models\CatalogCategory;
use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

final class WalkaCatalogSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function (): void {
            $categoryOrder = [];
            $swatches = [
                'drawer-organizer:white' => '#F6F3EC',
                'drawer-organizer:gray' => '#E1E4E7',
                'lunch-box:blue' => '#436B73',
                'lunch-box:pink' => '#E7C2C7',
                'lunch-box:green' => '#B9B995',
            ];

            foreach (WalkaCatalogSeed::products() as $productOrder => $productData) {
                $categoryId = $productData['category'];
                if (! array_key_exists($categoryId, $categoryOrder)) {
                    $categoryOrder[$categoryId] = count($categoryOrder);
                    CatalogCategory::query()->firstOrCreate(
                        ['id' => $categoryId],
                        [
                            'name' => str($categoryId)->replace('-', ' ')->title()->toString(),
                            'is_visible' => true,
                            'sort_order' => $categoryOrder[$categoryId],
                            'revision' => 1,
                        ],
                    );
                }

                Product::query()->firstOrCreate(
                    ['id' => $productData['id']],
                    [
                        'name' => $productData['name'],
                        'category' => $categoryId,
                        'category_id' => $categoryId,
                        'features' => $productData['features'],
                        'facts' => $productData['facts'],
                        'sort_order' => $productOrder,
                        'is_visible' => true,
                        'revision' => 1,
                    ],
                );

                foreach ($productData['variants'] as $variantOrder => $variantData) {
                    ProductVariant::query()->firstOrCreate(
                        ['id' => $variantData['id']],
                        [
                            'product_id' => $productData['id'],
                            'color' => $variantData['color'],
                            'swatch_hex' => $swatches[$variantData['id']] ?? null,
                            'pantone' => $variantData['pantone'] ?? null,
                            'asin' => $variantData['asin'],
                            'sort_order' => $variantOrder,
                            'is_visible' => true,
                            'revision' => 1,
                        ],
                    );
                }
            }
        });
    }
}
