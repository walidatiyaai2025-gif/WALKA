<?php

namespace App\Http\Controllers\Api\V1;

use App\Data\ProductData;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;

final class CatalogController extends Controller
{
    public function __invoke(): JsonResponse
    {
        $products = array_map(
            static fn (array $product): array => ProductData::fromArray($product)->toArray(),
            config('walka.products', []),
        );

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
