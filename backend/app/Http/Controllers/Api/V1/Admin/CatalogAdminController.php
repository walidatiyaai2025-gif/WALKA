<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Admin\UpdateCatalogProductRequest;
use App\Http\Requests\Api\V1\Admin\UpdateCatalogVariantRequest;
use App\Models\CatalogCategory;
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
            ->with(['categoryEntity', 'variants'])
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        return response()->json([
            'data' => $products->map(fn (Product $product): array => $this->product($product))->values(),
            'categories' => CatalogCategory::query()
                ->orderBy('sort_order')
                ->orderBy('id')
                ->get()
                ->map(fn (CatalogCategory $category): array => [
                    'id' => $category->id,
                    'name' => $category->name,
                    'sort_order' => $category->sort_order,
                    'is_visible' => $category->is_visible,
                    'revision' => $category->revision,
                ])
                ->values(),
            'meta' => $this->meta(),
        ]);
    }

    public function updateProduct(UpdateCatalogProductRequest $request, string $product): JsonResponse
    {
        $validated = $request->validated();
        $revision = (int) $validated['revision'];
        unset($validated['revision']);

        if (array_key_exists('short_description', $validated)) {
            $validated['short_description'] = $this->nullableTrimmed($validated['short_description']);
        }

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
            'short_description' => $product->short_description,
            'category_id' => $product->category_id ?? $product->category,
            'category_name' => $product->categoryEntity?->name,
            'features' => $product->features ?? [],
            'facts' => $product->facts ?? [],
            'sort_order' => $product->sort_order,
            'is_visible' => $product->is_visible,
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
            'swatch_hex' => $variant->swatch_hex,
            'pantone' => $variant->pantone,
            'asin' => $variant->asin,
            'sort_order' => $variant->sort_order,
            'is_visible' => $variant->is_visible,
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
                'category_fields' => ['name', 'sort_order', 'is_visible'],
                'product_fields' => ['name', 'short_description', 'category_id', 'features', 'facts', 'sort_order', 'is_visible'],
                'variant_fields' => ['color', 'swatch_hex', 'pantone', 'asin', 'sort_order', 'is_visible'],
                'immutable_after_create' => ['id', 'product_id'],
                'source_of_truth' => 'database',
                'featured_source' => 'home.featured',
            ],
        ];
    }

    private function nullableTrimmed(mixed $value): ?string
    {
        $trimmed = trim((string) ($value ?? ''));

        return $trimmed === '' ? null : $trimmed;
    }
}
