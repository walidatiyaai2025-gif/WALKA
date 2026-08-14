@extends('admin.layout')

@section('title', 'Maintenance Notice · WALKA Admin')
@section('topbar', 'Operational notice')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">CMS-044 · SAFE CUSTOMER NOTICE</p>
        <h1>Maintenance / customer notice</h1>
        <p class="lead">Publish bounded informational copy with an optional UTC window. This surface cannot author HTML, executable code, arbitrary links, Product Master facts or commerce destinations.</p>
    </div>
    <a class="btn secondary" href="{{ route('admin.content.index') }}">← Mobile content</a>
</div>

<div class="grid two">
    <section class="card">
        <p class="eyebrow">PRIVATE DRAFT</p>
        <h2>Notice content</h2>
        <form method="post" action="{{ route('admin.content.maintenance.update') }}" class="stack">
            @csrf
            @method('PATCH')
            <input type="hidden" name="revision" value="{{ $entry->revision }}">
            <label class="status-row"><span><strong>Enabled</strong><span class="muted">Compatible clients render only inside the UTC window.</span></span><input type="checkbox" name="enabled" value="1" @checked(old('enabled', $draft['enabled']))></label>
            <div class="field"><label for="severity">Severity</label><select id="severity" name="severity"><option value="info" @selected(old('severity', $draft['severity']) === 'info')>Info</option><option value="warning" @selected(old('severity', $draft['severity']) === 'warning')>Warning</option><option value="maintenance" @selected(old('severity', $draft['severity']) === 'maintenance')>Maintenance</option></select></div>
            <div class="field"><label for="title">Headline</label><input id="title" name="title" maxlength="140" value="{{ old('title', $draft['title']) }}" required></div>
            <div class="field"><label for="body">Body</label><textarea id="body" name="body" maxlength="700" required>{{ old('body', $draft['body']) }}</textarea></div>
            <div class="grid two">
                <div class="field"><label for="starts_at">Starts at · UTC</label><input id="starts_at" type="datetime-local" name="starts_at" value="{{ old('starts_at', $draft['starts_at'] ? \Carbon\CarbonImmutable::parse($draft['starts_at'])->utc()->format('Y-m-d\\TH:i') : '') }}"></div>
                <div class="field"><label for="ends_at">Ends at · UTC</label><input id="ends_at" type="datetime-local" name="ends_at" value="{{ old('ends_at', $draft['ends_at'] ? \Carbon\CarbonImmutable::parse($draft['ends_at'])->utc()->format('Y-m-d\\TH:i') : '') }}"></div>
            </div>
            <button class="btn navy" type="submit">Save notice draft</button>
        </form>
    </section>

    <aside class="card">
        <p class="eyebrow">PUBLICATION GATE</p>
        <h2>Live state</h2>
        <div class="status-row"><strong>Draft revision</strong><span class="badge lock">#{{ $entry->revision }}</span></div>
        <div class="status-row"><strong>Published revision</strong><span class="badge {{ $entry->published_revision ? 'good' : 'warn' }}">{{ $entry->published_revision ? '#'.$entry->published_revision : 'NOT LIVE' }}</span></div>
        <form method="post" action="{{ route('admin.content.maintenance.publish') }}" class="section-space">@csrf<input type="hidden" name="revision" value="{{ $entry->revision }}"><button class="btn primary" type="submit">Publish validated notice</button></form>
        <div class="locked section-space"><small>Compiled boundary</small><strong>No URL/action field exists. Compatible clients keep essential navigation compiled and available.</strong></div>
    </aside>
</div>

@if ($published)
<section class="card section-space"><p class="eyebrow">LIVE SNAPSHOT</p><h2>{{ $published['title'] }}</h2><p>{{ $published['body'] }}</p><div class="muted">{{ strtoupper($published['severity']) }} · {{ $published['starts_at'] ?? 'no start' }} → {{ $published['ends_at'] ?? 'no end' }}</div></section>
@endif

<section class="card section-space">
    <p class="eyebrow">IMMUTABLE HISTORY</p><h2>Revision timeline</h2>
    <div class="table-wrap"><table><thead><tr><th>Revision</th><th>Action</th><th>Created</th><th>Recovery</th></tr></thead><tbody>
    @foreach ($entry->revisions as $revision)
        <tr><td>#{{ $revision->revision }}</td><td>{{ str_replace('_', ' ', strtoupper($revision->action)) }}</td><td>{{ $revision->created_at?->format('Y-m-d H:i:s') }}</td><td>@if ($revision->payload !== $entry->draft_payload)<form method="post" action="{{ route('admin.content.maintenance.restore') }}">@csrf<input type="hidden" name="revision" value="{{ $entry->revision }}"><input type="hidden" name="source_revision" value="{{ $revision->revision }}"><button class="btn secondary" type="submit">Restore to draft</button></form>@else<span class="badge lock">CURRENT DRAFT</span>@endif</td></tr>
    @endforeach
    </tbody></table></div>
</section>
@endsection
