@extends('admin.layout')

@section('title', $entry->content_key.' · WALKA Admin')
@section('topbar', 'Content workspace')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">DRAFT · PREVIEW · PUBLISH · ROLLBACK</p>
        <h1>{{ $entry->content_key }}</h1>
        <p class="lead">Edit the draft, compare it with the published snapshot, then publish explicitly. Restoring history always creates a new draft and never silently changes the live snapshot.</p>
    </div>
    <a class="btn secondary" href="{{ route('admin.content.index') }}">← All content</a>
</div>

@php
    $hasPublished = $entry->published_revision !== null;
    $hasChanges = $hasPublished && $entry->draft_payload !== $entry->published_payload;
@endphp

<div class="grid metrics">
    <div class="card metric"><div class="metric-label">Content type</div><div class="metric-value" style="font-size:20px">{{ $entry->content_type }}</div><div class="metric-note">Immutable type</div></div>
    <div class="card metric"><div class="metric-label">Current revision</div><div class="metric-value">{{ $entry->revision }}</div><div class="metric-note">Optimistic concurrency token</div></div>
    <div class="card metric"><div class="metric-label">Published revision</div><div class="metric-value">{{ $entry->published_revision ?? '—' }}</div><div class="metric-note">{{ $hasPublished ? 'Last live snapshot' : 'Never published' }}</div></div>
    <div class="card metric"><div class="metric-label">State</div><div class="metric-value" style="font-size:20px">{{ ! $hasPublished ? 'Draft only' : ($hasChanges ? 'Changed' : 'Published') }}</div><div class="metric-note">{{ $hasChanges ? 'Review before publish' : 'Revision-safe' }}</div></div>
</div>

<div class="grid two section-space">
    <section class="card">
        <p class="eyebrow">AUTHORING</p>
        <h2>Draft editor</h2>
        <form method="post" action="{{ route('admin.content.draft.update', ['content' => $entry->id]) }}" class="stack">
            @csrf
            @method('PATCH')
            <input type="hidden" name="revision" value="{{ $entry->revision }}">
            <div class="field">
                <label for="payload_json">Structured JSON draft</label>
                <textarea id="payload_json" name="payload_json" class="json-editor" spellcheck="false" required>{{ old('payload_json', $draftJson) }}</textarea>
            </div>
            <div class="actions">
                <button class="btn navy" type="submit">Save draft</button>
            </div>
        </form>
    </section>

    <aside class="card">
        <p class="eyebrow">PUBLICATION GATE</p>
        <h2>Publish controls</h2>
        <p class="muted">Publishing snapshots the current draft into an immutable revision. A later edit stays private until the next explicit publish.</p>
        <div class="status-row">
            <div><strong>Live state</strong><div class="muted">{{ $hasPublished ? 'Revision '.$entry->published_revision : 'No public snapshot yet' }}</div></div>
            @if (! $hasPublished)
                <span class="badge warn">NOT LIVE</span>
            @elseif ($hasChanges)
                <span class="badge warn">CHANGES WAITING</span>
            @else
                <span class="badge good">CURRENT</span>
            @endif
        </div>
        <form method="post" action="{{ route('admin.content.publish', ['content' => $entry->id]) }}" class="section-space">
            @csrf
            <input type="hidden" name="revision" value="{{ $entry->revision }}">
            <button class="btn primary" type="submit">Publish current draft</button>
        </form>
        <div class="locked section-space">
            <small>Public API boundary</small>
            <strong>CMS-002 does not expose content to Flutter yet. CMS-003 adds the versioned public content envelope and mobile cache/fallback contract.</strong>
        </div>
    </aside>
</div>

<section class="card section-space">
    <p class="eyebrow">PREVIEW</p>
    <h2>Draft vs published snapshot</h2>
    <div class="preview-grid">
        <div>
            <div class="preview-label">DRAFT · rev {{ $entry->revision }}</div>
            <pre class="json-preview">{{ $draftJson }}</pre>
        </div>
        <div>
            <div class="preview-label">PUBLISHED · {{ $entry->published_revision ? 'rev '.$entry->published_revision : 'none' }}</div>
            <pre class="json-preview">{{ $publishedJson ?? 'No published snapshot yet.' }}</pre>
        </div>
    </div>
</section>

<section class="card section-space">
    <p class="eyebrow">IMMUTABLE HISTORY</p>
    <h2>Revision timeline</h2>
    <div class="table-wrap">
        <table>
            <thead>
            <tr><th>Revision</th><th>Action</th><th>Source</th><th>Created</th><th>Recovery</th></tr>
            </thead>
            <tbody>
            @foreach ($entry->revisions as $revision)
                <tr>
                    <td><strong>#{{ $revision->revision }}</strong></td>
                    <td>{{ str_replace('_', ' ', strtoupper($revision->action)) }}</td>
                    <td>{{ $revision->source_revision ? '#'.$revision->source_revision : '—' }}</td>
                    <td>{{ $revision->created_at?->format('Y-m-d H:i:s') }}</td>
                    <td>
                        @if ($revision->payload !== $entry->draft_payload)
                            <form method="post" action="{{ route('admin.content.restore', ['content' => $entry->id]) }}">
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
