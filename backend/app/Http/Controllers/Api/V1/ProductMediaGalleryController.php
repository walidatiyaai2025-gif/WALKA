<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\ProductMediaGalleryService;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;

final class ProductMediaGalleryController extends Controller
{
    public function __invoke(ProductMediaGalleryService $galleries): JsonResponse
    {
        try {
            $products = $galleries->publicPayload();
        } catch (ValidationException) {
            return response()->json([
                'error' => [
                    'code' => 'media_gallery_invalid',
                    'message' => 'Published product media gallery metadata failed its delivery contract.',
                ],
            ], 503);
        }

        return response()->json([
            'data' => [
                'schema_version' => 1,
                'products' => $products,
            ],
            'meta' => [
                'api_version' => 'v1',
                'binary_delivery' => 'not_enabled',
            ],
        ])->header('Cache-Control', 'public, max-age=60, stale-while-revalidate=300');
    }
}
