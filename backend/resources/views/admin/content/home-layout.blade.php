@extends('admin.layout')

@section('title', 'Home Layout · WALKA Admin')
@section('topbar', 'Home Layout')

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
        'hero' => ['Hero', 'Primary Home message and navigation entry point', true],
        'benefits' => ['Benefit band', 'Approved trust/benefit presentation', false],
        'collection' => ['Collection', 'Core product-family discovery', true],
        'small_changes' => ['Editorial card', 'Lifestyle/editorial supporting module', false],
        'trust' => ['Trust strip', 'Catalog/Amazon/release trust metadata', false],
    ];
@endphp

<div class="page-head">
    <div>
        <p class="eyebrow">TYPED HOME COMPOSITION</p>
        <h1>Section order & visibility</h1>
        <p class="lead">Reorder approved Home modules and hide optional sections without changing Flutter code. WALKA still owns the actual components and behavior; the backend can only configure known, validated section IDs.</p>
    </div>
    <a class="btn secondary" href="{{ route('admin.content.index') }}">← Mobile content</a>
</div>

<div class="grid metrics">
    <div class="card metric"><div class="metric-label">Stable key</div><div class="metric-value" style="font-size:20px">home.layout</div><div class="metric-note">Typed schema v1</div></div>
    <div class="card metric"><div class="metric-label">Draft revision</div><div class="metric-value">{{ $entry->revision }}</div><div class="metric-note">Concurrency protected</div></div>
    <div class="card metric"><div class="metric-label">Live revision</div><div class="metric-value">{{ $entry->published_revision ?? '—' }}</div><div class="metric-note">{{ $hasPublished ? 'Published manifest' : 'Not published yet' }}</div></div>
    <div class="card metric"><div class="metric-label">State</div><div class="metric-value" style="font-size:20px">{{ ! $hasPublished ? 'Draft only' : ($hasChanges ? 'Changed' : 'Published') }}</div><div class="metric-note">{{ $hasChanges ? 'Publish required' : 'Revision safe' }}</div></div>
</div>

<form method="post" action="{{ route('admin.content.home.layout.update') }}" class="section-space">
    @csrf
    @method('PATCH')
    <input type="hidden" name="revision" value="{{ $entry->revision }}">

    <div class="grid two">
        <section class="card">
            <p class="eyebrow">MODULE MANIFEST</p>
            <h2>Order & visibility</h2>
            <p class="muted">Use each position 1–5 exactly once. Hero and Collection are protected core modules and cannot be hidden.</p>
            <div class="stack section-space">
                @foreach ($labels as $id => $definition)
                    @php
                        [$label, $description, $required] = $definition;
                        $section = $draftSections[$id];
                    @endphp
                    <div class="locked" style="display:grid;grid-template-columns:minmax(0,1fr) 96px 130px;gap:12px;align-items:center">
                        <div>
                            <strong style="font-size:14px;color:#003366">{{ $label }}</strong>
                            <div class="muted" style="font-size:12px;margin-top:4px">{{ $description }}</div>
                            <code>{{ $id }}</code>
                        </div>
                        <div class="field">
                            <label for="order_{{ $id }}">Position</label>
                            <input id="order_{{ $id }}" name="order[{{ $id }}]" type="number" min="1" max="5" value="{{ old('order.'.$id, $orderById[$id]) }}" required>
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
        </section>

        <aside class="card">
            <p class="eyebrow">SAFE DISPLAY COPY</p>
            <h2>Section headings</h2>
            <div class="stack section-space">
                <div class="field"><label for="collection_eyebrow">Collection eyebrow · max 80</label><input id="collection_eyebrow" name="collection_eyebrow" maxlength="80" value="{{ old('collection_eyebrow', $draftSections['collection']['eyebrow']) }}" required></div>
                <div class="field"><label for="collection_title">Collection heading · max 120</label><input id="collection_title" name="collection_title" maxlength="120" value="{{ old('collection_title', $draftSections['collection']['title']) }}" required></div>
                <div class="field"><label for="small_changes_title">Editorial heading · max 120</label><textarea id="small_changes_title" name="small_changes_title" maxlength="120" required>{{ old('small_changes_title', $draftSections['small_changes']['title']) }}</textarea></div>
                <div class="field"><label for="small_changes_body">Editorial body · max 300</label><textarea id="small_changes_body" name="small_changes_body" maxlength="300" required>{{ old('small_changes_body', $draftSections['small_changes']['body']) }}</textarea></div>
                <button class="btn navy" type="submit">Save private layout draft</button>
            </div>
        </aside>
    </div>
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
        <h2>Publish Home layout</h2>
        <p class="muted">Publishing snapshots this exact typed manifest. Compatible clients validate it again and fall back to last-known-good or bundled layout if anything is incompatible.</p>
        <div class="status-row"><div><strong>Live manifest</strong><div class="muted">{{ $hasPublished ? 'Revision '.$entry->published_revision : 'No published layout yet' }}</div></div><span class="badge {{ $hasPublished && ! $hasChanges ? 'good' : 'warn' }}">{{ ! $hasPublished ? 'NOT LIVE' : ($hasChanges ? 'CHANGES WAITING' : 'CURRENT') }}</span></div>
        <form method="post" action="{{ route('admin.content.home.layout.publish') }}" class="section-space">
            @csrf
            <input type="hidden" name="revision" value="{{ $entry->revision }}">
            <button class="btn primary" type="submit">Publish Home layout</button>
        </form>
        <div class="locked section-space"><small>Execution boundary</small><strong>Remote data can order/hide only known components. It cannot create arbitrary widgets, navigation code, URLs, HTML or JavaScript.</strong></div>
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
                            <form method="post" action="{{ route('admin.content.home.layout.restore') }}">
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
