@extends('admin.layout')

@section('title', 'Surface Media · WALKA Admin')
@section('topbar', 'Surface media')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">COMPILED PRESENTATION SLOTS</p>
        <h1>Home, category & editorial media</h1>
        <p class="lead">Assign admitted media to a fixed allowlist of presentation slots. Slot identity, required purpose and cardinality are compiled server contracts; the dashboard cannot create arbitrary remote widgets.</p>
    </div>
    <div class="actions">
        <a class="btn secondary" href="{{ route('admin.media.index') }}">← Media library</a>
        <a class="btn secondary" href="{{ route('admin.media.galleries.index') }}">Product galleries</a>
    </div>
</div>

<div class="locked">
    <small>CMS-033 SAFETY BOUNDARY</small>
    <strong>Only admitted, purpose-correct media with a canonical derivative can be saved. Draft/Archived media, wrong purpose, unknown slots and stale fingerprints fail closed before mutation.</strong>
</div>

<div class="stack section-space">
@foreach ($definitions as $slotKey => $definition)
    @php
        $items = $itemsBySlot->get($slotKey, collect());
        $assignedIds = $items->pluck('media_asset_id')->values()->all();
        $fingerprint = \App\Services\SurfaceMediaService::fingerprint($assignedIds);
        $eligible = $eligibleBySlot[$slotKey];
    @endphp
    <section class="card">
        <div class="actions" style="justify-content:space-between;align-items:flex-start">
            <div>
                <p class="eyebrow">{{ strtoupper($definition['purpose']->value) }} MEDIA</p>
                <h2>{{ $definition['label'] }}</h2>
                <p class="muted"><code>{{ $slotKey }}</code></p>
            </div>
            <span class="badge {{ $items->isEmpty() ? 'lock' : 'good' }}">{{ $items->isEmpty() ? 'UNASSIGNED' : 'ASSIGNED' }}</span>
        </div>

        <div class="locked-grid section-space">
            <div class="locked"><small>Required purpose</small><strong>{{ $definition['purpose']->value }}</strong></div>
            <div class="locked"><small>Maximum items</small><strong>{{ $definition['max_items'] }}</strong></div>
            <div class="locked"><small>Protected category</small><strong>{{ $definition['category_id'] ?? '—' }}</strong></div>
            <div class="locked"><small>Eligible now</small><strong>{{ $eligible->count() }}</strong></div>
        </div>

        <form method="post" action="{{ route('admin.media.surfaces.update', ['slot' => $slotKey]) }}" class="stack section-space">
            @csrf
            @method('PATCH')
            <input type="hidden" name="expected_fingerprint" value="{{ $fingerprint }}">

            @for ($slot = 0; $slot < $definition['max_items']; $slot++)
                @php $selected = $assignedIds[$slot] ?? null; @endphp
                <div class="field">
                    <label for="surface-{{ md5($slotKey) }}-{{ $slot }}">Media {{ $slot + 1 }}</label>
                    <select id="surface-{{ md5($slotKey) }}-{{ $slot }}" name="media_ids[]" style="width:100%;border:1px solid #ccd8e1;border-radius:11px;background:#fff;padding:11px 12px;color:#102235">
                        <option value="">— No assignment —</option>
                        @if ($selected && ! $eligible->contains('id', $selected))
                            <option value="{{ $selected }}" selected>[INVALID — clear before saving] {{ $selected }}</option>
                        @endif
                        @foreach ($eligible as $asset)
                            <option value="{{ $asset->id }}" @selected($selected === $asset->id)>
                                {{ $asset->semantic_label }} · {{ $asset->id }} · {{ $asset->canonicalDerivative->width }}×{{ $asset->canonicalDerivative->height }}
                            </option>
                        @endforeach
                    </select>
                </div>
            @endfor

            <div class="actions">
                <button class="btn navy" type="submit">Save assignment</button>
                <span class="muted">Current fingerprint: <code>{{ substr($fingerprint, 0, 12) }}…</code></span>
            </div>
        </form>
    </section>
@endforeach
</div>
@endsection
