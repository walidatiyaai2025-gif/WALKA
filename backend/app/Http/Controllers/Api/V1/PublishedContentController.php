<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use App\Services\Content\HomeFeaturedCatalogValidator;
use App\Services\Content\HomeFeaturedContentDefinition;
use App\Services\Content\HomeHeroContentDefinition;
use App\Services\Content\HomeLayoutContentDefinition;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Validation\ValidationException;

final class PublishedContentController extends Controller
{
    public function home(Request $request): JsonResponse|Response
    {
        return $this->publishedResponse(
            request: $request,
            key: HomeHeroContentDefinition::KEY,
            type: HomeHeroContentDefinition::TYPE,
            schemaVersion: HomeHeroContentDefinition::SCHEMA_VERSION,
            etagFamily: 'home-hero',
            notPublishedMessage: 'Published Home content is not available.',
            invalidMessage: 'Published Home content failed its delivery contract.',
            normalize: HomeHeroContentDefinition::validateAndNormalize(...),
        );
    }

    public function homeLayout(Request $request): JsonResponse|Response
    {
        return $this->publishedResponse(
            request: $request,
            key: HomeLayoutContentDefinition::KEY,
            type: HomeLayoutContentDefinition::TYPE,
            schemaVersion: HomeLayoutContentDefinition::SCHEMA_VERSION,
            etagFamily: 'home-layout',
            notPublishedMessage: 'Published Home layout is not available.',
            invalidMessage: 'Published Home layout failed its delivery contract.',
            normalize: HomeLayoutContentDefinition::validateAndNormalize(...),
        );
    }

    public function homeFeatured(
        Request $request,
        HomeFeaturedCatalogValidator $catalogValidator,
    ): JsonResponse|Response {
        return $this->publishedResponse(
            request: $request,
            key: HomeFeaturedContentDefinition::KEY,
            type: HomeFeaturedContentDefinition::TYPE,
            schemaVersion: HomeFeaturedContentDefinition::SCHEMA_VERSION,
            etagFamily: 'home-featured',
            notPublishedMessage: 'Published Home featured merchandising is not available.',
            invalidMessage: 'Published Home featured merchandising failed its delivery contract.',
            normalize: fn (array $payload): array => $catalogValidator->validate(
                HomeFeaturedContentDefinition::validateAndNormalize($payload),
            ),
        );
    }

    /**
     * @param  callable(array<string, mixed>): array<string, mixed>  $normalize
     */
    private function publishedResponse(
        Request $request,
        string $key,
        string $type,
        int $schemaVersion,
        string $etagFamily,
        string $notPublishedMessage,
        string $invalidMessage,
        callable $normalize,
    ): JsonResponse|Response {
        $entry = ContentEntry::query()
            ->where('content_key', $key)
            ->where('content_type', $type)
            ->whereNotNull('published_revision')
            ->first();

        if ($entry === null || $entry->published_payload === null) {
            return response()->json([
                'error' => [
                    'code' => 'content_not_published',
                    'message' => $notPublishedMessage,
                ],
            ], 404);
        }

        try {
            $publicPayload = $normalize($entry->published_payload);
        } catch (ValidationException) {
            return response()->json([
                'error' => [
                    'code' => 'content_invalid',
                    'message' => $invalidMessage,
                ],
            ], 503);
        }

        $revision = (int) $entry->published_revision;
        $etag = sprintf('"walka-%s-r%d"', $etagFamily, $revision);
        $cacheControl = 'public, max-age=60, stale-while-revalidate=300';

        if ($request->header('If-None-Match') === $etag) {
            return response('', 304)
                ->header('ETag', $etag)
                ->header('Cache-Control', $cacheControl);
        }

        return response()->json([
            'data' => [
                'key' => $key,
                'type' => $type,
                'schema_version' => $schemaVersion,
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
