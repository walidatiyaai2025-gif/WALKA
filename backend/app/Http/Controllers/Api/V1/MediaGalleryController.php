<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Services\MediaGalleryService;
use Illuminate\Http\JsonResponse;

final class MediaGalleryController extends Controller
{
    public function __construct(private readonly MediaGalleryService $galleries) {}

    public function product(Product $product): JsonResponse
    {
        return response()->json([
            'data' => $this->galleries->publicProductGallery($product),
        ]);
    }

    public function variant(ProductVariant $variant): JsonResponse
    {
        return response()->json([
            'data' => $this->galleries->publicVariantGallery($variant),
        ]);
    }
}
