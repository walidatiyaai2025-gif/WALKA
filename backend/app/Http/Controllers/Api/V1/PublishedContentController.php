<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use App\Services\Content\CategoryPresentationCatalogValidator;
use App\Services\Content\CategoryPresentationContentDefinition;
use App\Services\Content\HomeBannerContentDefinition;
use App\Services\Content\HomeFeaturedCatalogValidator;
use App\Services\Content\HomeFeaturedContentDefinition;
use App\Services\Content\HomeHeroContentDefinition;
use App\Services\Content\HomeLayoutContentDefinition;
use App\Services\Content\SearchPresentationCatalogValidator;
use App\Services\Content\SearchPresentationContentDefinition;
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

    public function homeBanner(Request $request): JsonResponse|Response
    {
        return $this->publishedResponse(
            request: $request,
            key: HomeBannerContentDefinition::KEY,
            type: HomeBannerContentDefinition::TYPE,
            schemaVersion: HomeBannerContentDefinition::SCHEMA_VERSION,
            etagFamily: 'home-banner',
            notPublishedMessage: 'Published Home banner is not available.',
            invalidMessage: 'Published Home banner failed its delivery contract.',
            normalize: HomeBannerContentDefinition::validateAndNormalize(...),
            extraMeta: fn (array $payload): array => [
                'active' => HomeBannerContentDefinition::isActiveAt($payload),
                'schedule_evaluated_at' => now()->utc()->toIso8601ZuluString(),
            ],
        );
    }

    public function categories(
        Request $request,
        CategoryPresentationCatalogValidator $catalogValidator,
    ): JsonResponse|Response {
        return $this->publishedResponse(
            request: $request,
            key: CategoryPresentationContentDefinition::KEY,
            type: CategoryPresentationContentDefinition::TYPE,
            schemaVersion: CategoryPresentationContentDefinition::SCHEMA_VERSION,
            etagFamily: 'categories',
            notPublishedMessage: 'Published category presentation is not available.',
            invalidMessage: 'Published category presentation failed its delivery contract.',
            normalize: fn (array $payload): array => $catalogValidator->validate(
                CategoryPresentationContentDefinition::validateAndNormalize($payload),
            ),
        );
    }

    public function search(
        Request $request,
        SearchPresentationCatalogValidator $catalogValidator,
    ): JsonResponse|Response {
        return $this->publishedResponse(
            request: $request,
            key: SearchPresentationContentDefinition::KEY,
            type: SearchPresentationContentDefinition::TYPE,
            schemaVersion: SearchPresentationContentDefinition::SCHEMA_VERSION,
            etagFamily: 'search',
            notPublishedMessage: 'Published Search presentation is not available.',
            invalidMessage: 'Published Search presentation failed its delivery contract.',
            normalize: fn (array $payload): array => $catalogValidator->validate(
                SearchPresentationContentDefinition::validateAndNormalize($payload),
            ),
        );
    }

    /**
     * @param  callable(array<string, mixed>): array<string, mixed>  $normalize
     * @param  callable(array<string, mixed>): array<string, mixed>|null  $extraMeta
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
        ?callable $extraMeta = null,
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
            $additionalMeta = $extraMeta === null ? [] : $extraMeta($publicPayload);
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
            'meta' => array_merge([
                'api_version' => 'v1',
            ], $additionalMeta),
        ])->header('ETag', $etag)
            ->header('Cache-Control', $cacheControl);
    }
}
