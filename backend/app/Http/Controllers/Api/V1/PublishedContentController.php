<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Validator;

final class PublishedContentController extends Controller
{
    private const HOME_HERO_KEY = 'home.hero';

    private const HOME_HERO_TYPE = 'home.hero';

    private const SCHEMA_VERSION = 1;

    public function home(Request $request): JsonResponse|Response
    {
        $entry = ContentEntry::query()
            ->where('content_key', self::HOME_HERO_KEY)
            ->where('content_type', self::HOME_HERO_TYPE)
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

        if (! $this->validHomeHeroPayload($entry->published_payload)) {
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
                'key' => self::HOME_HERO_KEY,
                'type' => self::HOME_HERO_TYPE,
                'schema_version' => self::SCHEMA_VERSION,
                'revision' => $revision,
                'published_at' => $entry->published_at?->toIso8601String(),
                'payload' => $entry->published_payload,
            ],
            'meta' => [
                'api_version' => 'v1',
            ],
        ])->header('ETag', $etag)
            ->header('Cache-Control', $cacheControl);
    }

    private function validHomeHeroPayload(array $payload): bool
    {
        return ! Validator::make($payload, [
            'eyebrow' => ['required', 'string', 'max:120'],
            'title' => ['required', 'string', 'max:160'],
            'body' => ['required', 'string', 'max:500'],
            'shop_label' => ['required', 'string', 'max:64'],
            'search_label' => ['required', 'string', 'max:64'],
        ])->fails();
    }
}
