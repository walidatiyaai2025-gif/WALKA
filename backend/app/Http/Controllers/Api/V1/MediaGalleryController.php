<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\MediaGalleryService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Validation\ValidationException;

final class MediaGalleryController extends Controller
{
    public function __invoke(
        Request $request,
        MediaGalleryService $galleries,
    ): JsonResponse|Response {
        try {
            $snapshot = $galleries->publicSnapshot();
        } catch (ValidationException) {
            return response()->json([
                'error' => [
                    'code' => 'media_gallery_invalid',
                    'message' => 'Published media gallery metadata failed its delivery contract.',
                ],
            ], 503);
        }

        $etag = sprintf(
            '"walka-media-galleries-%s"',
            substr($snapshot['revision_token'], 0, 24),
        );
        $cacheControl = 'public, max-age=60, stale-while-revalidate=300';

        if ($request->header('If-None-Match') === $etag) {
            return response('', 304)
                ->header('ETag', $etag)
                ->header('Cache-Control', $cacheControl);
        }

        return response()->json([
            'data' => $snapshot,
            'meta' => [
                'api_version' => 'v1',
                'fallback' => 'variant_without_explicit_items_uses_product_gallery',
            ],
        ])->header('ETag', $etag)
            ->header('Cache-Control', $cacheControl);
    }
}
