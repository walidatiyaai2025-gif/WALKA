<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use App\Services\Content\HomeHeroContentDefinition;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Validation\ValidationException;

final class PublishedContentController extends Controller
{
    public function home(Request $request): JsonResponse|Response
    {
        $entry = ContentEntry::query()
            ->where('content_key', HomeHeroContentDefinition::KEY)
            ->where('content_type', HomeHeroContentDefinition::TYPE)
            ->whereNotNull('published_revision')
            ->first();

        if ($entry === null || $entry->published_payload === null) {
            return response()->json([
                'error' => [
                    'code' => 'content_not_published',
                    'message' => 'Published Home content is not available.',
                ],
            ], 404);
        }

        try {
            $publicPayload = HomeHeroContentDefinition::validateAndNormalize(
                $entry->published_payload,
            );
        } catch (ValidationException) {
            return response()->json([
                'error' => [
                    'code' => 'content_invalid',
                    'message' => 'Published Home content failed its delivery contract.',
                ],
            ], 503);
        }

        $revision = (int) $entry->published_revision;
        $etag = '"walka-home-hero-r'.$revision.'"';
        $cacheControl = 'public, max-age=60, stale-while-revalidate=300';

        if ($request->header('If-None-Match') === $etag) {
            return response('', 304)
                ->header('ETag', $etag)
                ->header('Cache-Control', $cacheControl);
        }

        return response()->json([
            'data' => [
                'key' => HomeHeroContentDefinition::KEY,
                'type' => HomeHeroContentDefinition::TYPE,
                'schema_version' => HomeHeroContentDefinition::SCHEMA_VERSION,
                'revision' => $revision,
                'published_at' => $entry->published_at?->toIso8601String(),
                'payload' => $publicPayload,
            ],
            'meta' => [
                'api_version' => 'v1',
            ],
        ])->header('ETag', $etag)
            ->header('Cache-Control', $cacheControl);
    }
}
