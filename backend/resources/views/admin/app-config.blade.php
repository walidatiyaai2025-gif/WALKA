@extends('admin.layout')

@section('title', 'App Config · WALKA Admin')
@section('topbar', 'App Config')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">CMS-045 · COMPILED PRESENTATION SWITCHES</p>
        <h1>Safe App Config</h1>
        <p class="lead">Toggle only released presentation switches. Flag IDs are compiled in Laravel and Flutter; security, authentication, secrets, Product Master, commerce and executable behavior are not remotely authorable.</p>
    </div>
    <a class="btn secondary" href="{{ route('admin.content.index') }}">← Mobile content</a>
</div>

<div class="grid two">
    <section class="card">
        <p class="eyebrow">PRIVATE DRAFT</p><h2>Presentation switches</h2>
        <form method="post" action="{{ route('admin.app-config.update') }}" class="stack">
            @csrf
            @method('PATCH')
            <input type="hidden" name="revision" value="{{ $entry->revision }}">
            @foreach ($flagIds as $flag)
                <label class="status-row">
                    <span><strong>{{ str_replace('_', ' ', strtoupper($flag)) }}</strong><span class="muted">Compiled ID · unknown flags are rejected.</span></span>
                    <input type="checkbox" name="flags[{{ $flag }}]" value="1" @checked(old('flags.'.$flag, $draft['flags'][$flag]))>
                </label>
            @endforeach
            <button class="btn navy" type="submit">Save App Config draft</button>
        </form>
    </section>

    <aside class="card">
        <p class="eyebrow">PUBLICATION GATE</p><h2>Live state</h2>
        <div class="status-row"><strong>Draft revision</strong><span class="badge lock">#{{ $entry->revision }}</span></div>
        <div class="status-row"><strong>Published revision</strong><span class="badge {{ $entry->published_revision ? 'good' : 'warn' }}">{{ $entry->published_revision ? '#'.$entry->published_revision : 'NOT LIVE' }}</span></div>
        <form method="post" action="{{ route('admin.app-config.publish') }}" class="section-space">@csrf<input type="hidden" name="revision" value="{{ $entry->revision }}"><button class="btn primary" type="submit">Publish App Config</button></form>
        <div class="locked section-space"><small>Fail-safe contract</small><strong>Missing or incompatible remote config falls back to bundled Flutter defaults. Remote values cannot create new behavior.</strong></div>
    </aside>
</div>

@if ($published)
<section class="card section-space"><p class="eyebrow">LIVE FLAGS</p><h2>Published snapshot</h2>@foreach ($flagIds as $flag)<div class="status-row"><strong>{{ $flag }}</strong><span class="badge {{ $published['flags'][$flag] ? 'good' : 'lock' }}">{{ $published['flags'][$flag] ? 'ON' : 'OFF' }}</span></div>@endforeach</section>
@endif

<section class="card section-space">
    <p class="eyebrow">IMMUTABLE HISTORY</p><h2>Revision timeline</h2>
    <div class="table-wrap"><table><thead><tr><th>Revision</th><th>Action</th><th>Created</th><th>Recovery</th></tr></thead><tbody>
    @foreach ($entry->revisions as $revision)
        <tr><td>#{{ $revision->revision }}</td><td>{{ str_replace('_', ' ', strtoupper($revision->action)) }}</td><td>{{ $revision->created_at?->format('Y-m-d H:i:s') }}</td><td>@if ($revision->payload !== $entry->draft_payload)<form method="post" action="{{ route('admin.app-config.restore') }}">@csrf<input type="hidden" name="revision" value="{{ $entry->revision }}"><input type="hidden" name="source_revision" value="{{ $revision->revision }}"><button class="btn secondary" type="submit">Restore to draft</button></form>@else<span class="badge lock">CURRENT DRAFT</span>@endif</td></tr>
    @endforeach
    </tbody></table></div>
</section>
@endsection
