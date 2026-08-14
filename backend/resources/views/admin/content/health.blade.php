@extends('admin.layout')

@section('title', 'Content health · WALKA Admin')
@section('topbar', 'Content operations')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">CMS-053 · OBSERVABILITY</p>
        <h1>Content publication health</h1>
        <p class="lead">Read-only operational view of governed content revisions, publication age, cache metadata and schedule state. Payloads, drafts, credentials and secrets are intentionally excluded.</p>
    </div>
    <div class="actions">
        <a class="btn secondary" href="{{ route('admin.content.health.json') }}">JSON health</a>
        <a class="btn secondary" href="{{ route('admin.content.index') }}">← Content</a>
    </div>
</div>

<div class="grid metrics">
    <div class="card metric"><div class="metric-label">Entries</div><div class="metric-value">{{ $report['summary']['total'] }}</div><div class="metric-note">Governed content records</div></div>
    <div class="card metric"><div class="metric-label">Healthy</div><div class="metric-value">{{ $report['summary']['healthy'] }}</div><div class="metric-note">Published / no stale schedule</div></div>
    <div class="card metric"><div class="metric-label">Attention</div><div class="metric-value">{{ $report['summary']['attention'] }}</div><div class="metric-note">Private-only or stale schedule</div></div>
    <div class="card metric"><div class="metric-label">Changes waiting</div><div class="metric-value">{{ $report['summary']['changes_waiting'] }}</div><div class="metric-note">Draft differs from live</div></div>
</div>

<section class="card section-space">
    <div class="page-head" style="margin-bottom:14px;align-items:center">
        <div><p class="eyebrow">GENERATED {{ $report['generated_at'] }}</p><h2>Delivery matrix</h2></div>
        @if ($report['summary']['stale_schedules'] > 0)<span class="badge warn">{{ $report['summary']['stale_schedules'] }} STALE SCHEDULE(S)</span>@else<span class="badge good">NO STALE SCHEDULES</span>@endif
    </div>
    <div class="table-wrap">
        <table><thead><tr><th>Key</th><th>Health</th><th>Current / Live</th><th>Freshness</th><th>Draft</th><th>Schedule</th><th>Delivery</th></tr></thead><tbody>
        @foreach ($report['entries'] as $row)
            <tr>
                <td><strong>{{ $row['key'] }}</strong><div class="muted">{{ $row['type'] }}</div></td>
                <td><span class="badge {{ $row['health'] === 'healthy' ? 'good' : 'warn' }}">{{ strtoupper($row['health']) }}</span></td>
                <td>#{{ $row['current_revision'] }} / {{ $row['published_revision'] ? '#'.$row['published_revision'] : '—' }}<div class="muted">{{ $row['published_at'] ?? 'never published' }}</div></td>
                <td>{{ strtoupper($row['freshness']) }}@if ($row['published_age_seconds'] !== null)<div class="muted">{{ $row['published_age_seconds'] }}s old</div>@endif</td>
                <td>{{ str_replace('_', ' ', strtoupper($row['draft_state'])) }}</td>
                <td>{{ strtoupper($row['schedule_state']) }}@if ($row['scheduled_publish_at'])<div class="muted">publish {{ $row['scheduled_publish_at'] }}</div>@endif @if ($row['scheduled_unpublish_at'])<div class="muted">unpublish {{ $row['scheduled_unpublish_at'] }}</div>@endif</td>
                <td>@if ($row['delivery'])<code>{{ $row['delivery']['etag'] }}</code><div class="muted">{{ $row['delivery']['cache_control'] }}</div>@else<span class="muted">No public delivery contract</span>@endif</td>
            </tr>
        @endforeach
        </tbody></table>
    </div>
</section>
@endsection
