@extends('admin.layout')

@section('title', 'WALKA Admin · Catalog')
@section('topbar', 'Catalog management')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">Authoring surface</p>
        <h1>Products & variants</h1>
        <p class="lead">Edit customer-facing presentation while Product Master identity, facts, ASINs, Pantones and internal ordering remain locked by design.</p>
    </div>
    <span class="badge lock">REVISION PROTECTED</span>
</div>

@if ($products->isEmpty())
    <section class="card">
        <h2>Catalog is not seeded</h2>
        <p class="lead">Run the WALKA database migrations and catalog seeder before authoring content.</p>
    </section>
@else
    <div class="stack">
    @foreach ($products as $product)
        <article class="card">
            <div class="page-head" style="margin-bottom:18px;align-items:center">
                <div>
                    <p class="eyebrow">{{ $product->category }}</p>
                    <h2 style="margin-bottom:5px">{{ $product->name }}</h2>
                    <div class="muted" style="font-size:12px"><code>{{ $product->id }}</code> · revision {{ $product->revision }}</div>
                </div>
                <span class="badge {{ $product->is_visible ? 'good' : 'warn' }}">{{ $product->is_visible ? 'VISIBLE' : 'HIDDEN' }}</span>
            </div>

            <form method="post" action="{{ route('admin.catalog.products.update', ['product' => $product->id]) }}" class="stack">
                @csrf
                @method('PATCH')
                <input type="hidden" name="revision" value="{{ $product->revision }}">
                <div class="grid two">
                    <div class="stack">
                        <div class="field">
                            <label for="name-{{ $product->id }}">Customer-facing product name</label>
                            <input id="name-{{ $product->id }}" name="name" value="{{ $product->name }}" maxlength="160" required>
                        </div>
                        <div class="field">
                            <label for="features-{{ $product->id }}">Features · one per line</label>
                            <textarea id="features-{{ $product->id }}" name="features_text" maxlength="5000">{{ implode("\n", $product->features ?? []) }}</textarea>
                        </div>
                        @include('admin.partials.product-presentation-fields', ['product' => $product])
                        <div><button class="btn navy" type="submit">Save product presentation</button></div>
                    </div>
                    <div class="stack">
                        <div class="locked">
                            <small>Locked Product Master identity</small>
                            <div class="locked-grid" style="margin-top:10px">
                                <div><small>ID</small><strong>{{ $product->id }}</strong></div>
                                <div><small>Category</small><strong>{{ $product->category }}</strong></div>
                                <div><small>Internal sort order</small><strong>{{ $product->sort_order }}</strong></div>
                            </div>
                        </div>
                        <div class="locked">
                            <small>Verified facts · read only</small>
                            <strong>{{ count($product->facts ?? []) }} typed Product Master field{{ count($product->facts ?? []) === 1 ? '' : 's' }}</strong>
                            <div class="muted" style="font-size:11px;line-height:1.55;margin-top:6px">Verified dimensions, material/care rules and protected claims are intentionally not editable here.</div>
                        </div>
                    </div>
                </div>
            </form>

            <div class="section-space">
                <p class="eyebrow">Variants</p>
                <h3>Customer-facing variant presentation</h3>
                <p class="muted" style="font-size:12px">Visibility and presentation order are owner-controlled. Stable variant ID, Pantone, ASIN and internal sort order remain read-only.</p>
                <div class="table-wrap">
                    <table>
                        <thead><tr><th>Variant</th><th>Display color</th><th>Visible</th><th>Presentation order</th><th>Locked Pantone</th><th>Locked ASIN</th><th>Internal order</th><th>Revision</th><th>Action</th></tr></thead>
                        <tbody>
                        @foreach ($product->variants as $variant)
                            @php($variantFormId = 'variant-form-'.md5($variant->id))
                            <tr>
                                <td><code>{{ $variant->id }}</code></td>
                                <td>
                                    <form id="{{ $variantFormId }}" method="post" action="{{ route('admin.catalog.variants.update', ['variant' => $variant->id]) }}">
                                        @csrf
                                        @method('PATCH')
                                        <input type="hidden" name="revision" value="{{ $variant->revision }}">
                                        <input type="hidden" name="presentation_controls" value="1">
                                        <div class="field"><input name="color" value="{{ $variant->color }}" maxlength="80" required aria-label="Display color for {{ $variant->id }}"></div>
                                    </form>
                                </td>
                                <td>
                                    <label style="display:inline-flex;align-items:center;gap:7px;font-size:12px;font-weight:700">
                                        <input form="{{ $variantFormId }}" type="checkbox" name="is_visible" value="1" {{ (bool) $variant->getAttribute('is_visible') ? 'checked' : '' }}>
                                        {{ (bool) $variant->getAttribute('is_visible') ? 'Visible' : 'Hidden' }}
                                    </label>
                                </td>
                                <td>
                                    <div class="field" style="min-width:105px">
                                        <input form="{{ $variantFormId }}" name="presentation_order" type="number" min="0" max="65535" value="{{ (int) $variant->getAttribute('presentation_order') }}" required aria-label="Presentation order for {{ $variant->id }}">
                                    </div>
                                </td>
                                <td>{{ $variant->pantone ?: '—' }}</td>
                                <td><code>{{ $variant->asin }}</code></td>
                                <td>{{ $variant->sort_order }}</td>
                                <td>{{ $variant->revision }}</td>
                                <td><button class="btn secondary" type="submit" form="{{ $variantFormId }}">Save presentation</button></td>
                            </tr>
                        @endforeach
                        </tbody>
                    </table>
                </div>
            </div>
        </article>
    @endforeach
    </div>
@endif

<section class="card section-space">
    <p class="eyebrow">Safety boundary</p>
    <h2>Fields intentionally locked</h2>
    <p class="lead">{{ implode(', ', $lockedFields) }}. Stable identities and Product Master truth cannot be changed by this presentation editor.</p>
</section>
@endsection
