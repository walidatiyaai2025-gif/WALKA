<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Admin\UpdateCatalogProductRequest;
use App\Http\Requests\Api\V1\Admin\UpdateCatalogVariantRequest;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Services\CatalogAuthoringService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

final class CatalogAdminController extends Controller
{
    public function __construct(private readonly CatalogAuthoringService $authoring) {}

    public function index(): JsonResponse
    {
        $products = Product::query()
            ->with('variants')
            ->orderBy('sort_order')
            ->get();

        if ($products->isEmpty()) {
            return response()->json([
                'error' => [
                    'code' => 'catalog_unavailable',
                    'message' => 'WALKA catalog is not seeded.',
                ],
            ], 503);
        }

        return response()->json([
            'data' => $products->map(fn (Product $product): array => $this->product($product))->values(),
            'meta' => $this->meta(),
        ]);
    }

    public function updateProduct(UpdateCatalogProductRequest $request, string $product): JsonResponse
    {
        $validated = $request->validated();
        $revision = (int) $validated['revision'];
        unset($validated['revision']);

        $updated = $this->authoring->updateProduct(
            productId: $product,
            attributes: $validated,
            expectedRevision: $revision,
            actorFingerprint: $this->actorFingerprint($request),
        );

        return response()->json([
            'data' => $this->product($updated),
            'meta' => $this->meta(),
        ]);
    }

    public function updateVariant(UpdateCatalogVariantRequest $request, string $variant): JsonResponse
    {
        $validated = $request->validated();
        $revision = (int) $validated['revision'];
        unset($validated['revision']);

        $updated = $this->authoring->updateVariant(
            variantId: $variant,
            attributes: $validated,
            expectedRevision: $revision,
            actorFingerprint: $this->actorFingerprint($request),
        );

        return response()->json([
            'data' => $this->variant($updated),
            'meta' => $this->meta(),
        ]);
    }

    private function actorFingerprint(Request $request): string
    {
        return (string) $request->attributes->get('walka_admin_fingerprint', '');
    }

    private function product(Product $product): array
    {
        return [
            'id' => $product->id,
            'name' => $product->name,
            'category' => $product->category,
            'features' => $product->features ?? [],
            'facts' => $product->facts ?? [],
            'revision' => $product->revision,
            'updated_at' => $product->updated_at?->toISOString(),
            'variants' => $product->variants->map(fn (ProductVariant $variant): array => $this->variant($variant))->values(),
        ];
    }

    private function variant(ProductVariant $variant): array
    {
        return [
            'id' => $variant->id,
            'product_id' => $variant->product_id,
            'color' => $variant->color,
            'pantone' => $variant->pantone,
            'asin' => $variant->asin,
            'revision' => $variant->revision,
            'updated_at' => $variant->updated_at?->toISOString(),
        ];
    }

    private function meta(): array
    {
        return [
            'release' => config('walka.release'),
            'api_version' => config('walka.api_version'),
            'authoring' => [
                'product_fields' => ['name', 'features'],
                'variant_fields' => ['color'],
                'locked_fields' => [
                    'id',
                    'product_id',
                    'category',
                    'facts',
                    'asin',
                    'pantone',
                    'sort_order',
                ],
            ],
        ];
    }
}
