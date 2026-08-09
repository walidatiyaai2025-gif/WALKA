<?php

namespace App\Repositories;

use App\Contracts\CatalogRepository;
use App\Data\ProductData;
use App\Data\ProductVariantData;
use App\Exceptions\CatalogUnavailableException;
use App\Models\Product;
use App\Models\ProductVariant;

final class EloquentCatalogRepository implements CatalogRepository
{
    public function all(): array
    {
        $products = Product::query()
            ->with('variants')
            ->orderBy('sort_order')
            ->get();

        if ($products->isEmpty()) {
            throw new CatalogUnavailableException('WALKA catalog is not seeded.');
        }

        return $products->map(
            static fn (Product $product): ProductData => new ProductData(
                id: $product->id,
                name: $product->name,
                category: $product->category,
                features: $product->features ?? [],
                facts: $product->facts ?? [],
                variants: $product->variants->map(
                    static fn (ProductVariant $variant): ProductVariantData => new ProductVariantData(
                        id: $variant->id,
                        color: $variant->color,
                        asin: $variant->asin,
                        pantone: $variant->pantone,
                    ),
                )->values()->all(),
            ),
        )->values()->all();
    }
}
