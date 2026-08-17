@extends('admin.layout')

@section('title', 'Related Products · WALKA Admin')
@section('topbar', 'Related Products')

@section('content')
@php
    $draftByProduct = collect($draft['relationships'])->keyBy('product_id');
    $hasPublished = $entry->published_revision !== null;
    $hasChanges = $hasPublished && $entry->draft_payload !== $entry->published_payload;
@endphp

<div class="page-head">
    <div>
        <p class="eyebrow">GOVERNED PDP MERCHANDISING</p>
        <h1>Related products</h1>
        <p class="lead">Choose up to {{ $maxRelated }} currently visible catalog products to recommend from each Product Detail page. This editor stores Product IDs only; copy, media, identity and Amazon destinations are resolved from their governed sources at runtime.</p>
    </div>
    <a class="btn secondary" href="{{ route('admin.content.index') }}">← Mobile content</a>
</div>

<div class="grid metrics">
    <div class="card metric"><div class="metric-label">Stable key</div><div class="metric-value" style="font-size:18px">pdp.related_products</div><div class="metric-note">Typed schema v1</div></div>
    <div class="card metric"><div class="metric-label">Draft revision</div><div class="metric-value">{{ $entry->revision }}</div><div class="metric-note">Optimistic concurrency</div></div>
    <div class="card metric"><div class="metric-label">Live revision</div><div class="metric-value">{{ $entry->published_revision ?? '—' }}</div><div class="metric-note">{{ $hasPublished ? 'Published relationships' : 'Not published yet' }}</div></div>
    <div class="card metric"><div class="metric-label">Visible products</div><div class="metric-value">{{ $products->count() }}</div><div class="metric-note">Dynamic Dashboard catalog</div></div>
</div>

<form method="post" action="{{ route('admin.content.pdp.related-products.update') }}" class="section-space">
    @csrf
    @method('PATCH')
    <input type="hidden" name="revision" value="{{ $entry->revision }}">

    <div class="grid two">
        @foreach ($products as $product)
            @php
                $relationship = $draftByProduct->get($product->id, ['related_product_ids' => []]);
                $relatedIds = $relationship['related_product_ids'] ?? [];
            @endphp
            <section class="card">
                <p class="eyebrow">SOURCE PRODUCT</p>
                <h2>{{ $product->name }}</h2>
                <code>{{ $product->id }}</code>
                <p class="muted section-space">Only currently visible catalog products are eligible. Order applies only to selected recommendations.</p>

                <div class="stack section-space">
                    @forelse ($products as $candidate)
                        @continue($candidate->id === $product->id)
                        @php
                            $positionIndex = array_search($candidate->id, $relatedIds, true);
                            $selected = $positionIndex !== false;
                            $defaultPosition = $selected ? $positionIndex + 1 : 1;
                            $oldSelected = (bool) old('related.'.$product->id.'.'.$candidate->id, $selected);
                        @endphp
                        <div class="locked" style="display:grid;grid-template-columns:minmax(0,1fr) 90px;gap:12px;align-items:center">
                            <div>
                                <input type="hidden" name="related[{{ $product->id }}][{{ $candidate->id }}]" value="0">
                                <label style="display:flex;align-items:flex-start;gap:9px;font-weight:800;color:#003366">
                                    <input type="checkbox" name="related[{{ $product->id }}][{{ $candidate->id }}]" value="1" {{ $oldSelected ? 'checked' : '' }}>
                                    <span>{{ $candidate->name }}<br><code>{{ $candidate->id }}</code></span>
                                </label>
                            </div>
                            <div class="field">
                                <label for="order_{{ $product->id }}_{{ $candidate->id }}">Order</label>
                                <input id="order_{{ $product->id }}_{{ $candidate->id }}" name="order[{{ $product->id }}][{{ $candidate->id }}]" type="number" min="1" max="{{ $maxRelated }}" value="{{ old('order.'.$product->id.'.'.$candidate->id, $defaultPosition) }}">
                            </div>
                        </div>
                    @empty
                        <div class="locked"><strong>No other visible product is available.</strong></div>
                    @endforelse
                </div>
            </section>
        @endforeach
    </div>

    <section class="card section-space">
        <p class="eyebrow">PRIVATE DRAFT</p>
        <h2>Save relationship changes</h2>
        <p class="muted">Saving does not change live PDPs. Publish revalidates every Product ID against the current visible catalog.</p>
        <button class="btn navy section-space" type="submit">Save related-products draft</button>
    </section>
