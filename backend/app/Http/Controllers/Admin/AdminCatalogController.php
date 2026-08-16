<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\CatalogRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\CatalogCategory;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Services\CatalogAuthoringService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;
use JsonException;

final class AdminCatalogController extends Controller
{
    public function __construct(private readonly CatalogAuthoringService $authoring) {}

    public function index(): View
    {
        return view('admin.catalog', [
            'categories' => CatalogCategory::query()->orderBy('sort_order')->orderBy('id')->get(),
            'products' => Product::query()
                ->with(['categoryEntity', 'variants'])
                ->orderBy('sort_order')
                ->orderBy('id')
                ->get(),
        ]);
    }

    public function createCategory(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'id' => ['required', 'string', 'max:80', 'regex:/^[a-z0-9]+(?:-[a-z0-9]+)*$/', Rule::unique('catalog_categories', 'id')],
            'name' => ['required', 'filled', 'string', 'max:120'],
            'sort_order' => ['required', 'integer', 'min:0', 'max:65535'],
        ]);

        $this->authoring->createCategory([
            'id' => (string) $validated['id'],
            'name' => (string) $validated['name'],
            'sort_order' => (int) $validated['sort_order'],
            'is_visible' => $request->boolean('is_visible'),
        ], $this->actorFingerprint($request));

        return $this->done('Category created.');
    }

    public function updateCategory(Request $request, string $category): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'name' => ['required', 'filled', 'string', 'max:120'],
            'sort_order' => ['required', 'integer', 'min:0', 'max:65535'],
        ]);

        try {
            $this->authoring->updateCategory(
                categoryId: $category,
                attributes: [
                    'name' => (string) $validated['name'],
                    'sort_order' => (int) $validated['sort_order'],
                    'is_visible' => $request->boolean('is_visible'),
                ],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (CatalogRevisionConflictException) {
            return $this->revisionConflict('category');
        }

        return $this->done('Category saved.');
    }

    public function deleteCategory(Request $request, string $category): RedirectResponse
    {
        $validated = $request->validate(['revision' => ['required', 'integer', 'min:1']]);

        try {
            $this->authoring->deleteCategory(
                $category,
                (int) $validated['revision'],
                $this->actorFingerprint($request),
            );
        } catch (CatalogRevisionConflictException) {
            return $this->revisionConflict('category');
        }

        return $this->done('Category deleted.');
    }

    public function createProduct(Request $request): RedirectResponse
    {
        $validated = $request->validate($this->productRules(create: true));

        $this->authoring->createProduct([
            'id' => (string) $validated['id'],
            ...$this->productAttributes($request, $validated),
        ], $this->actorFingerprint($request));

        return $this->done('Product created. Add one or more colors/variants below it.');
    }

    public function updateProduct(Request $request, string $product): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            ...$this->productRules(create: false),
        ]);

        try {
            $this->authoring->updateProduct(
                productId: $product,
                attributes: $this->productAttributes($request, $validated),
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (CatalogRevisionConflictException) {
            return $this->revisionConflict('product');
        }

        return $this->done('Product saved and published to the catalog API.');
    }

    public function deleteProduct(Request $request, string $product): RedirectResponse
    {
        $validated = $request->validate(['revision' => ['required', 'integer', 'min:1']]);

        try {
            $this->authoring->deleteProduct(
                $product,
                (int) $validated['revision'],
                $this->actorFingerprint($request),
            );
        } catch (CatalogRevisionConflictException) {
            return $this->revisionConflict('product');
        }

        return $this->done('Product and its variants deleted.');
    }

    public function createVariant(Request $request, string $product): RedirectResponse
    {
        Product::query()->findOrFail($product);
        $validated = $request->validate([
            'variant_key' => ['required', 'string', 'max:60', 'regex:/^[a-z0-9]+(?:-[a-z0-9]+)*$/'],
            'color' => ['required', 'filled', 'string', 'max:80'],
            'swatch_hex' => ['nullable', 'regex:/^#[0-9A-Fa-f]{6}$/'],
            'pantone' => ['nullable', 'string', 'max:80'],
            'asin' => ['required', 'string', 'size:10', 'regex:/^[A-Za-z0-9]{10}$/'],
            'sort_order' => ['required', 'integer', 'min:0', 'max:65535'],
        ]);

        $variantId = $product.':'.(string) $validated['variant_key'];
        if (ProductVariant::query()->whereKey($variantId)->exists()) {
            throw ValidationException::withMessages([
                'variant_key' => 'That color/variant key already exists for this product.',
            ]);
        }

        $asin = strtoupper((string) $validated['asin']);
        if (ProductVariant::query()->where('asin', $asin)->exists()) {
            throw ValidationException::withMessages(['asin' => 'That ASIN is already assigned to another variant.']);
        }

        $this->authoring->createVariant([
            'id' => $variantId,
            'product_id' => $product,
            'color' => (string) $validated['color'],
            'swatch_hex' => $this->normalizedHex($validated['swatch_hex'] ?? null),
            'pantone' => $this->nullableTrimmed($validated['pantone'] ?? null),
            'asin' => $asin,
            'sort_order' => (int) $validated['sort_order'],
            'is_visible' => $request->boolean('is_visible'),
        ], $this->actorFingerprint($request));

        return $this->done('Color/variant created.');
    }

    public function updateVariant(Request $request, string $variant): RedirectResponse
    {
        $current = ProductVariant::query()->findOrFail($variant);
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'color' => ['required', 'filled', 'string', 'max:80'],
            'swatch_hex' => ['nullable', 'regex:/^#[0-9A-Fa-f]{6}$/'],
            'pantone' => ['nullable', 'string', 'max:80'],
            'asin' => ['required', 'string', 'size:10', 'regex:/^[A-Za-z0-9]{10}$/'],
            'sort_order' => ['required', 'integer', 'min:0', 'max:65535'],
        ]);

        $asin = strtoupper((string) $validated['asin']);
        if (ProductVariant::query()->where('asin', $asin)->whereKeyNot($current->id)->exists()) {
            throw ValidationException::withMessages(['asin' => 'That ASIN is already assigned to another variant.']);
        }

        try {
            $this->authoring->updateVariant(
                variantId: $variant,
                attributes: [
                    'color' => (string) $validated['color'],
                    'swatch_hex' => $this->normalizedHex($validated['swatch_hex'] ?? null),
                    'pantone' => $this->nullableTrimmed($validated['pantone'] ?? null),
                    'asin' => $asin,
                    'sort_order' => (int) $validated['sort_order'],
                    'is_visible' => $request->boolean('is_visible'),
                ],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (CatalogRevisionConflictException) {
            return $this->revisionConflict('variant');
        }

        return $this->done('Color/variant saved and published to the catalog API.');
    }

    public function deleteVariant(Request $request, string $variant): RedirectResponse
    {
        $validated = $request->validate(['revision' => ['required', 'integer', 'min:1']]);

        try {
            $this->authoring->deleteVariant(
                $variant,
                (int) $validated['revision'],
                $this->actorFingerprint($request),
            );
        } catch (CatalogRevisionConflictException) {
            return $this->revisionConflict('variant');
        }

        return $this->done('Color/variant deleted.');
    }

    private function productRules(bool $create): array
    {
        return [
            ...($create ? [
                'id' => ['required', 'string', 'max:100', 'regex:/^[a-z0-9]+(?:-[a-z0-9]+)*$/', Rule::unique('products', 'id')],
            ] : []),
            'name' => ['required', 'filled', 'string', 'max:160'],
            'category_id' => ['required', 'string', Rule::exists('catalog_categories', 'id')],
            'features_text' => ['nullable', 'string', 'max:5000'],
            'facts_json' => ['nullable', 'string', 'max:20000'],
            'sort_order' => ['required', 'integer', 'min:0', 'max:65535'],
        ];
    }

    private function productAttributes(Request $request, array $validated): array
    {
        $features = $this->featuresFromTextarea((string) ($validated['features_text'] ?? ''));
        if ($features->count() > 20 || $features->contains(fn (string $feature): bool => mb_strlen($feature) > 180)) {
            throw ValidationException::withMessages([
                'features_text' => 'Use at most 20 feature lines, maximum 180 characters each.',
            ]);
        }

        return [
            'name' => (string) $validated['name'],
            'category_id' => (string) $validated['category_id'],
            'features' => $features->all(),
            'facts' => $this->factsFromJson((string) ($validated['facts_json'] ?? '{}')),
            'sort_order' => (int) $validated['sort_order'],
            'is_visible' => $request->boolean('is_visible'),
        ];
    }

    private function factsFromJson(string $value): array
    {
        $value = trim($value);
        if ($value === '') return [];

        try {
            $decoded = json_decode($value, true, 64, JSON_THROW_ON_ERROR);
        } catch (JsonException) {
            throw ValidationException::withMessages(['facts_json' => 'Product facts must be valid JSON.']);
        }

        if (! is_array($decoded) || ($decoded !== [] && array_is_list($decoded))) {
            throw ValidationException::withMessages(['facts_json' => 'Product facts must be a JSON object.']);
        }

        return $decoded;
    }

    /** @return Collection<int, string> */
    private function featuresFromTextarea(string $value): Collection
    {
        return collect(preg_split('/\r\n|\r|\n/', $value) ?: [])
            ->map(fn (string $feature): string => trim($feature))
            ->filter(fn (string $feature): bool => $feature !== '')
            ->values();
    }

    private function nullableTrimmed(mixed $value): ?string
    {
        $trimmed = trim((string) ($value ?? ''));
        return $trimmed === '' ? null : $trimmed;
    }

    private function normalizedHex(mixed $value): ?string
    {
        $hex = $this->nullableTrimmed($value);
        return $hex === null ? null : strtoupper($hex);
    }

    private function actorFingerprint(Request $request): string
    {
        $fingerprint = (string) $request->session()->get('walka_admin_dashboard_actor', '');
        return $fingerprint !== '' ? $fingerprint : hash('sha256', 'dashboard|'.$request->session()->getId());
    }

    private function done(string $status): RedirectResponse
    {
        return redirect()->route('admin.catalog')->with('status', $status);
    }

    private function revisionConflict(string $target): RedirectResponse
    {
        return redirect()->route('admin.catalog')->withErrors([
            'revision' => "This {$target} changed in another session. Reloaded current values; review and save again.",
        ]);
    }
}
