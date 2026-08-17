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
            ->where('is_visible', true)
            ->whereHas('categoryEntity', fn ($query) => $query->where('is_visible', true))
            ->whereHas('variants', fn ($query) => $query->where('is_visible', true))
            ->with([
                'categoryEntity',
                'variants' => fn ($query) => $query
                    ->where('is_visible', true)
                    ->orderBy('sort_order')
                    ->orderBy('id'),
            ])
            ->get()
            ->sortBy(fn (Product $product): string => sprintf(
                '%05d|%05d|%s',
                $product->categoryEntity?->sort_order ?? 65535,
                $product->sort_order,
                $product->id,
            ))
            ->values();

        if ($products->isEmpty()) {
            throw new CatalogUnavailableException('No visible WALKA catalog is available.');
        }

        return $products->map(
            static fn (Product $product): ProductData => new ProductData(
                id: $product->id,
                name: $product->name,
                category: $product->category_id ?? $product->category,
                features: $product->features ?? [],
                facts: $product->facts ?? [],
                variants: $product->variants->map(
                    static fn (ProductVariant $variant): ProductVariantData => new ProductVariantData(
                        id: $variant->id,
                        color: $variant->color,
                        asin: $variant->asin,
                        pantone: $variant->pantone,
                        swatchHex: $variant->swatch_hex,
                    ),
                )->values()->all(),
                shortDescription: $product->short_description,
            ),
        )->values()->all();
    }
}
