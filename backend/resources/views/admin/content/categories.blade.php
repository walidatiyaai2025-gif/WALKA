@extends('admin.layout')

@section('title', 'Categories · WALKA Admin')
@section('topbar', 'Categories')

@section('content')
@php
    $hasPublished = $entry->published_revision !== null;
    $hasChanges = $hasPublished && $entry->draft_payload !== $entry->published_payload;
    $visibleCount = collect($draft['categories'])->where('visible', true)->count();
@endphp

<div class="page-head">
    <div>
        <p class="eyebrow">DISCOVERY PRESENTATION</p>
        <h1>Categories</h1>
        <p class="lead">Control customer-facing category names, descriptions, order and discovery visibility. Category identities and product membership come from the current Dashboard Catalog, and newly-created visible categories appear here automatically.</p>
    </div>
    <a class="btn secondary" href="{{ route('admin.content.index') }}">← Mobile content</a>
</div>

<div class="grid metrics">
    <div class="card metric"><div class="metric-label">Stable key</div><div class="metric-value" style="font-size:18px">categories.presentation</div><div class="metric-note">Typed schema v1</div></div>
    <div class="card metric"><div class="metric-label">Draft revision</div><div class="metric-value">{{ $entry->revision }}</div><div class="metric-note">Concurrency protected</div></div>
    <div class="card metric"><div class="metric-label">Visible</div><div class="metric-value">{{ $visibleCount }}/{{ count($draft['categories']) }}</div><div class="metric-note">At least one required</div></div>
    <div class="card metric"><div class="metric-label">Live revision</div><div class="metric-value">{{ $entry->published_revision ?? '—' }}</div><div class="metric-note">{{ ! $hasPublished ? 'Not published' : ($hasChanges ? 'Draft differs' : 'Current') }}</div></div>
</div>

<div class="grid two section-space">
    <section class="card">
        <p class="eyebrow">PRIVATE DRAFT</p>
        <h2>Category presentation</h2>
        <p class="muted">Position controls discovery order. Hiding a category removes it only from the Categories/Collections discovery surface; Catalog membership itself is managed in Catalog.</p>

        <form method="post" action="{{ route('admin.content.categories.update') }}" class="stack section-space">
            @csrf
            @method('PATCH')
            <input type="hidden" name="revision" value="{{ $entry->revision }}">

            @foreach ($draft['categories'] as $index => $category)
                <div class="card" style="background:#f8fafb;border-color:#dbe4ea">
                    <input type="hidden" name="categories[{{ $index }}][id]" value="{{ $category['id'] }}">
                    <input type="hidden" name="categories[{{ $index }}][visible]" value="0">
                    <div class="status-row">
                        <div>
                            <small>CATALOG CATEGORY ID</small>
                            <strong><code>{{ $category['id'] }}</code></strong>
                            <div class="muted">{{ $productCounts[$category['id']] ?? 0 }} public products currently derive from the Dashboard Catalog.</div>
                        </div>
                        <label style="display:flex;align-items:center;gap:8px;font-weight:800">
                            <input type="checkbox" name="categories[{{ $index }}][visible]" value="1" @checked((bool) old('categories.'.$index.'.visible', $category['visible']))>
                            Visible
                        </label>
                    </div>

                    <div class="grid two section-space">
                        <div class="field">
                            <label for="position_{{ $index }}">Position</label>
                            <select id="position_{{ $index }}" name="categories[{{ $index }}][position]" required style="width:100%;border:1px solid #ccd8e1;border-radius:11px;background:#fff;padding:11px 12px;color:#102235">
                                @for ($position = 1; $position <= count($draft['categories']); $position++)
                                    <option value="{{ $position }}" @selected((int) old('categories.'.$index.'.position', $index + 1) === $position)>{{ $position }}</option>
                                @endfor
                            </select>
                        </div>
                        <div class="field">
                            <label for="display_name_{{ $index }}">Display name</label>
                            <input id="display_name_{{ $index }}" name="categories[{{ $index }}][display_name]" maxlength="80" value="{{ old('categories.'.$index.'.display_name', $category['display_name']) }}" required>
                        </div>
                    </div>
                    <div class="field">
                        <label for="description_{{ $index }}">Short description</label>
                        <textarea id="description_{{ $index }}" name="categories[{{ $index }}][description]" maxlength="240" required>{{ old('categories.'.$index.'.description', $category['description']) }}</textarea>
                    </div>
                </div>
            @endforeach

            <button class="btn navy" type="submit">Save private category draft</button>
        </form>
    </section>

    <aside class="card">
        <p class="eyebrow">DISCOVERY PREVIEW</p>
        <h2>Published-style order</h2>
        <div class="stack section-space">
            @foreach ($draft['categories'] as $index => $category)
                <div style="padding:16px;border-radius:18px;background:#F7F4EC;opacity:{{ $category['visible'] ? '1' : '.52' }}">
                    <div style="display:flex;justify-content:space-between;gap:12px;align-items:flex-start">
                        <div>
                            <small style="font-weight:900;color:#D4AF37;letter-spacing:.8px">POSITION {{ $index + 1 }}</small>
                            <div style="font-family:serif;font-size:22px;font-weight:700;color:#003366;margin-top:4px">{{ $category['display_name'] }}</div>
                            <p style="color:#607080;line-height:1.45;margin:6px 0 0">{{ $category['description'] }}</p>
                        </div>
                        <span class="badge {{ $category['visible'] ? 'good' : 'lock' }}">{{ $category['visible'] ? 'VISIBLE' : 'HIDDEN' }}</span>
                    </div>
                </div>
            @endforeach
        </div>

        <div class="locked section-space">
            <small>Catalog boundary</small>
            <strong>Stable category IDs and product-to-category membership come from Dashboard Catalog. This editor controls presentation only and cannot inject URLs, HTML or executable UI.</strong>
        </div>

        <form method="post" action="{{ route('admin.content.categories.publish') }}" class="section-space">
            @csrf
            <input type="hidden" name="revision" value="{{ $entry->revision }}">
            <button class="btn primary" type="submit">Publish Categories</button>
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
                            <form method="post" action="{{ route('admin.content.categories.restore') }}">
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
