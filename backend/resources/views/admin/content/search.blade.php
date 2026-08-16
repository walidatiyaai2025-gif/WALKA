@extends('admin.layout')

@section('title', 'Search · WALKA Admin')
@section('topbar', 'Search')

@section('content')
@php
    $hasPublished = $entry->published_revision !== null;
    $hasChanges = $hasPublished && $entry->draft_payload !== $entry->published_payload;
@endphp

<div class="page-head">
    <div>
        <p class="eyebrow">SEARCH / DISCOVERY</p>
        <h1>Search presentation</h1>
        <p class="lead">Control Search copy, filter labels and default merchandising order. Product, Variant and Category membership comes from the current Dashboard Catalog automatically.</p>
    </div>
    <a class="btn secondary" href="{{ route('admin.content.index') }}">← Mobile content</a>
</div>

<div class="grid metrics">
    <div class="card metric"><div class="metric-label">Stable key</div><div class="metric-value" style="font-size:18px">search.presentation</div><div class="metric-note">Typed schema v1</div></div>
    <div class="card metric"><div class="metric-label">Draft revision</div><div class="metric-value">{{ $entry->revision }}</div><div class="metric-note">Concurrency protected</div></div>
    <div class="card metric"><div class="metric-label">Visible variants</div><div class="metric-value">{{ count($draft['featured_variant_ids']) }}</div><div class="metric-note">Generated from Dashboard Catalog</div></div>
    <div class="card metric"><div class="metric-label">Live revision</div><div class="metric-value">{{ $entry->published_revision ?? '—' }}</div><div class="metric-note">{{ ! $hasPublished ? 'Not published' : ($hasChanges ? 'Draft differs' : 'Current') }}</div></div>
</div>

<div class="grid two section-space">
    <section class="card">
        <p class="eyebrow">PRIVATE DRAFT</p>
        <h2>Customer-facing Search copy</h2>
        <form method="post" action="{{ route('admin.content.search.update') }}" class="stack section-space">
            @csrf
            @method('PATCH')
            <input type="hidden" name="revision" value="{{ $entry->revision }}">

            <div class="field">
                <label for="heading">Heading</label>
                <input id="heading" name="heading" maxlength="80" value="{{ old('heading', $draft['heading']) }}" required>
            </div>
            <div class="field">
                <label for="supporting_copy">Supporting copy</label>
                <textarea id="supporting_copy" name="supporting_copy" maxlength="240" required>{{ old('supporting_copy', $draft['supporting_copy']) }}</textarea>
            </div>
            <div class="field">
                <label for="placeholder">Search field placeholder</label>
                <input id="placeholder" name="placeholder" maxlength="100" value="{{ old('placeholder', $draft['placeholder']) }}" required>
            </div>
            <div class="grid two">
                <div class="field">
                    <label for="empty_title">Empty-state title</label>
                    <input id="empty_title" name="empty_title" maxlength="100" value="{{ old('empty_title', $draft['empty_title']) }}" required>
                </div>
                <div class="field">
                    <label for="empty_body">Empty-state body</label>
                    <textarea id="empty_body" name="empty_body" maxlength="240" required>{{ old('empty_body', $draft['empty_body']) }}</textarea>
                </div>
            </div>

            <div class="section-space">
                <p class="eyebrow">DEFAULT FEATURED ORDER</p>
                <p class="muted">Current visible Dashboard variants are offered automatically and newly-created variants append without a code change. This order affects default merchandising only; Search matching still uses the complete visible Catalog.</p>
                @foreach ($draft['featured_variant_ids'] as $index => $variantId)
                    @php($variant = $variants[$variantId] ?? null)
                    <div class="card" style="background:#f8fafb;border-color:#dbe4ea;margin-top:12px">
                        <input type="hidden" name="variants[{{ $index }}][id]" value="{{ $variantId }}">
                        <div class="status-row">
                            <div>
                                <small>DASHBOARD VARIANT ID</small>
                                <strong><code>{{ $variantId }}</code></strong>
                                <div class="muted">{{ $variant?->product?->name ?? 'Dashboard product' }} · {{ $variant?->color ?? '' }}</div>
                            </div>
                            <div class="field" style="min-width:120px">
                                <label for="position_{{ $index }}">Position</label>
                                <select id="position_{{ $index }}" name="variants[{{ $index }}][position]" required>
                                    @for ($position = 1; $position <= count($draft['featured_variant_ids']); $position++)
                                        <option value="{{ $position }}" @selected((int) old('variants.'.$index.'.position', $index + 1) === $position)>{{ $position }}</option>
                                    @endfor
                                </select>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>

            <div class="section-space">
                <p class="eyebrow">FILTER LABELS</p>
                <p class="muted">Category filters are generated from the current visible Dashboard Categories. This editor changes their customer-facing labels; it does not invent or delete Catalog identities.</p>
                @foreach ($draft['filter_labels'] as $index => $filter)
                    <div class="grid two" style="margin-top:12px">
                        <div class="field">
                            <label>Dashboard filter ID</label>
                            <input value="{{ $filter['id'] }}" disabled>
                            <input type="hidden" name="filter_labels[{{ $index }}][id]" value="{{ $filter['id'] }}">
                        </div>
                        <div class="field">
                            <label for="filter_label_{{ $index }}">Display label</label>
                            <input id="filter_label_{{ $index }}" name="filter_labels[{{ $index }}][label]" maxlength="40" value="{{ old('filter_labels.'.$index.'.label', $filter['label']) }}" required>
                        </div>
                    </div>
                @endforeach
            </div>

            <button class="btn navy" type="submit">Save private Search draft</button>
        </form>
    </section>

    <aside class="card">
        <p class="eyebrow">SEARCH PREVIEW</p>
        <h2>{{ $draft['heading'] }}</h2>
        <p class="muted">{{ $draft['supporting_copy'] }}</p>
        <div class="field section-space">
            <label>Search field preview</label>
            <input value="{{ $draft['placeholder'] }}" disabled>
        </div>
        <div class="section-space">
            <small>FILTERS</small>
            <div style="display:flex;gap:8px;flex-wrap:wrap;margin-top:8px">
                @foreach ($draft['filter_labels'] as $filter)
                    <span class="badge lock">{{ $filter['label'] }}</span>
                @endforeach
            </div>
        </div>
        <div class="section-space">
            <small>FEATURED ORDER</small>
            <ol>
                @foreach ($draft['featured_variant_ids'] as $variantId)
                    <li style="margin-top:8px"><code>{{ $variantId }}</code></li>
                @endforeach
            </ol>
        </div>
        <div class="locked section-space">
            <small>Governed boundary</small>
            <strong>Search matching and Product/Variant/Category facts are governed by Dashboard Catalog. ASIN, Pantone and Amazon routing remain edited at their governed Catalog/commerce sources, not in Search presentation.</strong>
        </div>
        <form method="post" action="{{ route('admin.content.search.publish') }}" class="section-space">
            @csrf
            <input type="hidden" name="revision" value="{{ $entry->revision }}">
            <button class="btn primary" type="submit">Publish Search</button>
        </form>
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
                            <form method="post" action="{{ route('admin.content.search.restore') }}">
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
