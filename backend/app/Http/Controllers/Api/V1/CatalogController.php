<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\CatalogRepository;
use App\Data\ProductData;
use App\Exceptions\CatalogUnavailableException;
use App\Http\Controllers\Controller;
use App\Models\ProductVariant;
use Illuminate\Http\JsonResponse;

final class CatalogController extends Controller
{
    public function __construct(private readonly CatalogRepository $catalog) {}

    public function __invoke(): JsonResponse
    {
        try {
            $variantPresentation = ProductVariant::query()
                ->get(['id', 'is_visible', 'presentation_order'])
                ->keyBy('id');

            $products = array_map(
                static function (ProductData $product) use ($variantPresentation): array {
                    $data = $product->toArray();
                    $variants = array_values(array_filter(
                        $data['variants'],
                        static function (array $variant) use ($variantPresentation): bool {
                            $presentation = $variantPresentation->get($variant['id']);

                            return $presentation !== null
                                && (bool) $presentation->getAttribute('is_visible');
                        },
                    ));

                    usort($variants, static function (array $left, array $right) use ($variantPresentation): int {
                        $leftPresentation = $variantPresentation->get($left['id']);
                        $rightPresentation = $variantPresentation->get($right['id']);
                        $leftOrder = (int) $leftPresentation?->getAttribute('presentation_order');
                        $rightOrder = (int) $rightPresentation?->getAttribute('presentation_order');

                        return $leftOrder <=> $rightOrder ?: $left['id'] <=> $right['id'];
                    });

                    $data['variants'] = array_map(
                        static function (array $variant) use ($variantPresentation): array {
                            $presentation = $variantPresentation->get($variant['id']);
                            $variant['presentation_order'] = (int) $presentation?->getAttribute('presentation_order');

                            return $variant;
                        },
                        $variants,
                    );

                    return $data;
                },
                $this->catalog->all(),
            );
        } catch (CatalogUnavailableException) {
            return response()->json([
                'error' => [
                    'code' => 'catalog_unavailable',
                    'message' => 'WALKA catalog is not seeded.',
                ],
            ], 503);
        }

        return response()->json([
            'data' => $products,
            'meta' => [
                'release' => config('walka.release'),
                'api_version' => config('walka.api_version'),
                'purchase_mode' => config('walka.purchase_mode'),
            ],
        ]);
    }
}
