<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\CanonicalMediaDeliveryService;
use App\Services\CanonicalMediaIntegrityException;
use App\Services\CanonicalMediaUnavailableException;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

final class CanonicalMediaController extends Controller
{
    public function __invoke(
        Request $request,
        string $mediaAsset,
        CanonicalMediaDeliveryService $delivery,
    ): Response {
        try {
            $verified = $delivery->verifiedBytes($mediaAsset);
        } catch (CanonicalMediaUnavailableException) {
            return response([
                'error' => [
                    'code' => 'canonical_media_not_available',
                    'message' => 'Canonical media is not available.',
                ],
            ], 404, ['Content-Type' => 'application/json']);
        } catch (CanonicalMediaIntegrityException) {
            return response([
                'error' => [
                    'code' => 'canonical_media_integrity_failed',
                    'message' => 'Canonical media failed integrity verification.',
                ],
            ], 503, ['Content-Type' => 'application/json']);
        }

        $cacheControl = 'public, max-age=300, stale-while-revalidate=3600';
        if ($request->header('If-None-Match') === $verified['etag']) {
            return response('', 304)
                ->header('ETag', $verified['etag'])
                ->header('Cache-Control', $cacheControl)
                ->header('X-Content-Type-Options', 'nosniff');
        }

        return response(
            $request->isMethod('HEAD') ? '' : $verified['bytes'],
            200,
            [
                'Content-Type' => $verified['mime'],
                'Content-Length' => (string) strlen($verified['bytes']),
                'ETag' => $verified['etag'],
                'Cache-Control' => $cacheControl,
                'X-Content-Type-Options' => 'nosniff',
                'Content-Disposition' => sprintf('inline; filename="%s"', $mediaAsset),
            ],
        );
    }
}
