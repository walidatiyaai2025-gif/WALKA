@extends('admin.layout')

@section('title', 'WALKA Admin · Overview')
@section('topbar', 'Overview')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">Control center</p>
        <h1>Storefront overview</h1>
        <p class="lead">One operational view of the Laravel API that powers the WALKA mobile storefront. Catalog edits here flow through the same database-backed API consumed by Flutter.</p>
    </div>
    <div class="actions">
        <a class="btn secondary" href="{{ route('admin.media.index') }}">Media library</a>
        <a class="btn secondary" href="{{ route('admin.media.galleries.index') }}">Media galleries</a>
        <a class="btn primary" href="{{ route('admin.catalog') }}">Manage catalog →</a>
    </div>
</div>

<section class="grid metrics" aria-label="Dashboard metrics">
    <article class="card metric">
        <div class="metric-label">Products</div>
        <div class="metric-value">{{ $productCount }}</div>
        <div class="metric-note">Stable product identities</div>
    </article>
    <article class="card metric">
        <div class="metric-label">Variants</div>
        <div class="metric-value">{{ $variantCount }}</div>
        <div class="metric-note">Sellable color destinations</div>
    </article>
    <article class="card metric">
        <div class="metric-label">Audit events</div>
        <div class="metric-value">{{ $auditCount }}</div>
        <div class="metric-note">Immutable effective edits</div>
    </article>
    <article class="card metric">
        <div class="metric-label">Backend release</div>
        <div class="metric-value" style="font-size:25px">{{ $release }}</div>
        <div class="metric-note">API {{ $apiVersion }}</div>
    </article>
</section>

<section class="grid two section-space">
    <article class="card">
        <p class="eyebrow">Live contract</p>
        <h2>Backend readiness</h2>
        <div class="status-row">
            <div><strong>Catalog database</strong><div class="muted" style="font-size:12px;margin-top:3px">Public `/api/v1/catalog` source</div></div>
            <span class="badge {{ $catalogReady ? 'good' : 'warn' }}">{{ $catalogReady ? 'READY' : 'NEEDS SEED' }}</span>
        </div>
        <div class="status-row">
            <div><strong>Admin API token</strong><div class="muted" style="font-size:12px;margin-top:3px">Backend-only Bearer API surface</div></div>
            <span class="badge {{ $adminApiConfigured ? 'good' : 'warn' }}">{{ $adminApiConfigured ? 'CONFIGURED' : 'NOT SET' }}</span>
        </div>
        <div class="status-row">
            <div><strong>Purchase mode</strong><div class="muted" style="font-size:12px;margin-top:3px">No WALKA cart or payment storage</div></div>
            <span class="badge lock">{{ strtoupper(str_replace('_', ' ', $purchaseMode)) }}</span>
        </div>
        <div class="status-row">
            <div><strong>Mobile contract</strong><div class="muted" style="font-size:12px;margin-top:3px">Flutter consumes public API only</div></div>
            <span class="badge good">{{ strtoupper($apiVersion) }}</span>
        </div>
    </article>

    <article class="card">
        <p class="eyebrow">How data moves</p>
        <h2>Flutter connection</h2>
        <div class="stack" style="gap:11px">
            <div class="locked"><small>1 · Mobile request</small><strong><code>WALKA_API_BASE_URL</code> + <code>/api/v1/catalog</code></strong></div>
            <div class="locked"><small>2 · Laravel source</small><strong>Products + variants from database</strong></div>
            <div class="locked"><small>3 · Admin authoring</small><strong>This dashboard → CatalogAuthoringService</strong></div>
            <div class="locked"><small>4 · Purchase</small><strong>Official Amazon redirect from variant URL</strong></div>
        </div>
    </article>
</section>

<section class="card section-space">
    <div class="page-head" style="margin-bottom:16px;align-items:center">
        <div>
            <p class="eyebrow">Recent activity</p>
            <h2 style="margin-bottom:0">Catalog audit trail</h2>
        </div>
        <a class="btn secondary" href="{{ route('admin.audits') }}">View all</a>
    </div>
    @if ($recentAudits->isEmpty())
        <div class="locked"><strong>No catalog edits recorded yet.</strong><div class="muted" style="font-size:12px;margin-top:5px">Your first effective product or variant edit will appear here.</div></div>
    @else
        <div class="table-wrap">
            <table>
                <thead><tr><th>Time</th><th>Target</th><th>Action</th><th>Revision</th><th>Changed fields</th></tr></thead>
                <tbody>
                @foreach ($recentAudits as $audit)
                    <tr>
                        <td>{{ $audit->created_at?->format('Y-m-d H:i') }}</td>
                        <td><code>{{ $audit->target_type }}:{{ $audit->target_id }}</code></td>
                        <td>{{ strtoupper($audit->action) }}</td>
                        <td>{{ $audit->from_revision }} → {{ $audit->to_revision }}</td>
                        <td>{{ implode(', ', array_keys($audit->changes ?? [])) ?: '—' }}</td>
                    </tr>
                @endforeach
                </tbody>
            </table>
        </div>
    @endif
</section>
@endsection
