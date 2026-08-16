@extends('admin.layout')

@section('title', 'Amazon Destinations · WALKA Admin')
@section('topbar', 'Amazon destinations')

@section('content')
@php
    $hasPublished = $entry->published_revision !== null;
    $hasChanges = $hasPublished && $entry->draft_payload !== $entry->published_payload;
@endphp

<div class="page-head">
    <div>
        <p class="eyebrow">CMS-060/061 · GOVERNED COMMERCE</p>
        <h1>Amazon purchase destinations</h1>
        <p class="lead">Control which approved Amazon markets are enabled for every released WALKA variant. Variant IDs, Product Master ASINs and canonical Amazon paths are read-only and revalidated on save, publish, restore and public delivery.</p>
    </div>
    <a class="btn secondary" href="{{ route('admin.content.index') }}">← Mobile content</a>
</div>

<div class="grid metrics">
    <div class="card metric"><div class="metric-label">Stable key</div><div class="metric-value" style="font-size:20px">commerce.map</div><div class="metric-note">Typed schema v1</div></div>
    <div class="card metric"><div class="metric-label">Released variants</div><div class="metric-value">{{ $variants->count() }}</div><div class="metric-note">All require active US mapping</div></div>
    <div class="card metric"><div class="metric-label">Draft revision</div><div class="metric-value">{{ $entry->revision }}</div><div class="metric-note">Optimistic concurrency</div></div>
    <div class="card metric"><div class="metric-label">State</div><div class="metric-value" style="font-size:20px">{{ ! $hasPublished ? 'Draft only' : ($hasChanges ? 'Changed' : 'Published') }}</div><div class="metric-note">Live revision {{ $entry->published_revision ?? '—' }}</div></div>
</div>

<form method="post" action="{{ route('admin.content.commerce.update') }}" class="section-space">
    @csrf
    @method('PATCH')
    <input type="hidden" name="revision" value="{{ $entry->revision }}">

    <section class="card">
        <p class="eyebrow">PROTECTED PRODUCT MASTER MAPPING</p>
        <h2>Released variants & approved markets</h2>
        <p class="muted">US is mandatory and cannot be disabled because the mobile resolver has a deterministic US fallback. Canada and Mexico may be enabled per variant. The dashboard never accepts a free-form destination URL or editable ASIN.</p>

        <div class="table-wrap section-space">
            <table>
                <thead>
                    <tr><th>Variant</th><th>Protected ASIN</th><th>Market</th><th>Canonical destination</th><th>State</th></tr>
                </thead>
                <tbody>
                @foreach ($variants as $variant)
                    @foreach ($markets as $market)
                        @php
                            $identity = $variant->id.'|'.$market;
                            $mapping = $draftMappings->get($identity);
                            $active = $market === 'US' ? true : (bool) ($mapping['active'] ?? false);
                            $destination = \App\Services\Content\CommerceMapContentDefinition::canonicalDestination($market, (string) $variant->asin);
                        @endphp
                        <tr>
                            <td>
                                <strong>{{ $variant->product?->name ?? $variant->product_id }}</strong>
                                <div class="muted">{{ $variant->color }} · <code>{{ $variant->id }}</code></div>
                                @if ($variant->pantone)<div class="muted">Pantone {{ $variant->pantone }}</div>@endif
                            </td>
                            <td><code>{{ $variant->asin }}</code><div class="muted">Product Master · read-only</div></td>
                            <td><strong>{{ $market }}</strong></td>
                            <td><code style="font-size:11px">{{ $destination }}</code></td>
                            <td>
                                @if ($market === 'US')
                                    <span class="badge good">REQUIRED · ACTIVE</span>
                                @else
                                    <input type="hidden" name="active[{{ $variant->id }}][{{ $market }}]" value="0">
                                    <label style="display:flex;align-items:center;gap:8px;font-size:12px;font-weight:800;color:#365068">
                                        <input name="active[{{ $variant->id }}][{{ $market }}]" type="checkbox" value="1" {{ old('active.'.$variant->id.'.'.$market, $active) ? 'checked' : '' }}>
                                        Enabled
                                    </label>
                                @endif
                            </td>
                        </tr>
                    @endforeach
                @endforeach
                </tbody>
            </table>
        </div>

        <button class="btn navy section-space" type="submit">Save private commerce draft</button>
        <div class="locked section-space"><small>Fail-closed boundary</small><strong>Unknown/missing variants, ASIN drift, stale Product Master revisions, duplicate market mappings and non-Amazon destinations are rejected before publication.</strong></div>
    </section>
</form>

<div class="grid two section-space">
    <section class="card">
        <p class="eyebrow">PUBLICATION GATE</p>
        <h2>Publish verified mapping</h2>
        <p class="muted">Publish revalidates the complete draft against the current Product Master. The public API revalidates again before returning any Amazon destination.</p>
        <div class="status-row"><div><strong>Live snapshot</strong><div class="muted">{{ $hasPublished ? 'Revision '.$entry->published_revision : 'No published commerce map yet' }}</div></div><span class="badge {{ $hasPublished && ! $hasChanges ? 'good' : 'warn' }}">{{ ! $hasPublished ? 'NOT LIVE' : ($hasChanges ? 'CHANGES WAITING' : 'CURRENT') }}</span></div>
        <form method="post" action="{{ route('admin.content.commerce.publish') }}" class="section-space">
            @csrf
            <input type="hidden" name="revision" value="{{ $entry->revision }}">
            <button class="btn primary" type="submit">Publish verified destinations</button>
        </form>
    </section>

    <aside class="card">
        <p class="eyebrow">COMMERCE INVARIANTS</p>
        <h2>What cannot change here</h2>
        <div class="status-row"><div><strong>Variant identity</strong><div class="muted">Stable ID and Product membership</div></div><span class="badge lock">LOCKED</span></div>
        <div class="status-row"><div><strong>ASIN / Pantone</strong><div class="muted">Product Master truth</div></div><span class="badge lock">LOCKED</span></div>
        <div class="status-row"><div><strong>Purchase architecture</strong><div class="muted">Compiled amazon_redirect behavior</div></div><span class="badge lock">LOCKED</span></div>
        <div class="status-row"><div><strong>Destination shape</strong><div class="muted">HTTPS approved Amazon host + /dp/{ASIN}</div></div><span class="badge good">SERVER BUILT</span></div>
    </aside>
</div>

<section class="card section-space">
    <p class="eyebrow">IMMUTABLE HISTORY</p>
    <h2>Reasoned restore to private draft</h2>
    <p class="muted">Rollback never republishes automatically. Historical payloads must still match the current canonical variant IDs, ASINs and revisions before they can become a new draft.</p>
    <div class="table-wrap section-space">
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
                            <form method="post" action="{{ route('admin.content.commerce.restore') }}" style="display:grid;grid-template-columns:minmax(170px,1fr) auto;gap:8px;align-items:center">
                                @csrf
                                <input type="hidden" name="revision" value="{{ $entry->revision }}">
                                <input type="hidden" name="source_revision" value="{{ $revision->revision }}">
                                <input name="reason" type="text" minlength="3" maxlength="280" placeholder="Reason for restoring this mapping" required>
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
