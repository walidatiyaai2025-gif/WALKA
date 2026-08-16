<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\CommerceMapService;
use App\Services\Content\CommerceMapContentDefinition;
use App\Services\ContentDeliveryMetadataService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Validation\ValidationException;

final class AmazonOutboundController extends Controller
{
    public function __construct(
        private readonly CommerceMapService $commerce,
        private readonly ContentDeliveryMetadataService $deliveryMetadata,
    ) {}

    public function index(Request $request): JsonResponse|Response
    {
        try {
            $snapshot = $this->commerce->publishedSnapshot();
        } catch (ValidationException) {
            return $this->invalidPublishedMap();
        }

        if ($snapshot === null) {
            return response()->json(['error' => [
                'code' => 'commerce_map_not_published',
                'message' => 'No governed CommerceMap has been published.',
            ]], 404);
        }

        $revision = (int) $snapshot['verification']['published_revision'];
        $delivery = $this->deliveryMetadata->forPublishedRevision(
            CommerceMapContentDefinition::KEY,
            $revision,
        );

        if ($request->header('If-None-Match') === $delivery['etag']) {
            return response('', 304)
                ->header('ETag', $delivery['etag'])
                ->header('Cache-Control', $delivery['cache_control']);
        }

        return response()->json(['data' => [
            'schema_version' => CommerceMapContentDefinition::SCHEMA_VERSION,
            'mappings' => $snapshot['payload']['mappings'],
            'verification' => $snapshot['verification'],
        ]])->header('ETag', $delivery['etag'])
            ->header('Cache-Control', $delivery['cache_control']);
    }

    public function resolve(Request $request, string $variant): JsonResponse
    {
        $rawMarket = $request->query('market');
        $market = is_string($rawMarket) && trim($rawMarket) !== '' ? $rawMarket : 'US';
        $marketSource = is_string($rawMarket) && trim($rawMarket) !== '' ? 'query' : 'default_us';

        try {
            $market = CommerceMapContentDefinition::normalizeMarket($market);
        } catch (ValidationException $exception) {
            return response()->json(['error' => [
                'code' => 'amazon_destination_rejected',
                'message' => 'Amazon destination resolution failed closed.',
                'details' => $exception->errors(),
            ]], 422);
        }

        try {
            $resolution = $this->commerce->resolve($variant, $market);
        } catch (ValidationException) {
            return $this->invalidPublishedMap();
        }

        if ($resolution === null) {
            return response()->json(['error' => [
                'code' => 'amazon_destination_unmapped',
                'message' => 'No active governed Amazon destination exists for this variant and market.',
            ]], 404);
        }

        $resolutionId = hash('sha256', implode('|', [
            $resolution['variant_id'],
            $resolution['region_market'],
            $resolution['asin'],
            $resolution['verification_digest'],
        ]));

        return response()->json([
            'data' => $resolution,
            'meta' => [
                'market_source' => $marketSource,
                'resolution_id' => $resolutionId,
                'retry_safe' => true,
            ],
        ]);
    }

    private function invalidPublishedMap(): JsonResponse
    {
        return response()->json(['error' => [
            'code' => 'commerce_map_invalid',
            'message' => 'Published CommerceMap failed validation and no destination was returned.',
        ]], 503);
    }
}
