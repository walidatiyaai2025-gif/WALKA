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
            'short_description' => ['sometimes', 'nullable', 'string', 'max:500'],
            'highlights_text' => ['sometimes', 'nullable', 'string', 'max:3000'],
            'presentation_order' => ['sometimes', 'integer', 'min:0', 'max:65535'],
            'presentation_controls' => ['sometimes', 'boolean'],
        ]);

        $features = $this->lines((string) ($validated['features_text'] ?? ''));
        if (count($features) > 20 || collect($features)->contains(fn (string $line): bool => mb_strlen($line) > 180)) {
            return back()->withInput()->withErrors(['features_text' => 'Use at most 20 feature lines, maximum 180 characters each.']);
        }

        $attributes = [
            'name' => trim((string) $validated['name']),
            'features' => $features,
        ];

        if (array_key_exists('short_description', $validated)) {
            $description = trim((string) ($validated['short_description'] ?? ''));
            $attributes['short_description'] = $description === '' ? null : $description;
        }
        if (array_key_exists('highlights_text', $validated)) {
            $highlights = $this->lines((string) ($validated['highlights_text'] ?? ''));
            if (count($highlights) > 8 || collect($highlights)->contains(fn (string $line): bool => mb_strlen($line) > 180)) {
                return back()->withInput()->withErrors(['highlights_text' => 'Use at most 8 highlight lines, maximum 180 characters each.']);
            }
            $attributes['highlights'] = $highlights;
        }
        if (array_key_exists('presentation_order', $validated)) {
            $attributes['presentation_order'] = (int) $validated['presentation_order'];
        }
        if ($request->boolean('presentation_controls')) {
            $attributes['is_visible'] = $request->boolean('is_visible');
            $attributes['is_featured'] = $request->boolean('is_featured');
        }

        $sessionActor = trim((string) $request->session()->get('walka_admin_dashboard_actor', ''));
        $author = $sessionActor !== '' ? $sessionActor : hash('sha256', 'dashboard|'.$request->session()->getId());

        try {
            $this->authoring->updateProduct(
                productId: $product,
                attributes: $attributes,
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
