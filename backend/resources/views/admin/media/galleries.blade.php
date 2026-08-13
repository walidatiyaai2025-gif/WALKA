@extends('admin.layout')

@section('title', 'Product Galleries · WALKA Admin')
@section('topbar', 'Product media galleries')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">GOVERNED PRODUCT MEDIA</p>
        <h1>Product & variant galleries</h1>
        <p class="lead">Assign only admitted Product media to stable catalog targets. Product galleries are the deterministic fallback for variants that have no explicit gallery.</p>
    </div>
    <a class="btn secondary" href="{{ route('admin.media.index') }}">← Media library</a>
</div>

<div class="grid metrics">
    <div class="card metric">
        <div class="metric-label">Eligible assets</div>
        <div class="metric-value">{{ $eligibleAssets->count() }}</div>
        <div class="metric-note">Admitted · Product · canonical derivative</div>
    </div>
    <div class="card metric">
        <div class="metric-label">Gallery limit</div>
        <div class="metric-value">{{ $maxItems }}</div>
        <div class="metric-note">Unique ordered assets per target</div>
    </div>
    <div class="card metric">
        <div class="metric-label">Product targets</div>
        <div class="metric-value">{{ $products->count() }}</div>
        <div class="metric-note">Stable Product Master IDs</div>
    </div>
    <div class="card metric">
        <div class="metric-label">Variant targets</div>
        <div class="metric-value">{{ $products->sum(fn ($product) => $product->variants->count()) }}</div>
        <div class="metric-note">Stable ProductVariant IDs</div>
    </div>
</div>

<div class="locked section-space">
    <small>Fail-closed publication boundary</small>
    <strong>Draft/Archived media, non-Product purpose media, missing canonical derivatives, duplicate IDs and stale revisions are rejected before mutation. Public gallery metadata never exposes storage disks, paths, source filenames or provenance.</strong>
</div>

@if ($eligibleAssets->isEmpty())
    <section class="card section-space">
        <p class="eyebrow">NO ELIGIBLE MEDIA</p>
        <h2>Nothing can be assigned yet</h2>
        <p class="muted">Media upload alone creates Draft assets. A separate governed admission step must produce an admitted Product asset with a canonical derivative before it can appear here.</p>
    </section>
@endif

<div class="stack section-space">
@foreach ($products as $product)
    @php
        $productKey = 'product:'.$product->id;
        $productGallery = $galleries->get($productKey);
        $productAssignments = $productGallery?->items?->pluck('media_asset_id')->values()->all() ?? [];
    @endphp
    <section class="card">
        <p class="eyebrow">PRODUCT GALLERY</p>
        <h2>{{ $product->name }}</h2>
        <div class="locked-grid">
            <div class="locked"><small>Stable product ID</small><strong>{{ $product->id }}</strong></div>
            <div class="locked"><small>Revision</small><strong>{{ $productGallery?->revision ?? 0 }}</strong></div>
            <div class="locked"><small>Fallback behavior</small><strong>Used by variants with no explicit gallery.</strong></div>
        </div>

        <form method="post" action="{{ route('admin.media.galleries.products.update', ['product' => $product->id]) }}" class="stack section-space">
            @csrf
            @method('PATCH')
            <input type="hidden" name="expected_revision" value="{{ $productGallery?->revision ?? 0 }}">
            <div class="grid two">
                @for ($slot = 0; $slot < $maxItems; $slot++)
                    @php $selected = $productAssignments[$slot] ?? null; @endphp
                    <div class="field">
                        <label for="product-{{ $product->id }}-slot-{{ $slot }}">Position {{ $slot + 1 }}</label>
                        <select id="product-{{ $product->id }}-slot-{{ $slot }}" name="media_ids[]" style="width:100%;border:1px solid #ccd8e1;border-radius:11px;background:#fff;padding:11px 12px;color:#102235">
                            <option value="">— Empty —</option>
                            @if ($selected && ! $eligibleAssets->contains('id', $selected))
                                <option value="{{ $selected }}" selected>[INVALID — clear before saving] {{ $selected }}</option>
                            @endif
                            @foreach ($eligibleAssets as $asset)
                                <option value="{{ $asset->id }}" @selected($selected === $asset->id)>
                                    {{ $asset->semantic_label }} · {{ $asset->id }} · {{ $asset->canonicalDerivative->width }}×{{ $asset->canonicalDerivative->height }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                @endfor
            </div>
            <div class="actions">
                <button class="btn navy" type="submit">Save product gallery</button>
                <span class="muted">Saving replaces this gallery atomically and increments its revision.</span>
            </div>
        </form>

        <div class="stack section-space">
        @foreach ($product->variants as $variant)
            @php
                $variantKey = 'variant:'.$variant->id;
                $variantGallery = $galleries->get($variantKey);
                $variantAssignments = $variantGallery?->items?->pluck('media_asset_id')->values()->all() ?? [];
            @endphp
            <div class="locked" style="padding:18px">
                <div class="actions" style="justify-content:space-between">
                    <div>
                        <small>VARIANT GALLERY · {{ $variant->color }}</small>
                        <strong>{{ $variant->id }}</strong>
                    </div>
                    <span class="badge {{ count($variantAssignments) > 0 ? 'good' : 'lock' }}">
                        {{ count($variantAssignments) > 0 ? 'EXPLICIT' : 'PRODUCT FALLBACK' }}
                    </span>
                </div>
                <form method="post" action="{{ route('admin.media.galleries.variants.update', ['variant' => $variant->id]) }}" class="stack section-space">
                    @csrf
                    @method('PATCH')
                    <input type="hidden" name="expected_revision" value="{{ $variantGallery?->revision ?? 0 }}">
                    <div class="grid two">
                        @for ($slot = 0; $slot < $maxItems; $slot++)
                            @php $selected = $variantAssignments[$slot] ?? null; @endphp
                            <div class="field">
                                <label for="variant-{{ md5($variant->id) }}-slot-{{ $slot }}">Position {{ $slot + 1 }}</label>
                                <select id="variant-{{ md5($variant->id) }}-slot-{{ $slot }}" name="media_ids[]" style="width:100%;border:1px solid #ccd8e1;border-radius:11px;background:#fff;padding:11px 12px;color:#102235">
                                    <option value="">— Use no explicit item —</option>
                                    @if ($selected && ! $eligibleAssets->contains('id', $selected))
                                        <option value="{{ $selected }}" selected>[INVALID — clear before saving] {{ $selected }}</option>
                                    @endif
                                    @foreach ($eligibleAssets as $asset)
                                        <option value="{{ $asset->id }}" @selected($selected === $asset->id)>
                                            {{ $asset->semantic_label }} · {{ $asset->id }}
                                        </option>
                                    @endforeach
                                </select>
                            </div>
                        @endfor
                    </div>
                    <div class="actions">
                        <button class="btn secondary" type="submit">Save {{ $variant->color }} gallery</button>
                        <span class="muted">Revision {{ $variantGallery?->revision ?? 0 }} · Empty explicit gallery resolves to product fallback.</span>
                    </div>
                </form>
            </div>
        @endforeach
        </div>
    </section>
@endforeach
</div>
@endsection
