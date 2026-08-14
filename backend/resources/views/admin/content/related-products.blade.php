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
        <p class="lead">Choose which existing WALKA product families may be recommended from each Product Detail page. This editor stores stable Product IDs only; names, facts, media, visibility and Amazon destinations continue to come from their governed sources.</p>
    </div>
    <a class="btn secondary" href="{{ route('admin.content.index') }}">← Mobile content</a>
</div>

<div class="grid metrics">
    <div class="card metric"><div class="metric-label">Stable key</div><div class="metric-value" style="font-size:18px">pdp.related_products</div><div class="metric-note">Typed schema v1</div></div>
    <div class="card metric"><div class="metric-label">Draft revision</div><div class="metric-value">{{ $entry->revision }}</div><div class="metric-note">Optimistic concurrency</div></div>
    <div class="card metric"><div class="metric-label">Live revision</div><div class="metric-value">{{ $entry->published_revision ?? '—' }}</div><div class="metric-note">{{ $hasPublished ? 'Published relationships' : 'Not published yet' }}</div></div>
    <div class="card metric"><div class="metric-label">State</div><div class="metric-value" style="font-size:20px">{{ ! $hasPublished ? 'Draft only' : ($hasChanges ? 'Changed' : 'Published') }}</div><div class="metric-note">Max {{ $maxRelated }} per product</div></div>
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
                <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap">
                    <code>{{ $product->id }}</code>
                    <span class="badge {{ $product->is_visible ? 'good' : 'lock' }}">{{ $product->is_visible ? 'VISIBLE' : 'HIDDEN' }}</span>
                </div>
                <p class="muted section-space">Select up to {{ $maxRelated }} other stable product families. Order values are evaluated only for selected products.</p>

                <div class="stack section-space">
                    @foreach ($products as $candidate)
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
                                    <span>{{ $candidate->name }}<br><code>{{ $candidate->id }}</code> @if (! $candidate->is_visible)<span class="badge lock">HIDDEN</span>@endif</span>
                                </label>
                            </div>
                            <div class="field">
                                <label for="order_{{ $product->id }}_{{ $candidate->id }}">Order</label>
                                <input id="order_{{ $product->id }}_{{ $candidate->id }}" name="order[{{ $product->id }}][{{ $candidate->id }}]" type="number" min="1" max="{{ $maxRelated }}" value="{{ old('order.'.$product->id.'.'.$candidate->id, $defaultPosition) }}">
                            </div>
                        </div>
                    @endforeach
                </div>
            </section>
        @endforeach
    </div>

    <section class="card section-space">
        <p class="eyebrow">PRIVATE DRAFT</p>
        <h2>Save relationship changes</h2>
        <p class="muted">Saving does not change live PDPs. The next Publish snapshots only stable relationship IDs. Hidden products are never made visible or purchasable by this setting.</p>
        <button class="btn navy section-space" type="submit">Save related-products draft</button>
    </section>
</form>

<div class="grid two section-space">
    <section class="card">
        <p class="eyebrow">DRAFT PREVIEW</p>
        <h2>Resolved stable-ID order</h2>
        @foreach ($draft['relationships'] as $relationship)
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
        @endforeach
    </section>

    <aside class="card">
        <p class="eyebrow">PUBLICATION GATE</p>
        <h2>Publish recommendations</h2>
        <p class="muted">Compatible clients validate the published schema, cross-resolve every ID through the visible catalog, then use last-known-good or bundled fallback if the remote content cannot be trusted.</p>
        <div class="status-row"><div><strong>Live relationships</strong><div class="muted">{{ $hasPublished ? 'Revision '.$entry->published_revision : 'No published relationships yet' }}</div></div><span class="badge {{ $hasPublished && ! $hasChanges ? 'good' : 'warn' }}">{{ ! $hasPublished ? 'NOT LIVE' : ($hasChanges ? 'CHANGES WAITING' : 'CURRENT') }}</span></div>
        <form method="post" action="{{ route('admin.content.pdp.related-products.publish') }}" class="section-space">
            @csrf
            <input type="hidden" name="revision" value="{{ $entry->revision }}">
            <button class="btn primary" type="submit">Publish related products</button>
        </form>
        <div class="locked section-space"><small>Commerce boundary</small><strong>No URL, ASIN, Pantone, fact, media path or purchase behavior is editable here. Related cards resolve through the governed catalog and existing Amazon handoff only.</strong></div>
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
