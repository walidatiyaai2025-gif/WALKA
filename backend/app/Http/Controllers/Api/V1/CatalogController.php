<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\CatalogRepository;
use App\Data\ProductData;
use App\Exceptions\CatalogUnavailableException;
use App\Http\Controllers\Controller;
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
                    'message' => 'WALKA catalog is not seeded.',
                ],
            ], 503);
        }

        return response()->json([
            'data' => $products,
            'meta' => [
                'release' => config('walka.release'),
                'api_version' => config('walka.api_version'),
                'purchase_mode' => config('walka.purchase_mode'),
            ],
        ]);
    }
}
