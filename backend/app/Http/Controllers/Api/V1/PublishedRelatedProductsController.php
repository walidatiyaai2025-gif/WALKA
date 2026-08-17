<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use App\Services\Content\RelatedProductsCatalogValidator;
use App\Services\Content\RelatedProductsContentDefinition;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Validation\ValidationException;

final class PublishedRelatedProductsController extends Controller
{
    public function __invoke(
        Request $request,
        RelatedProductsCatalogValidator $catalogValidator,
    ): JsonResponse|Response {
        $entry = ContentEntry::query()
            ->where('content_key', RelatedProductsContentDefinition::KEY)
            ->where('content_type', RelatedProductsContentDefinition::TYPE)
            ->whereNotNull('published_revision')
            ->first();

        if ($entry === null || $entry->published_payload === null) {
            return response()->json([
                'error' => [
                    'code' => 'content_not_published',
                    'message' => 'Published related products are not available.',
                ],
            ], 404);
        }

        try {
            $payload = $catalogValidator->validate(
                RelatedProductsContentDefinition::validateAndNormalize(
                    $entry->published_payload,
                ),
            );
        } catch (ValidationException) {
            return response()->json([
                'error' => [
                    'code' => 'content_invalid',
                    'message' => 'Published related products failed current catalog validation.',
                ],
            ], 503);
        }

        $revision = (int) $entry->published_revision;
        $etag = sprintf('"walka-related-products-r%d"', $revision);
        $cacheControl = 'public, max-age=60, stale-while-revalidate=300';

        if ($request->header('If-None-Match') === $etag) {
            return response('', 304)
                ->header('ETag', $etag)
                ->header('Cache-Control', $cacheControl);
        }

        return response()->json([
            'data' => [
                'key' => RelatedProductsContentDefinition::KEY,
                'type' => RelatedProductsContentDefinition::TYPE,
                'schema_version' => RelatedProductsContentDefinition::SCHEMA_VERSION,
                'revision' => $revision,
                'published_at' => $entry->published_at?->toIso8601String(),
                'payload' => $payload,
            ],
            'meta' => ['api_version' => 'v1'],
        ])->header('ETag', $etag)
            ->header('Cache-Control', $cacheControl);
    }
}
