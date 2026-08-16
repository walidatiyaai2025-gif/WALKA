<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\ContentRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use App\Models\ProductVariant;
use App\Services\CommerceMapService;
use App\Services\Content\CommerceMapContentDefinition;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

final class AdminCommerceMapController extends Controller
{
    /** @var list<string> */
    private const MARKETS = ['US', 'CA', 'MX'];

    public function __construct(private readonly CommerceMapService $commerce) {}

    public function edit(Request $request): View
    {
        $variants = $this->variants();
        $entry = ContentEntry::query()
            ->where('content_key', CommerceMapContentDefinition::KEY)
            ->first();

        if ($entry === null) {
            $entry = $this->commerce->saveDraft(
                $this->payloadFromCatalog($request, $variants, bootstrap: true),
                0,
                $this->actorFingerprint($request),
            );
        }

        abort_unless(
            $entry->content_type === CommerceMapContentDefinition::TYPE,
            409,
            'The reserved commerce.map content key has an incompatible content type.',
        );

        $entry->load(['revisions' => fn ($query) => $query->orderByDesc('revision')]);
        $draftMappings = collect($entry->draft_payload['mappings'] ?? [])->keyBy(
            static fn (array $mapping): string => $mapping['variant_id'].'|'.$mapping['region_market'],
        );

        return view('admin.content.commerce-map', [
            'entry' => $entry,
            'variants' => $variants,
            'markets' => self::MARKETS,
            'draftMappings' => $draftMappings,
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'active' => ['nullable', 'array'],
        ]);

        try {
            $this->commerce->saveDraft(
                $this->payloadFromCatalog($request, $this->variants()),
                (int) $validated['revision'],
                $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.commerce.edit')
                ->withErrors([
                    'revision' => 'Commerce destinations changed in another session. Current values were reloaded; review before saving again.',
                ]);
        }

        return redirect()
            ->route('admin.content.commerce.edit')
            ->with('status', 'Private commerce destination draft saved. Stable Variant IDs and ASINs were re-derived from Product Master.');
    }

    public function publish(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
        ]);

        try {
            $this->commerce->publish(
                (int) $validated['revision'],
                $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.commerce.edit')
                ->withErrors([
                    'revision' => 'Publish blocked because the commerce draft changed in another session. Review the latest draft first.',
                ]);
        }

        return redirect()
            ->route('admin.content.commerce.edit')
            ->with('status', 'Governed Amazon destinations published after Product Master revalidation.');
    }

    public function restore(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'source_revision' => ['required', 'integer', 'min:1'],
            'reason' => ['required', 'string', 'min:3', 'max:280'],
        ]);

        try {
            $this->commerce->restore(
                (int) $validated['source_revision'],
                (int) $validated['revision'],
                $this->actorFingerprint($request),
                (string) $validated['reason'],
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.commerce.edit')
                ->withErrors([
                    'revision' => 'Restore blocked because the commerce draft changed in another session. Reload and review the latest revision.',
                ]);
        }

        return redirect()
            ->route('admin.content.commerce.edit')
            ->with('status', 'Historical commerce snapshot restored into a new private draft after canonical ASIN/revision validation. Review before publishing.');
    }

    /** @return Collection<int, ProductVariant> */
    private function variants(): Collection
    {
        return ProductVariant::query()
            ->with('product')
            ->orderBy('product_id')
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();
    }

    /**
     * @param  Collection<int, ProductVariant>  $variants
     * @return array{mappings: list<array<string, mixed>>}
     */
    private function payloadFromCatalog(Request $request, Collection $variants, bool $bootstrap = false): array
    {
        $mappings = [];

        foreach ($variants as $variant) {
            foreach (self::MARKETS as $market) {
                $active = $market === 'US'
                    ? true
                    : ($bootstrap ? false : $request->boolean('active.'.$variant->id.'.'.$market));

                $mappings[] = [
                    'variant_id' => $variant->id,
                    'variant_revision' => (int) $variant->revision,
                    'region_market' => $market,
                    'asin' => strtoupper((string) $variant->asin),
                    'destination_url' => CommerceMapContentDefinition::canonicalDestination($market, (string) $variant->asin),
                    'cta_key' => 'buy_on_amazon',
                    'disclosure_key' => 'amazon_purchase_disclosure',
                    'entitlements' => ['amazon_purchase'],
                    'active' => $active,
                    'trace' => [
                        'source' => 'admin_commerce_map',
                        'reference' => 'dashboard',
                    ],
                ];
            }
        }

        return ['mappings' => $mappings];
    }

    private function actorFingerprint(Request $request): string
    {
        $fingerprint = (string) $request->session()->get('walka_admin_dashboard_actor', '');

        return $fingerprint !== ''
            ? $fingerprint
            : hash('sha256', 'dashboard|'.$request->session()->getId());
    }
}
