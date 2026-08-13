<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\ProductMediaGalleryService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Validation\ValidationException;

final class ProductMediaGalleryController extends Controller
{
    public function __invoke(
        Request $request,
        ProductMediaGalleryService $galleries,
    ): JsonResponse|Response {
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

        $revisionToken = hash(
            'sha256',
            json_encode($products, JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES),
        );
        $etag = sprintf('"walka-product-media-%s"', substr($revisionToken, 0, 24));
        $cacheControl = 'public, max-age=60, stale-while-revalidate=300';

        if ($request->header('If-None-Match') === $etag) {
            return response('', 304)
                ->header('ETag', $etag)
                ->header('Cache-Control', $cacheControl);
        }

        return response()->json([
            'data' => [
                'schema_version' => 1,
                'revision_token' => $revisionToken,
                'products' => $products,
            ],
            'meta' => [
                'api_version' => 'v1',
                'binary_delivery' => 'canonical_by_media_id',
            ],
        ])->header('ETag', $etag)
            ->header('Cache-Control', $cacheControl);
    }
}
