@extends('admin.layout')

@section('title', 'Product Galleries · WALKA Admin')
@section('topbar', 'Product galleries')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">GOVERNED MEDIA ASSIGNMENT</p>
        <h1>Product & variant galleries</h1>
        <p class="lead">Assign only admitted Product media to stable Product Master identities. Ordering is explicit. Empty variant galleries inherit their product gallery metadata until a variant-specific gallery is saved.</p>
    </div>
    <a class="btn secondary" href="{{ route('admin.media.index') }}">← Media library</a>
</div>

<div class="grid metrics">
    <div class="card metric"><div class="metric-label">Eligible admitted media</div><div class="metric-value">{{ $eligibleAssets->count() }}</div><div class="metric-note">Product purpose + canonical derivative</div></div>
    <div class="card metric"><div class="metric-label">Gallery ceiling</div><div class="metric-value">{{ $maxItems }}</div><div class="metric-note">Per product or variant</div></div>
    <div class="card metric"><div class="metric-label">Private storage</div><div class="metric-value" style="font-size:22px">HIDDEN</div><div class="metric-note">No disk/path in public metadata</div></div>
    <div class="card metric"><div class="metric-label">Binary delivery</div><div class="metric-value" style="font-size:22px">OFF</div><div class="metric-note">CMS-035 remains separate</div></div>
</div>

@if ($eligibleAssets->isEmpty())
    <div class="locked section-space">
        <small>No eligible media yet</small>
        <strong>Upload validation alone does not make media assignable. A Product media asset must complete its canonical derivative + explicit admission workflow before it appears here.</strong>
    </div>
@endif

@foreach ($products as $product)
    @php
        $productCurrent = $product->mediaGalleryItems->pluck('media_asset_id')->values()->all();
    @endphp
    <section class="card section-space">
        <div class="page-head" style="margin-bottom:16px;align-items:flex-start">
            <div>
                <p class="eyebrow">PRODUCT GALLERY</p>
                <h2>{{ $product->name }}</h2>
                <div class="muted"><code>{{ $product->id }}</code> · protected Product Master identity</div>
            </div>
            <span class="badge lock">{{ count($productCurrent) }} / {{ $maxItems }}</span>
        </div>

        <form method="post" action="{{ route('admin.media.galleries.products.update', ['product' => $product->id]) }}" class="stack">
            @csrf
            @method('PUT')
            <input type="hidden" name="expected_fingerprint" value="{{ $productFingerprints[$product->id] }}">
            <div class="grid two">
                @for ($slot = 0; $slot < $maxItems; $slot++)
                    <div class="field">
                        <label for="product_{{ $product->id }}_{{ $slot }}">Position {{ $slot + 1 }}</label>
                        <select id="product_{{ $product->id }}_{{ $slot }}" name="media_ids[]" style="width:100%;border:1px solid #ccd8e1;border-radius:11px;background:#fff;padding:11px 12px;color:#102235">
                            <option value="">— Empty —</option>
                            @foreach ($eligibleAssets as $asset)
                                <option value="{{ $asset->id }}" @selected(($productCurrent[$slot] ?? null) === $asset->id)>
                                    {{ $asset->semantic_label ?: $asset->original_filename }} · {{ substr($asset->id, -6) }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                @endfor
            </div>
            <button class="btn navy" type="submit">Save product gallery</button>
        </form>

        <div class="grid two section-space">
            @foreach ($product->variants as $variant)
                @php
                    $variantCurrent = $variant->mediaGalleryItems->pluck('media_asset_id')->values()->all();
                    $inherits = count($variantCurrent) === 0;
                @endphp
                <article class="card" style="background:#f8fafb;border-color:#dbe4ea">
                    <div class="status-row">
                        <div>
                            <small>VARIANT GALLERY</small>
                            <strong>{{ $variant->color }}</strong>
                            <div class="muted"><code>{{ $variant->id }}</code></div>
                        </div>
                        <span class="badge {{ $inherits ? 'lock' : 'good' }}">{{ $inherits ? 'PRODUCT FALLBACK' : count($variantCurrent).' EXPLICIT' }}</span>
                    </div>

                    <form method="post" action="{{ route('admin.media.galleries.variants.update', ['variant' => $variant->id]) }}" class="stack section-space">
                        @csrf
                        @method('PUT')
                        <input type="hidden" name="expected_fingerprint" value="{{ $variantFingerprints[$variant->id] }}">
                        @for ($slot = 0; $slot < $maxItems; $slot++)
                            <div class="field">
                                <label for="variant_{{ md5($variant->id) }}_{{ $slot }}">Position {{ $slot + 1 }}</label>
                                <select id="variant_{{ md5($variant->id) }}_{{ $slot }}" name="media_ids[]" style="width:100%;border:1px solid #ccd8e1;border-radius:11px;background:#fff;padding:10px 11px;color:#102235">
                                    <option value="">— Empty —</option>
                                    @foreach ($eligibleAssets as $asset)
                                        <option value="{{ $asset->id }}" @selected(($variantCurrent[$slot] ?? null) === $asset->id)>
                                            {{ $asset->semantic_label ?: $asset->original_filename }} · {{ substr($asset->id, -6) }}
                                        </option>
                                    @endforeach
                                </select>
                            </div>
                        @endfor
                        <button class="btn secondary" type="submit">Save {{ $variant->color }} gallery</button>
                    </form>
                </article>
            @endforeach
        </div>
    </section>
@endforeach

<div class="locked section-space">
    <small>Protected boundary</small>
    <strong>Gallery assignment never edits Product/Variant IDs, ASINs, Pantones, product facts, Amazon destinations, private storage paths or media lifecycle. Draft/archived media is rejected even if a stale assignment row exists.</strong>
</div>
@endsection
