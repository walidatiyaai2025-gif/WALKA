@extends('admin.layout')

@section('title', 'Featured Products · WALKA Admin')
@section('topbar', 'Featured Products')

@section('content')
@php
    $hasPublished = $entry->published_revision !== null;
    $hasChanges = $hasPublished && $entry->draft_payload !== $entry->published_payload;
    $variantLabels = $variants->mapWithKeys(function ($variant) {
        return [$variant->id => ($variant->product?->name ?? $variant->product_id).' · '.$variant->color.' · '.$variant->id];
    });
@endphp

<div class="page-head">
    <div>
        <p class="eyebrow">TYPED MERCHANDISING</p>
        <h1>Featured products</h1>
        <p class="lead">Choose which existing WALKA variants appear in the Home collection and editorial module. Only stable catalog IDs can be selected; Product Master facts, ASINs, Pantones and Amazon destinations stay locked.</p>
    </div>
    <a class="btn secondary" href="{{ route('admin.content.index') }}">← Mobile content</a>
</div>

<div class="grid metrics">
    <div class="card metric"><div class="metric-label">Stable key</div><div class="metric-value" style="font-size:20px">home.featured</div><div class="metric-note">Typed schema v1</div></div>
    <div class="card metric"><div class="metric-label">Draft revision</div><div class="metric-value">{{ $entry->revision }}</div><div class="metric-note">Concurrency protected</div></div>
    <div class="card metric"><div class="metric-label">Live revision</div><div class="metric-value">{{ $entry->published_revision ?? '—' }}</div><div class="metric-note">{{ $hasPublished ? 'Published membership' : 'Not published yet' }}</div></div>
    <div class="card metric"><div class="metric-label">State</div><div class="metric-value" style="font-size:20px">{{ ! $hasPublished ? 'Draft only' : ($hasChanges ? 'Changed' : 'Published') }}</div><div class="metric-note">{{ $hasChanges ? 'Publish required' : 'Revision safe' }}</div></div>
</div>

<div class="grid two section-space">
    <section class="card">
        <p class="eyebrow">HOME COLLECTION</p>
        <h2>Two featured families</h2>
        <p class="muted">Order matters. The two collection slots must use different product families so Home keeps both WALKA product families discoverable.</p>

        <form method="post" action="{{ route('admin.content.home.featured.update') }}" class="stack section-space">
            @csrf
            @method('PATCH')
            <input type="hidden" name="revision" value="{{ $entry->revision }}">

            @for ($slot = 0; $slot < 2; $slot++)
                <div class="field">
                    <label for="collection_{{ $slot }}">Collection slot {{ $slot + 1 }}</label>
                    <select id="collection_{{ $slot }}" name="collection_variant_ids[]" required style="width:100%;border:1px solid #ccd8e1;border-radius:11px;background:#fff;padding:11px 12px;color:#102235">
                        @foreach ($variantLabels as $variantId => $label)
                            <option value="{{ $variantId }}" @selected(old('collection_variant_ids.'.$slot, $draft['collection_variant_ids'][$slot]) === $variantId)>{{ $label }}</option>
                        @endforeach
                    </select>
                </div>
            @endfor

            <div class="field">
                <label for="editorial_variant_id">Editorial / Small Changes product</label>
                <select id="editorial_variant_id" name="editorial_variant_id" required style="width:100%;border:1px solid #ccd8e1;border-radius:11px;background:#fff;padding:11px 12px;color:#102235">
                    @foreach ($variantLabels as $variantId => $label)
                        <option value="{{ $variantId }}" @selected(old('editorial_variant_id', $draft['editorial_variant_id']) === $variantId)>{{ $label }}</option>
                    @endforeach
                </select>
            </div>

            <button class="btn navy" type="submit">Save private merchandising draft</button>
        </form>
    </section>

    <aside class="card">
        <p class="eyebrow">DRAFT PREVIEW</p>
        <h2>Current selection</h2>
        <div class="stack">
            @foreach ($draft['collection_variant_ids'] as $index => $variantId)
                <div class="status-row">
                    <div><strong>Collection {{ $index + 1 }}</strong><div class="muted">{{ $variantLabels[$variantId] ?? $variantId }}</div></div>
                    <span class="badge good">APPROVED ID</span>
                </div>
            @endforeach
            <div class="status-row">
                <div><strong>Editorial</strong><div class="muted">{{ $variantLabels[$draft['editorial_variant_id']] ?? $draft['editorial_variant_id'] }}</div></div>
                <span class="badge good">APPROVED ID</span>
            </div>
        </div>

        <div class="status-row section-space">
            <div><strong>Live merchandising</strong><div class="muted">{{ $hasPublished ? 'Revision '.$entry->published_revision : 'No published membership yet' }}</div></div>
            <span class="badge {{ $hasPublished && ! $hasChanges ? 'good' : 'warn' }}">{{ ! $hasPublished ? 'NOT LIVE' : ($hasChanges ? 'CHANGES WAITING' : 'CURRENT') }}</span>
        </div>

        <form method="post" action="{{ route('admin.content.home.featured.publish') }}" class="section-space">
            @csrf
            <input type="hidden" name="revision" value="{{ $entry->revision }}">
            <button class="btn primary" type="submit">Publish featured products</button>
        </form>

        <div class="locked section-space">
            <small>Commerce boundary</small>
            <strong>The CMS stores stable variant IDs only. Flutter resolves product copy, protected facts and Amazon handoff from the catalog/Product Master path.</strong>
        </div>
    </aside>
</div>

<section class="card section-space">
    <p class="eyebrow">REVISION HISTORY</p>
    <h2>Restore safely</h2>
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
                            <form method="post" action="{{ route('admin.content.home.featured.restore') }}">
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