</form>

<div class="grid two section-space">
    <section class="card">
        <p class="eyebrow">DRAFT PREVIEW</p>
        <h2>Resolved Product-ID order</h2>
        @forelse ($draft['relationships'] as $relationship)
            @php $source = $products->firstWhere('id', $relationship['product_id']); @endphp
            <div class="status-row" style="align-items:flex-start">
                <div>
                    <strong>{{ $source?->name ?? $relationship['product_id'] }}</strong>
                    <div class="muted"><code>{{ $relationship['product_id'] }}</code></div>
                    <div style="margin-top:6px">
                        @forelse ($relationship['related_product_ids'] as $index => $relatedId)
                            <span class="badge good">{{ $index + 1 }} · {{ $relatedId }}</span>
                        @empty
                            <span class="badge lock">NO RELATED PRODUCTS</span>
                        @endforelse
                    </div>
                </div>
            </div>
        @empty
            <div class="locked"><strong>No relationships configured yet.</strong></div>
        @endforelse
    </section>

    <aside class="card">
        <p class="eyebrow">PUBLICATION GATE</p>
        <h2>Publish recommendations</h2>
        <p class="muted">Compatible clients cross-resolve every ID through the visible dynamic catalog and fall back safely if remote content is stale or invalid.</p>
        <div class="status-row"><div><strong>Live relationships</strong><div class="muted">{{ $hasPublished ? 'Revision '.$entry->published_revision : 'No published relationships yet' }}</div></div><span class="badge {{ $hasPublished && ! $hasChanges ? 'good' : 'warn' }}">{{ ! $hasPublished ? 'NOT LIVE' : ($hasChanges ? 'CHANGES WAITING' : 'CURRENT') }}</span></div>
        <form method="post" action="{{ route('admin.content.pdp.related-products.publish') }}" class="section-space">
            @csrf
            <input type="hidden" name="revision" value="{{ $entry->revision }}">
            <button class="btn primary" type="submit">Publish related products</button>
        </form>
        <div class="locked section-space"><small>Commerce boundary</small><strong>No URL, ASIN, Pantone, facts, media path or purchase behavior is editable here.</strong></div>
    </aside>
</div>

<section class="card section-space">
    <p class="eyebrow">REVISION HISTORY</p>
    <h2>Restore relationships safely</h2>
    <div class="table-wrap">
        <table>
            <thead><tr><th>Revision</th><th>Action</th><th>Source</th><th>Created</th><th>Recovery</th></tr></thead>
            <tbody>
            @foreach ($entry->revisions as $revision)
                <tr>
                    <td><strong>#{{ $revision->revision }}</strong></td>
                    <td>{{ str_replace('_', ' ', strtoupper($revision->action)) }}</td>
                    <td>{{ $revision->source_revision ? '#'.$revision->source_revision : '—' }}</td>
                    <td>{{ $revision->created_at?->format('Y-m-d H:i:s') }}</td>
                    <td>
                        @if ($revision->payload !== $entry->draft_payload)
                            <form method="post" action="{{ route('admin.content.pdp.related-products.restore') }}">
                                @csrf
                                <input type="hidden" name="revision" value="{{ $entry->revision }}">
                                <input type="hidden" name="source_revision" value="{{ $revision->revision }}">
                                <button class="btn secondary" type="submit">Restore to draft</button>
                            </form>
                        @else
                            <span class="badge lock">CURRENT DRAFT</span>
                        @endif
                    </td>
                </tr>
            @endforeach
            </tbody>
        </table>
    </div>
</section>
@endsection
