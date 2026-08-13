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
        $catalogSeeded = Product::query()->exists();
        if (! $catalogSeeded) {
            throw new CatalogUnavailableException('WALKA catalog is not seeded.');
        }

        $products = Product::query()
            ->with('variants')
            ->where('is_visible', true)
            ->orderBy('presentation_order')
            ->orderBy('id')
            ->get();

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
                shortDescription: $product->short_description,
                highlights: $product->highlights ?? [],
                featured: $product->is_featured,
                presentationOrder: $product->presentation_order,
            ),
        )->values()->all();
    }
}
