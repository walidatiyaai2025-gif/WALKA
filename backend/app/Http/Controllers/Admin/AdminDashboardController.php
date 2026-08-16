<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\CatalogRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\CatalogAudit;
use App\Models\CatalogCategory;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Services\CatalogAuthoringService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Validation\Rule;
use Illuminate\View\View;
use JsonException;

final class AdminDashboardController extends Controller
{
    public function __construct(private readonly CatalogAuthoringService $authoring) {}

    public function loginForm(Request $request): View|RedirectResponse
    {
        if ($request->session()->get('walka_admin_dashboard_authenticated') === true) {
            return redirect()->route('admin.dashboard');
        }

        return view('admin.login', [
            'configured' => $this->dashboardIsConfigured(),
        ]);
    }

    public function authenticate(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'username' => ['required', 'string', 'max:80'],
            'password' => ['required', 'string', 'max:500'],
        ]);

        if (! $this->dashboardIsConfigured()) {
            return back()
                ->withInput($request->only('username'))
                ->withErrors(['password' => 'Dashboard authentication is not configured on this server.']);
        }

        $configuredUsername = (string) config('walka.dashboard_username', 'admin');
        $configuredPassword = (string) config('walka.dashboard_password', '');

        $usernameMatches = hash_equals($configuredUsername, (string) $validated['username']);
        $passwordMatches = hash_equals($configuredPassword, (string) $validated['password']);

        if (! $usernameMatches || ! $passwordMatches) {
            return back()
                ->withInput($request->only('username'))
                ->withErrors(['password' => 'Invalid WALKA Admin credentials.']);
        }

        $request->session()->regenerate();
        $request->session()->put('walka_admin_dashboard_authenticated', true);
        $request->session()->put('walka_admin_dashboard_username', $configuredUsername);
        $request->session()->put(
            'walka_admin_dashboard_actor',
            hash('sha256', 'dashboard|'.$configuredUsername.'|'.$request->session()->getId()),
        );

        return redirect()->intended(route('admin.dashboard'));
    }

    public function logout(Request $request): RedirectResponse
    {
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('admin.login');
    }

    public function dashboard(): View
    {
        $products = Product::query()->get();
        $variants = ProductVariant::query()->get();
        $recentAudits = CatalogAudit::query()->latest('created_at')->limit(6)->get();

        return view('admin.dashboard', [
            'productCount' => $products->count(),
            'variantCount' => $variants->count(),
            'categoryCount' => CatalogCategory::query()->count(),
            'auditCount' => CatalogAudit::query()->count(),
            'recentAudits' => $recentAudits,
            'release' => (string) config('walka.release'),
            'apiVersion' => (string) config('walka.api_version'),
            'purchaseMode' => (string) config('walka.purchase_mode'),
            'adminApiConfigured' => strlen((string) config('walka.admin_token', '')) >= 32,
            'catalogReady' => $products->isNotEmpty(),
        ]);
    }

    public function catalog(): View
    {
        $categories = CatalogCategory::query()->orderBy('sort_order')->orderBy('id')->get();
        $products = Product::query()
            ->with(['categoryEntity', 'variants'])
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        return view('admin.catalog', [
            'categories' => $categories,
            'products' => $products,
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

        return $this->catalogRedirect('Category created.');
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

        return $this->catalogRedirect('Category saved.');
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

        return $this->catalogRedirect('Category deleted.');
    }

    public function createProduct(Request $request): RedirectResponse
    {
        $validated = $request->validate($this->productRules(create: true));

        $this->authoring->createProduct([
            'id' => (string) $validated['id'],
            ...$this->productAttributes($request, $validated),
        ], $this->actorFingerprint($request));

        return $this->catalogRedirect('Product created. Add one or more colors/variants below it.');
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

        return $this->catalogRedirect('Product saved and published to the catalog API.');
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

        return $this->catalogRedirect('Product and its variants deleted.');
    }

    public function createVariant(Request $request, string $product): RedirectResponse
    {
        Product::query()->findOrFail($product);
        $validated = $request->validate([
            'variant_key' => ['required', 'string', 'max:60', 'regex:/^[a-z0-9]+(?:-[a-z0-9]+)*$/'],
            'color' => ['required', 'filled', 'string', 'max:80'],
            'pantone' => ['nullable', 'string', 'max:80'],
            'asin' => ['required', 'string', 'size:10', 'regex:/^[A-Z0-9]{10}$/', Rule::unique('product_variants', 'asin')],
            'sort_order' => ['required', 'integer', 'min:0', 'max:65535'],
        ]);

        $variantId = $product.':'.$validated['variant_key'];
        $request->validate([
            'variant_key' => [Rule::unique('product_variants', 'id')->where(fn ($query) => $query->where('id', $variantId))],
        ]);

        $this->authoring->createVariant([
            'id' => $variantId,
            'product_id' => $product,
            'color' => (string) $validated['color'],
            'pantone' => $this->nullableTrimmed($validated['pantone'] ?? null),
            'asin' => strtoupper((string) $validated['asin']),
            'sort_order' => (int) $validated['sort_order'],
            'is_visible' => $request->boolean('is_visible'),
        ], $this->actorFingerprint($request));

        return $this->catalogRedirect('Color/variant created.');
    }

    public function updateVariant(Request $request, string $variant): RedirectResponse
    {
        $current = ProductVariant::query()->findOrFail($variant);
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'color' => ['required', 'filled', 'string', 'max:80'],
            'pantone' => ['nullable', 'string', 'max:80'],
            'asin' => ['required', 'string', 'size:10', 'regex:/^[A-Z0-9]{10}$/', Rule::unique('product_variants', 'asin')->ignore($current->id, 'id')],
            'sort_order' => ['required', 'integer', 'min:0', 'max:65535'],
        ]);

        try {
            $this->authoring->updateVariant(
                variantId: $variant,
                attributes: [
                    'color' => (string) $validated['color'],
                    'pantone' => $this->nullableTrimmed($validated['pantone'] ?? null),
                    'asin' => strtoupper((string) $validated['asin']),
                    'sort_order' => (int) $validated['sort_order'],
                    'is_visible' => $request->boolean('is_visible'),
                ],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (CatalogRevisionConflictException) {
            return $this->revisionConflict('variant');
        }

        return $this->catalogRedirect('Color/variant saved and published to the catalog API.');
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

        return $this->catalogRedirect('Color/variant deleted.');
    }

    public function audits(): View
    {
        return view('admin.audits', [
            'audits' => CatalogAudit::query()->latest('created_at')->limit(100)->get(),
        ]);
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
            abort(422, 'Use at most 20 feature lines, maximum 180 characters each.');
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
        if ($value === '') {
            return [];
        }

        try {
            $decoded = json_decode($value, true, 64, JSON_THROW_ON_ERROR);
        } catch (JsonException) {
            abort(422, 'Product facts must be valid JSON.');
        }

        if (! is_array($decoded) || ($decoded !== [] && array_is_list($decoded))) {
            abort(422, 'Product facts must be a JSON object.');
        }

        return $decoded;
    }

    private function dashboardIsConfigured(): bool
    {
        $username = trim((string) config('walka.dashboard_username', ''));
        $password = (string) config('walka.dashboard_password', '');

        return $username !== '' && strlen($password) >= 12;
    }

    private function actorFingerprint(Request $request): string
    {
        $fingerprint = (string) $request->session()->get('walka_admin_dashboard_actor', '');

        return $fingerprint !== ''
            ? $fingerprint
            : hash('sha256', 'dashboard|'.$request->session()->getId());
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

    private function catalogRedirect(string $status): RedirectResponse
    {
        return redirect()->route('admin.catalog')->with('status', $status);
    }

    private function revisionConflict(string $target): RedirectResponse
    {
        return redirect()
            ->route('admin.catalog')
            ->withErrors(['revision' => "This {$target} changed in another session. Reloaded current values; review and save again."]);
    }
}
