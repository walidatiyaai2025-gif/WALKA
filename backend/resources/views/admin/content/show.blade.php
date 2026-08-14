@extends('admin.layout')

@section('title', $entry->content_key.' · WALKA Admin')
@section('topbar', 'Content workspace')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">DRAFT · DIFF · SCHEDULE · PUBLISH · ROLLBACK</p>
        <h1>{{ $entry->content_key }}</h1>
        <p class="lead">Edit the draft, inspect a deterministic non-executable diff, optionally schedule publication in UTC, then publish explicitly. Historical restore always creates a new draft.</p>
    </div>
    <a class="btn secondary" href="{{ route('admin.content.index') }}">← All content</a>
</div>

@php
    $hasPublished = $entry->published_revision !== null;
    $hasChanges = $hasPublished && $entry->draft_payload !== $entry->published_payload;
    $hasSchedule = $entry->scheduled_publish_at || $entry->scheduled_unpublish_at;
    $scheduleCurrent = $hasSchedule && $entry->schedule_revision === $entry->revision;
@endphp

<div class="grid metrics">
    <div class="card metric"><div class="metric-label">Content type</div><div class="metric-value" style="font-size:20px">{{ $entry->content_type }}</div><div class="metric-note">Immutable type</div></div>
    <div class="card metric"><div class="metric-label">Current revision</div><div class="metric-value">{{ $entry->revision }}</div><div class="metric-note">Optimistic concurrency token</div></div>
    <div class="card metric"><div class="metric-label">Published revision</div><div class="metric-value">{{ $entry->published_revision ?? '—' }}</div><div class="metric-note">{{ $hasPublished ? 'Last live snapshot' : 'Never published' }}</div></div>
    <div class="card metric"><div class="metric-label">Schedule</div><div class="metric-value" style="font-size:20px">{{ ! $hasSchedule ? 'None' : ($scheduleCurrent ? 'Armed' : 'Stale') }}</div><div class="metric-note">{{ $scheduleCurrent ? 'Exact revision protected' : ($hasSchedule ? 'Will not execute until rescheduled' : 'Manual publication only') }}</div></div>
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
            <div class="actions"><button class="btn navy" type="submit">Save draft</button></div>
        </form>
    </section>

    <aside class="card">
        <p class="eyebrow">PUBLICATION GATE</p>
        <h2>Publish controls</h2>
        <p class="muted">Publishing snapshots the current draft into an immutable revision. A later edit stays private until the next explicit or scheduled publish.</p>
        <div class="status-row">
            <div><strong>Live state</strong><div class="muted">{{ $hasPublished ? 'Revision '.$entry->published_revision : 'No public snapshot yet' }}</div></div>
            @if (! $hasPublished)<span class="badge warn">NOT LIVE</span>@elseif ($hasChanges)<span class="badge warn">CHANGES WAITING</span>@else<span class="badge good">CURRENT</span>@endif
        </div>
        <form method="post" action="{{ route('admin.content.publish', ['content' => $entry->id]) }}" class="section-space">
            @csrf
            <input type="hidden" name="revision" value="{{ $entry->revision }}">
            <button class="btn primary" type="submit">Publish current draft</button>
        </form>

        <div class="section-space" style="border-top:1px solid #edf1f4;padding-top:18px">
            <p class="eyebrow">CMS-050 · UTC SCHEDULE</p>
            <form method="post" action="{{ route('admin.content.schedule', ['content' => $entry->id]) }}" class="stack">
                @csrf
                <input type="hidden" name="revision" value="{{ $entry->revision }}">
                <div class="field"><label for="scheduled_publish_at">Publish at · UTC</label><input id="scheduled_publish_at" type="datetime-local" name="scheduled_publish_at" value="{{ old('scheduled_publish_at', $entry->scheduled_publish_at?->utc()->format('Y-m-d\\TH:i')) }}"></div>
                <div class="field"><label for="scheduled_unpublish_at">Unpublish at · UTC</label><input id="scheduled_unpublish_at" type="datetime-local" name="scheduled_unpublish_at" value="{{ old('scheduled_unpublish_at', $entry->scheduled_unpublish_at?->utc()->format('Y-m-d\\TH:i')) }}"></div>
                <button class="btn secondary" type="submit">Save / clear schedule</button>
            </form>
            @if ($hasSchedule)
                <div class="locked section-space"><small>Schedule revision</small><strong>#{{ $entry->schedule_revision ?? '—' }} · {{ $scheduleCurrent ? 'armed' : 'stale / fail-closed' }}</strong></div>
            @endif
        </div>
    </aside>
