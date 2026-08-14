@extends('admin.layout')

@section('title', 'PDP Layout · WALKA Admin')
@section('topbar', 'PDP Layout')

@section('content')
@php
    $draftSections = collect($draft['sections'])->keyBy('id');
    $orderById = [];
    foreach ($draft['sections'] as $index => $section) {
        $orderById[$section['id']] = $index + 1;
    }
    $hasPublished = $entry->published_revision !== null;
    $hasChanges = $hasPublished && $entry->draft_payload !== $entry->published_payload;
    $labels = [
        'gallery' => ['Gallery', 'Approved product media and fullscreen gallery'],
        'identity' => ['Product identity', 'Product name and verified identity summary'],
        'variants' => ['Variant selector', 'Visible released color/variant selection'],
        'usage' => ['Usage guidance', 'Optional approved usage presentation'],
        'facts' => ['Verified facts', 'Protected Product Master facts'],
        'editorial' => ['Editorial panel', 'Optional presentation-only supporting panel'],
        'specifications' => ['Specifications', 'Protected verified specification tables'],
        'amazon_trust' => ['Amazon trust', 'Official purchase-destination trust message'],
    ];
@endphp

<div class="page-head">
    <div>
        <p class="eyebrow">TYPED PDP COMPOSITION</p>
        <h1>Product Detail section order & visibility</h1>
        <p class="lead">Reorder approved Product Detail modules and hide only presentation-safe optional sections. Product identity, verified facts/specifications and Amazon commerce trust remain protected and visible.</p>
    </div>
    <a class="btn secondary" href="{{ route('admin.content.index') }}">← Mobile content</a>
</div>

<div class="grid metrics">
    <div class="card metric"><div class="metric-label">Stable key</div><div class="metric-value" style="font-size:20px">pdp.layout</div><div class="metric-note">Typed schema v1</div></div>
    <div class="card metric"><div class="metric-label">Draft revision</div><div class="metric-value">{{ $entry->revision }}</div><div class="metric-note">Optimistic concurrency</div></div>
    <div class="card metric"><div class="metric-label">Live revision</div><div class="metric-value">{{ $entry->published_revision ?? '—' }}</div><div class="metric-note">{{ $hasPublished ? 'Published manifest' : 'Not published yet' }}</div></div>
    <div class="card metric"><div class="metric-label">State</div><div class="metric-value" style="font-size:20px">{{ ! $hasPublished ? 'Draft only' : ($hasChanges ? 'Changed' : 'Published') }}</div><div class="metric-note">{{ $hasChanges ? 'Publish required' : 'Revision safe' }}</div></div>
</div>

<form method="post" action="{{ route('admin.content.pdp.layout.update') }}" class="section-space">
    @csrf
    @method('PATCH')
    <input type="hidden" name="revision" value="{{ $entry->revision }}">

    <section class="card">
        <p class="eyebrow">SECTION MANIFEST</p>
        <h2>Order & visibility</h2>
        <p class="muted">Use every position 1–8 exactly once. Only Usage and Editorial may be hidden. The official Amazon purchase button is outside this CMS manifest and can never be removed here.</p>
        <div class="stack section-space">
            @foreach ($labels as $id => $definition)
                @php
                    [$label, $description] = $definition;
                    $section = $draftSections[$id];
                    $required = in_array($id, $requiredVisible, true);
                @endphp
                <div class="locked" style="display:grid;grid-template-columns:minmax(0,1fr) 100px 150px;gap:12px;align-items:center">
                    <div>
                        <strong style="font-size:14px;color:#003366">{{ $label }}</strong>
                        <div class="muted" style="font-size:12px;margin-top:4px">{{ $description }}</div>
                        <code>{{ $id }}</code>
                    </div>
                    <div class="field">
                        <label for="order_{{ $id }}">Position</label>
                        <input id="order_{{ $id }}" name="order[{{ $id }}]" type="number" min="1" max="8" value="{{ old('order.'.$id, $orderById[$id]) }}" required>
                    </div>
                    <div>
                        @if ($required)
                            <input type="hidden" name="visible[{{ $id }}]" value="1">
                            <span class="badge lock">REQUIRED · VISIBLE</span>
                        @else
                            <input type="hidden" name="visible[{{ $id }}]" value="0">
                            <label style="display:flex;align-items:center;gap:8px;font-size:12px;font-weight:800;color:#365068">
                                <input name="visible[{{ $id }}]" type="checkbox" value="1" {{ old('visible.'.$id, $section['visible']) ? 'checked' : '' }}>
                                Visible
                            </label>
                        @endif
                    </div>
                </div>
            @endforeach
        </div>
        <button class="btn navy section-space" type="submit">Save private PDP layout draft</button>
    </section>
</form>

<div class="grid two section-space">
    <section class="card">
        <p class="eyebrow">DRAFT PREVIEW</p>
        <h2>Rendered sequence</h2>
        @foreach ($draft['sections'] as $index => $section)
            <div class="status-row">
                <div style="display:flex;align-items:center;gap:12px"><span class="nav-icon" style="color:#003366;background:#f0f4f7">{{ $index + 1 }}</span><div><strong>{{ $labels[$section['id']][0] }}</strong><div class="muted"><code>{{ $section['id'] }}</code></div></div></div>
                <span class="badge {{ $section['visible'] ? 'good' : 'lock' }}">{{ $section['visible'] ? 'VISIBLE' : 'HIDDEN' }}</span>
            </div>
        @endforeach
    </section>

    <aside class="card">
        <p class="eyebrow">PUBLICATION GATE</p>
        <h2>Publish PDP layout</h2>
        <p class="muted">Publishing snapshots this exact typed manifest. Compatible clients validate it again and fall back to last-known-good or bundled layout on incompatible remote data.</p>
        <div class="status-row"><div><strong>Live manifest</strong><div class="muted">{{ $hasPublished ? 'Revision '.$entry->published_revision : 'No published layout yet' }}</div></div><span class="badge {{ $hasPublished && ! $hasChanges ? 'good' : 'warn' }}">{{ ! $hasPublished ? 'NOT LIVE' : ($hasChanges ? 'CHANGES WAITING' : 'CURRENT') }}</span></div>
        <form method="post" action="{{ route('admin.content.pdp.layout.publish') }}" class="section-space">
            @csrf
            <input type="hidden" name="revision" value="{{ $entry->revision }}">
            <button class="btn primary" type="submit">Publish PDP layout</button>
        </form>
        <div class="locked section-space"><small>Commerce boundary</small><strong>The CMS cannot mutate stable IDs, Pantone, ASIN, verified facts, arbitrary URLs or the official Amazon handoff behavior.</strong></div>
    </aside>
</div>

<section class="card section-space">
    <p class="eyebrow">REVISION HISTORY</p>
    <h2>Restore layout safely</h2>
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
                            <form method="post" action="{{ route('admin.content.pdp.layout.restore') }}">
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
