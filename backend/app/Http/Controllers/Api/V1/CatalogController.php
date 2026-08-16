<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\CatalogRepository;
use App\Data\ProductData;
use App\Exceptions\CatalogUnavailableException;
use App\Http\Controllers\Controller;
use App\Models\CatalogCategory;
use Illuminate\Http\JsonResponse;

final class CatalogController extends Controller
{
    public function __construct(private readonly CatalogRepository $catalog) {}

    public function __invoke(): JsonResponse
    {
        try {
            $products = array_map(
                static fn (ProductData $product): array => $product->toArray(),
                $this->catalog->all(),
            );
        } catch (CatalogUnavailableException) {
            return response()->json([
                'error' => [
                    'code' => 'catalog_unavailable',
                    'message' => 'No visible WALKA catalog is currently available.',
                ],
            ], 503);
        }

        $categories = CatalogCategory::query()
            ->where('is_visible', true)
            ->whereHas('products', fn ($query) => $query
                ->where('is_visible', true)
                ->whereHas('variants', fn ($variants) => $variants->where('is_visible', true)))
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get()
            ->map(fn (CatalogCategory $category): array => [
                'id' => $category->id,
                'name' => $category->name,
                'sort_order' => $category->sort_order,
            ])
            ->values();

        return response()->json([
            'data' => $products,
            'meta' => [
                'release' => config('walka.release'),
                'api_version' => config('walka.api_version'),
                'purchase_mode' => config('walka.purchase_mode'),
                'categories' => $categories,
            ],
        ]);
    }
}
