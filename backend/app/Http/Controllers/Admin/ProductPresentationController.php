<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\CatalogRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Services\CatalogAuthoringService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

final class ProductPresentationController extends Controller
{
    public function __construct(private readonly CatalogAuthoringService $authoring) {}

    public function update(Request $request, string $product): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'name' => ['required', 'filled', 'string', 'max:160'],
            'features_text' => ['nullable', 'string', 'max:5000'],
            'short_description' => ['nullable', 'string', 'max:500'],
            'highlights_text' => ['nullable', 'string', 'max:3000'],
            'presentation_order' => ['required', 'integer', 'min:0', 'max:65535'],
        ]);

        $features = $this->lines((string) ($validated['features_text'] ?? ''));
        $highlights = $this->lines((string) ($validated['highlights_text'] ?? ''));
        if (count($features) > 20 || collect($features)->contains(fn (string $line): bool => mb_strlen($line) > 180)) {
            return back()->withInput()->withErrors(['features_text' => 'Use at most 20 feature lines, maximum 180 characters each.']);
        }
        if (count($highlights) > 8 || collect($highlights)->contains(fn (string $line): bool => mb_strlen($line) > 180)) {
            return back()->withInput()->withErrors(['highlights_text' => 'Use at most 8 highlight lines, maximum 180 characters each.']);
        }

        $description = trim((string) ($validated['short_description'] ?? ''));
        $sessionActor = trim((string) $request->session()->get('walka_admin_dashboard_actor', ''));
        $author = $sessionActor !== '' ? $sessionActor : hash('sha256', 'dashboard|'.$request->session()->getId());

        try {
            $this->authoring->updateProduct(
                productId: $product,
                attributes: [
                    'name' => trim((string) $validated['name']),
                    'features' => $features,
                    'short_description' => $description === '' ? null : $description,
                    'highlights' => $highlights,
                    'is_visible' => $request->boolean('is_visible'),
                    'is_featured' => $request->boolean('is_featured'),
                    'presentation_order' => (int) $validated['presentation_order'],
                ],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $author,
            );
        } catch (CatalogRevisionConflictException) {
            return redirect()->route('admin.catalog')->withErrors([
                'revision' => 'This product changed in another session. Reloaded current values; review and save again.',
            ]);
        }

        return redirect()->route('admin.catalog')->with('status', 'Product presentation saved and published to the catalog API.');
    }

    /** @return list<string> */
    private function lines(string $value): array
    {
        return collect(preg_split('/\r\n|\r|\n/', $value) ?: [])
            ->map(fn (string $line): string => trim($line))
            ->filter(fn (string $line): bool => $line !== '')
            ->values()
            ->all();
    }
}
