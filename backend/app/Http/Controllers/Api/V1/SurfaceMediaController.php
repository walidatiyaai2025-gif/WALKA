<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\SurfaceMediaService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Validation\ValidationException;

final class SurfaceMediaController extends Controller
{
    public function __invoke(
        Request $request,
        SurfaceMediaService $surfaceMedia,
    ): JsonResponse|Response {
        try {
            $slots = $surfaceMedia->publicPayload();
        } catch (ValidationException) {
            return response()->json([
                'error' => [
                    'code' => 'surface_media_invalid',
                    'message' => 'Published surface media metadata failed its delivery contract.',
                ],
            ], 503);
        }

        $revisionToken = hash(
            'sha256',
            json_encode($slots, JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES),
        );
        $etag = sprintf('"walka-surface-media-%s"', substr($revisionToken, 0, 24));
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
                'slots' => $slots,
            ],
            'meta' => [
                'api_version' => 'v1',
                'binary_delivery' => 'canonical_by_media_id',
            ],
        ])->header('ETag', $etag)
            ->header('Cache-Control', $cacheControl);
    }
}