</div>

<section class="card section-space">
    <p class="eyebrow">CMS-051 · RICH DIFF BEFORE PUBLISH</p>
    <div class="page-head" style="margin-bottom:14px;align-items:center">
        <div><h2 style="margin-bottom:4px">Draft changes</h2><p class="muted">Compared with {{ $diffBaseLabel }}. Sensitive/admin-only key names are excluded and values are rendered as text, never executed.</p></div>
        @if ($compareRevision)<a class="btn secondary" href="{{ route('admin.content.show', ['content' => $entry->id]) }}">Compare to live</a>@endif
    </div>
    @if ($diffRows === [])
        <div class="locked"><strong>No differences.</strong><p class="muted">The selected comparison snapshot matches the current draft.</p></div>
    @else
        <div class="table-wrap"><table><thead><tr><th>Path</th><th>State</th><th>Before</th><th>After</th></tr></thead><tbody>
        @foreach ($diffRows as $row)
            <tr>
                <td><code>{{ $row['path'] }}</code></td>
                <td><span class="badge {{ $row['state'] === 'added' ? 'good' : ($row['state'] === 'removed' ? 'warn' : 'lock') }}">{{ strtoupper($row['state']) }}</span></td>
                <td><code>{{ is_scalar($row['before']) || $row['before'] === null ? var_export($row['before'], true) : json_encode($row['before'], JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE) }}</code></td>
                <td><code>{{ is_scalar($row['after']) || $row['after'] === null ? var_export($row['after'], true) : json_encode($row['after'], JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE) }}</code></td>
            </tr>
        @endforeach
        </tbody></table></div>
    @endif
</section>

<section class="card section-space">
    <p class="eyebrow">PREVIEW</p>
    <h2>Draft vs published snapshot</h2>
    <div class="preview-grid">
        <div><div class="preview-label">DRAFT · rev {{ $entry->revision }}</div><pre class="json-preview">{{ $draftJson }}</pre></div>
        <div><div class="preview-label">PUBLISHED · {{ $entry->published_revision ? 'rev '.$entry->published_revision : 'none' }}</div><pre class="json-preview">{{ $publishedJson ?? 'No published snapshot yet.' }}</pre></div>
    </div>
</section>

<section class="card section-space">
    <p class="eyebrow">IMMUTABLE HISTORY</p>
    <h2>Revision timeline</h2>
    <div class="table-wrap">
        <table><thead><tr><th>Revision</th><th>Action</th><th>Source</th><th>Created</th><th>Compare</th><th>Recovery</th></tr></thead><tbody>
        @foreach ($entry->revisions as $revision)
            <tr>
                <td><strong>#{{ $revision->revision }}</strong></td>
                <td>{{ str_replace('_', ' ', strtoupper($revision->action)) }}</td>
                <td>{{ $revision->source_revision ? '#'.$revision->source_revision : '—' }}</td>
                <td>{{ $revision->created_at?->format('Y-m-d H:i:s') }}</td>
                <td><a class="btn secondary" href="{{ route('admin.content.show', ['content' => $entry->id, 'compare_revision' => $revision->revision]) }}">Diff</a></td>
                <td>@if ($revision->payload !== $entry->draft_payload)<form method="post" action="{{ route('admin.content.restore', ['content' => $entry->id]) }}">@csrf<input type="hidden" name="revision" value="{{ $entry->revision }}"><input type="hidden" name="source_revision" value="{{ $revision->revision }}"><button class="btn secondary" type="submit">Restore to draft</button></form>@else<span class="badge lock">CURRENT DRAFT</span>@endif</td>
            </tr>
        @endforeach
        </tbody></table>
    </div>
</section>
@endsection
