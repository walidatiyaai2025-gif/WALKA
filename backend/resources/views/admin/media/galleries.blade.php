@extends('admin.layout')

@section('title', 'Media Galleries · WALKA Admin')
@section('topbar', 'Media galleries')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">GOVERNED PRODUCT MEDIA</p>
        <h1>Product & variant galleries</h1>
        <p class="lead">Assign only admitted product media with validated canonical derivatives. Product galleries are the deterministic fallback only when a variant has no explicit gallery.</p>
    </div>
    <div>
        <a class="btn" href="{{ route('admin.media.index') }}">Back to Media Library</a>
    </div>
</div>

<div class="grid metrics">
    <div class="card metric">
        <div class="metric-label">Eligible media</div>
        <div class="metric-value">{{ $assets->count() }}</div>
        <div class="metric-note">Admitted product-purpose assets only</div>
    </div>
    <div class="card metric">
        <div class="metric-label">Maximum gallery</div>
        <div class="metric-value">{{ $maxItems }}</div>
        <div class="metric-note">Deterministic positions 1–{{ $maxItems }}</div>
    </div>
    <div class="card metric">
        <div class="metric-label">Products</div>
        <div class="metric-value">{{ $products->count() }}</div>
        <div class="metric-note">Stable Product Master IDs</div>
    </div>
</div>

@if ($assets->isEmpty())
    <section class="card section-space">
        <div class="locked">
            <small>Assignment blocked</small>
            <strong>No admitted product-purpose media with canonical derivatives is currently eligible. Uploading Draft media is not enough.</strong>
        </div>
    </section>
@endif

@foreach ($products as $product)
    @php($productGallery = $productGalleries->get($product->id))
    @php($productSelections = $productGallery?->items?->pluck('media_asset_id')->values()->all() ?? [])
    <section class="card section-space">
        <p class="eyebrow">PRODUCT GALLERY</p>
        <h2>{{ $product->name }} <code>{{ $product->id }}</code></h2>
        <p class="muted">Revision {{ $productGallery?->revision ?? 0 }}. This gallery is used as metadata fallback only when a variant has no explicit assignments.</p>

        <form method="post" action="{{ route('admin.media.galleries.products.update', $product) }}" class="stack section-space">
            @csrf
            @method('PUT')
            <input type="hidden" name="expected_revision" value="{{ $productGallery?->revision ?? 0 }}">
            <div class="grid two">
                @for ($position = 0; $position < $maxItems; $position++)
                    <div class="field">
                        <label>Position {{ $position + 1 }}</label>
                        <select name="media_asset_ids[]" style="width:100%;border:1px solid #ccd8e1;border-radius:11px;background:#fff;padding:11px 12px;color:#102235">
                            <option value="">— empty —</option>
                            @foreach ($assets as $asset)
                                <option value="{{ $asset->id }}" @selected(($productSelections[$position] ?? null) === $asset->id)>
                                    {{ $asset->semantic_label }} · {{ substr($asset->id, 0, 10) }}…
                                </option>
                            @endforeach
                        </select>
                    </div>
                @endfor
            </div>
            <button class="btn navy" type="submit" @disabled($assets->isEmpty())>Save product gallery</button>
        </form>

        @foreach ($product->variants as $variant)
            @php($variantGallery = $variantGalleries->get($variant->id))
            @php($variantSelections = $variantGallery?->items?->pluck('media_asset_id')->values()->all() ?? [])
            <div class="section-space" style="border-top:1px solid #dfe8ef;padding-top:24px">
                <p class="eyebrow">VARIANT GALLERY</p>
                <h3>{{ $variant->color }} <code>{{ $variant->id }}</code></h3>
                <p class="muted">Revision {{ $variantGallery?->revision ?? 0 }}. Leave all positions empty to use the product-level gallery fallback.</p>
                <form method="post" action="{{ route('admin.media.galleries.variants.update', $variant) }}" class="stack section-space">
                    @csrf
                    @method('PUT')
                    <input type="hidden" name="expected_revision" value="{{ $variantGallery?->revision ?? 0 }}">
                    <div class="grid two">
                        @for ($position = 0; $position < $maxItems; $position++)
                            <div class="field">
                                <label>Position {{ $position + 1 }}</label>
                                <select name="media_asset_ids[]" style="width:100%;border:1px solid #ccd8e1;border-radius:11px;background:#fff;padding:11px 12px;color:#102235">
                                    <option value="">— empty / fallback —</option>
                                    @foreach ($assets as $asset)
                                        <option value="{{ $asset->id }}" @selected(($variantSelections[$position] ?? null) === $asset->id)>
                                            {{ $asset->semantic_label }} · {{ substr($asset->id, 0, 10) }}…
                                        </option>
                                    @endforeach
                                </select>
                            </div>
                        @endfor
                    </div>
                    <button class="btn navy" type="submit" @disabled($assets->isEmpty())>Save variant gallery</button>
                </form>
            </div>
        @endforeach
    </section>
@endforeach

<section class="card section-space">
    <p class="eyebrow">PUBLIC CONTRACT</p>
    <h2>Fail-closed delivery</h2>
    <div class="stack section-space">
        <div class="locked"><small>Lifecycle</small><strong>Draft or archived media cannot be assigned. If previously assigned media is archived, it is omitted from public metadata.</strong></div>
        <div class="locked"><small>Private storage</small><strong>Public gallery payloads expose stable IDs, semantic labels and canonical dimensions/MIME/hash only. Quarantine disk/path and derivative storage paths never leave the backend.</strong></div>
        <div class="locked"><small>Product truth</small><strong>Gallery assignment does not mutate Product Master identity, ASIN, Pantone, pricing or Amazon destinations.</strong></div>
    </div>
</section>
@endsection
