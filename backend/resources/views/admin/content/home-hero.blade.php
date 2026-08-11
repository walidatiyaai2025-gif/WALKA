@extends('admin.layout')

@section('title', 'Home Hero · WALKA Admin')
@section('topbar', 'Home Hero')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">TYPED MOBILE CMS</p>
        <h1>Home Hero</h1>
        <p class="lead">Change the customer-facing Home headline and CTA labels safely from the backend. Save creates a private draft; Publish is the only action that changes what compatible WALKA clients can receive.</p>
    </div>
    <a class="btn secondary" href="{{ route('admin.content.index') }}">← Mobile content</a>
</div>

@php
    $hasPublished = $entry->published_revision !== null;
    $hasChanges = $hasPublished && $entry->draft_payload !== $entry->published_payload;
@endphp

<div class="grid metrics">
    <div class="card metric"><div class="metric-label">Stable key</div><div class="metric-value" style="font-size:20px">home.hero</div><div class="metric-note">Typed schema v1</div></div>
    <div class="card metric"><div class="metric-label">Draft revision</div><div class="metric-value">{{ $entry->revision }}</div><div class="metric-note">Concurrency protected</div></div>
    <div class="card metric"><div class="metric-label">Live revision</div><div class="metric-value">{{ $entry->published_revision ?? '—' }}</div><div class="metric-note">{{ $hasPublished ? 'Published snapshot' : 'Not published yet' }}</div></div>
    <div class="card metric"><div class="metric-label">State</div><div class="metric-value" style="font-size:20px">{{ ! $hasPublished ? 'Draft only' : ($hasChanges ? 'Changed' : 'Published') }}</div><div class="metric-note">{{ $hasChanges ? 'Publish required' : 'Revision safe' }}</div></div>
</div>

<div class="grid two section-space">
    <section class="card">
        <p class="eyebrow">AUTHORING</p>
        <h2>Customer-facing copy</h2>
        <form method="post" action="{{ route('admin.content.home.hero.update') }}" class="stack">
            @csrf
            @method('PATCH')
            <input type="hidden" name="revision" value="{{ $entry->revision }}">

            <div class="field">
                <label for="eyebrow">Eyebrow <span class="muted">· max 120</span></label>
                <textarea id="eyebrow" name="eyebrow" maxlength="120" required>{{ old('eyebrow', $draft['eyebrow']) }}</textarea>
            </div>
            <div class="field">
                <label for="title">Hero title <span class="muted">· max 160</span></label>
                <textarea id="title" name="title" maxlength="160" required>{{ old('title', $draft['title']) }}</textarea>
            </div>
            <div class="field">
                <label for="body">Supporting copy <span class="muted">· max 500</span></label>
                <textarea id="body" name="body" maxlength="500" required>{{ old('body', $draft['body']) }}</textarea>
            </div>
            <div class="grid two">
                <div class="field">
                    <label for="shop_label">Primary CTA label <span class="muted">· max 64</span></label>
                    <input id="shop_label" name="shop_label" maxlength="64" value="{{ old('shop_label', $draft['shop_label']) }}" required>
                </div>
                <div class="field">
                    <label for="search_label">Search CTA label <span class="muted">· max 64</span></label>
                    <input id="search_label" name="search_label" maxlength="64" value="{{ old('search_label', $draft['search_label']) }}" required>
                </div>
            </div>

            <div class="actions">
                <button class="btn navy" type="submit">Save private draft</button>
            </div>
        </form>
    </section>

    <aside class="card">
        <p class="eyebrow">MOBILE PREVIEW</p>
        <h2>Draft snapshot</h2>
        <div style="border:1px solid #e6dfce;background:linear-gradient(145deg,#fffefc,#f7f1e6);border-radius:18px;padding:24px;box-shadow:inset 0 0 0 1px rgba(212,175,55,.05)">
            <div style="color:#9a7a13;font-size:10px;line-height:1.5;font-weight:900;letter-spacing:.7px;white-space:pre-line">{{ $draft['eyebrow'] }}</div>
            <div style="margin-top:14px;color:#003366;font-family:Georgia,serif;font-size:34px;line-height:1;white-space:pre-line">{{ $draft['title'] }}</div>
            <p style="color:#59616a;line-height:1.55;font-size:13px">{{ $draft['body'] }}</p>
            <div style="display:grid;gap:8px;max-width:240px">
                <div class="btn primary">{{ $draft['shop_label'] }}</div>
                <div class="btn secondary">{{ $draft['search_label'] }}</div>
            </div>
        </div>

        <div class="status-row section-space">
            <div>
                <strong>Published snapshot</strong>
                <div class="muted">{{ $hasPublished ? 'Revision '.$entry->published_revision : 'No live Home Hero yet' }}</div>
            </div>
            @if (! $hasPublished)
                <span class="badge warn">NOT LIVE</span>
            @elseif ($hasChanges)
                <span class="badge warn">CHANGES WAITING</span>
            @else
                <span class="badge good">CURRENT</span>
            @endif
        </div>

        <form method="post" action="{{ route('admin.content.home.hero.publish') }}" class="section-space">
            @csrf
            <input type="hidden" name="revision" value="{{ $entry->revision }}">
            <button class="btn primary" type="submit">Publish Home Hero</button>
        </form>

        <div class="locked section-space">
            <small>What stays locked</small>
            <strong>CTA behavior/navigation stays in Flutter code. This editor controls safe display copy only; it cannot inject URLs, HTML, scripts or native behavior.</strong>
        </div>
    </aside>
</div>

<section class="card section-space">
    <p class="eyebrow">DRAFT VS LIVE</p>
    <h2>Publication comparison</h2>
    <div class="preview-grid">
        <div>
            <div class="preview-label">DRAFT · REV {{ $entry->revision }}</div>
            <pre class="json-preview">{{ json_encode($draft, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) }}</pre>
        </div>
        <div>
            <div class="preview-label">PUBLISHED · {{ $entry->published_revision ? 'REV '.$entry->published_revision : 'NONE' }}</div>
            <pre class="json-preview">{{ $published === null ? 'No published snapshot yet.' : json_encode($published, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) }}</pre>
        </div>
    </div>
</section>

<section class="card section-space">
    <p class="eyebrow">REVISION HISTORY</p>
    <h2>Restore safely</h2>
    <p class="muted">Restore never changes the live version directly. It copies the selected historical snapshot into a new draft so you can review it before publishing.</p>
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
                            <form method="post" action="{{ route('admin.content.home.hero.restore') }}">
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
