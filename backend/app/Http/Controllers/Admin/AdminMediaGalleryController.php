<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\MediaGalleryRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\MediaGallery;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Services\MediaGalleryService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

final class AdminMediaGalleryController extends Controller
{
    public function __construct(private readonly MediaGalleryService $galleries) {}

    public function index(): View
    {
        return view('admin.media.galleries', [
            'products' => Product::query()
                ->with(['variants' => fn ($query) => $query->orderBy('sort_order')])
                ->orderBy('sort_order')
                ->get(),
            'galleries' => MediaGallery::query()
                ->with('items.asset.canonicalDerivative')
                ->get()
                ->keyBy(fn (MediaGallery $gallery): string => $gallery->isProductGallery()
                    ? 'product:'.$gallery->product_id
                    : 'variant:'.$gallery->product_variant_id),
            'eligibleAssets' => $this->galleries->eligibleAssets(),
            'maxItems' => MediaGalleryService::MAX_ITEMS,
        ]);
    }

    public function updateProduct(Request $request, Product $product): RedirectResponse
    {
        return $this->replace(
            request: $request,
            targetType: 'product',
            targetId: $product->id,
            replace: fn (array $mediaIds, int $revision, string $actor) => $this->galleries
                ->replaceProductGallery($product, $mediaIds, $revision, $actor),
        );
    }

    public function updateVariant(Request $request, ProductVariant $variant): RedirectResponse
    {
        return $this->replace(
            request: $request,
            targetType: 'variant',
            targetId: $variant->id,
            replace: fn (array $mediaIds, int $revision, string $actor) => $this->galleries
                ->replaceVariantGallery($variant, $mediaIds, $revision, $actor),
        );
    }

    /**
     * @param  callable(array<int, string|null>, int, string): MediaGallery  $replace
     */
    private function replace(
        Request $request,
        string $targetType,
        string $targetId,
        callable $replace,
    ): RedirectResponse {
        $validated = $request->validate([
            'expected_revision' => ['required', 'integer', 'min:0'],
            'media_ids' => ['nullable', 'array', 'max:'.MediaGalleryService::MAX_ITEMS],
            'media_ids.*' => ['nullable', 'string', 'max:64'],
        ]);

        try {
            $gallery = $replace(
                $validated['media_ids'] ?? [],
                (int) $validated['expected_revision'],
                $this->actorFingerprint($request),
            );
        } catch (MediaGalleryRevisionConflictException) {
            return redirect()
                ->route('admin.media.galleries.index')
                ->withErrors([
                    'revision' => sprintf(
                        'The %s gallery for %s changed in another session. Reload and review the latest order before saving.',
                        $targetType,
                        $targetId,
                    ),
                ]);
        } catch (ValidationException $error) {
            throw $error;
        }

        return redirect()
            ->route('admin.media.galleries.index')
            ->with(
                'status',
                sprintf(
                    '%s gallery %s saved at revision %d. Only admitted product media can be delivered publicly.',
                    ucfirst($targetType),
                    $targetId,
                    $gallery->revision,
                ),
            );
    }

    private function actorFingerprint(Request $request): string
    {
        $fingerprint = (string) $request->session()->get('walka_admin_dashboard_actor', '');

        return $fingerprint !== ''
            ? $fingerprint
            : hash('sha256', 'dashboard|'.$request->session()->getId());
    }
}
