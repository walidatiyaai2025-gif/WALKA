<?php

namespace App\Http\Controllers\Admin;

use App\Enums\DashboardRole;
use App\Exceptions\CatalogRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\CatalogAudit;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Services\CatalogAuthoringService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\View\View;

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
        $configuredRole = DashboardRole::from(trim((string) config('walka_dashboard.role', 'owner')));

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
        $request->session()->put('walka_admin_dashboard_role', $configuredRole->value);
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
        $products = Product::query()->orderBy('sort_order')->get();
        $variants = ProductVariant::query()->orderBy('sort_order')->get();
        $recentAudits = CatalogAudit::query()->latest('created_at')->limit(6)->get();

        return view('admin.dashboard', [
            'productCount' => $products->count(),
            'variantCount' => $variants->count(),
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
        $products = Product::query()
            ->with('variants')
            ->orderBy('sort_order')
            ->get();

        return view('admin.catalog', [
            'products' => $products,
            'lockedFields' => [
                'id',
                'category',
                'facts',
                'product_id',
                'asin',
                'pantone',
                'sort_order',
            ],
        ]);
    }

    public function updateProduct(Request $request, string $product): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'name' => ['required', 'filled', 'string', 'max:160'],
            'features_text' => ['nullable', 'string', 'max:5000'],
        ]);

        $features = $this->featuresFromTextarea((string) ($validated['features_text'] ?? ''));
        if ($features->count() > 20 || $features->contains(fn (string $feature): bool => mb_strlen($feature) > 180)) {
            return back()
                ->withInput()
                ->withErrors(['features_text' => 'Use at most 20 feature lines, maximum 180 characters each.']);
        }

        try {
            $this->authoring->updateProduct(
                productId: $product,
                attributes: [
                    'name' => (string) $validated['name'],
                    'features' => $features->all(),
                ],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (CatalogRevisionConflictException) {
            return redirect()
                ->route('admin.catalog')
                ->withErrors(['revision' => 'This product changed in another session. Reloaded current values; review and save again.']);
        }

        return redirect()
            ->route('admin.catalog')
            ->with('status', 'Product content saved and published to the catalog API.');
    }

    public function updateVariant(Request $request, string $variant): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'color' => ['required', 'filled', 'string', 'max:80'],
        ]);

        try {
            $this->authoring->updateVariant(
                variantId: $variant,
                attributes: ['color' => (string) $validated['color']],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (CatalogRevisionConflictException) {
            return redirect()
                ->route('admin.catalog')
                ->withErrors(['revision' => 'This variant changed in another session. Reloaded current values; review and save again.']);
        }

        return redirect()
            ->route('admin.catalog')
            ->with('status', 'Variant display color saved and published to the catalog API.');
    }

    public function audits(): View
    {
        return view('admin.audits', [
            'audits' => CatalogAudit::query()->latest('created_at')->limit(100)->get(),
        ]);
    }

    private function dashboardIsConfigured(): bool
    {
        $username = trim((string) config('walka.dashboard_username', ''));
        $password = (string) config('walka.dashboard_password', '');
        $role = DashboardRole::tryFrom(trim((string) config('walka_dashboard.role', '')));

        return $username !== '' && strlen($password) >= 12 && $role !== null;
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
}
