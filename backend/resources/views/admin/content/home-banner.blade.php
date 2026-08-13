@extends('admin.layout')

@section('title', 'Home Banner · WALKA Admin')
@section('topbar', 'Home Banner')

@section('content')
@php
    $hasPublished = $entry->published_revision !== null;
    $hasChanges = $hasPublished && $entry->draft_payload !== $entry->published_payload;
@endphp

<div class="page-head">
    <div>
        <p class="eyebrow">SCHEDULED ANNOUNCEMENT</p>
        <h1>Home Banner</h1>
        <p class="lead">Create one policy-safe Home announcement and control exactly when it appears. Schedule timestamps are entered and stored in UTC; compatible clients also enforce the window locally when offline.</p>
    </div>
    <a class="btn secondary" href="{{ route('admin.content.index') }}">← Mobile content</a>
</div>

<div class="grid metrics">
    <div class="card metric"><div class="metric-label">Stable key</div><div class="metric-value" style="font-size:20px">home.banner</div><div class="metric-note">Typed schema v1</div></div>
    <div class="card metric"><div class="metric-label">Draft revision</div><div class="metric-value">{{ $entry->revision }}</div><div class="metric-note">Concurrency protected</div></div>
    <div class="card metric"><div class="metric-label">Draft now</div><div class="metric-value" style="font-size:20px">{{ $draftActiveNow ? 'ACTIVE' : 'INACTIVE' }}</div><div class="metric-note">Evaluated against UTC now</div></div>
    <div class="card metric"><div class="metric-label">Live now</div><div class="metric-value" style="font-size:20px">{{ $publishedActiveNow ? 'ACTIVE' : 'INACTIVE' }}</div><div class="metric-note">{{ $hasPublished ? 'Published rev '.$entry->published_revision : 'Not published' }}</div></div>
</div>

<div class="grid two section-space">
    <section class="card">
        <p class="eyebrow">PRIVATE DRAFT</p>
        <h2>Announcement content</h2>
        <form method="post" action="{{ route('admin.content.home.banner.update') }}" class="stack section-space">
            @csrf
            @method('PATCH')
            <input type="hidden" name="revision" value="{{ $entry->revision }}">
            <input type="hidden" name="enabled" value="0">

            <label style="display:flex;align-items:center;gap:10px;font-weight:800">
                <input type="checkbox" name="enabled" value="1" @checked((bool) old('enabled', $draft['enabled']))>
                Enable this banner when its schedule is active
            </label>

            <div class="field">
                <label for="eyebrow">Eyebrow</label>
                <input id="eyebrow" name="eyebrow" maxlength="80" value="{{ old('eyebrow', $draft['eyebrow']) }}" required>
            </div>
            <div class="field">
                <label for="title">Headline</label>
                <input id="title" name="title" maxlength="140" value="{{ old('title', $draft['title']) }}" required>
            </div>
            <div class="field">
                <label for="body">Supporting copy</label>
                <textarea id="body" name="body" maxlength="320" required>{{ old('body', $draft['body']) }}</textarea>
            </div>

            <div class="grid two">
                <div class="field">
                    <label for="cta_action">CTA behavior</label>
                    <select id="cta_action" name="cta_action" required style="width:100%;border:1px solid #ccd8e1;border-radius:11px;background:#fff;padding:11px 12px;color:#102235">
                        @foreach ($actions as $action)
                            <option value="{{ $action }}" @selected(old('cta_action', $draft['cta_action']) === $action)>{{ strtoupper($action) }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="field">
                    <label for="cta_label">CTA label</label>
                    <input id="cta_label" name="cta_label" maxlength="48" value="{{ old('cta_label', $draft['cta_label']) }}" placeholder="Hidden when action = NONE">
                </div>
            </div>

            <div class="grid two">
                <div class="field">
                    <label for="starts_at">Starts at · UTC</label>
                    <input id="starts_at" type="datetime-local" name="starts_at" value="{{ old('starts_at', $draftStartsAtInput) }}">
                    <small class="muted">Leave blank for no start boundary.</small>
                </div>
                <div class="field">
                    <label for="ends_at">Ends at · UTC</label>
                    <input id="ends_at" type="datetime-local" name="ends_at" value="{{ old('ends_at', $draftEndsAtInput) }}">
                    <small class="muted">Leave blank for no end boundary.</small>
                </div>
            </div>

            <button class="btn navy" type="submit">Save private banner draft</button>
        </form>
    </section>

    <aside class="card">
        <p class="eyebrow">COMPILED MOBILE PREVIEW</p>
        <h2>{{ $draft['title'] }}</h2>
        <div style="margin-top:14px;border-radius:20px;padding:20px;background:#003366;color:white">
            <div style="font-size:10px;font-weight:900;letter-spacing:1.2px;color:#D4AF37">{{ $draft['eyebrow'] }}</div>
            <div style="font-family:serif;font-size:25px;font-weight:700;line-height:1.08;margin-top:8px">{{ $draft['title'] }}</div>
            <p style="color:#dbe4ec;line-height:1.5;margin:10px 0 0">{{ $draft['body'] }}</p>
            @if ($draft['cta_action'] !== 'none')
                <div style="margin-top:14px;font-size:11px;font-weight:900;letter-spacing:.8px;color:#D4AF37">{{ $draft['cta_label'] }} →</div>
            @endif
        </div>

        <div class="status-row section-space">
            <div><strong>Draft schedule state</strong><div class="muted">Server UTC evaluation right now</div></div>
            <span class="badge {{ $draftActiveNow ? 'good' : 'warn' }}">{{ $draftActiveNow ? 'ACTIVE' : 'INACTIVE' }}</span>
        </div>
        <div class="status-row">
            <div><strong>Publication state</strong><div class="muted">{{ $hasPublished ? 'Live revision '.$entry->published_revision : 'Nothing public yet' }}</div></div>
            <span class="badge {{ $hasPublished && ! $hasChanges ? 'good' : 'warn' }}">{{ ! $hasPublished ? 'NOT LIVE' : ($hasChanges ? 'CHANGES WAITING' : 'CURRENT') }}</span>
        </div>

        <form method="post" action="{{ route('admin.content.home.banner.publish') }}" class="section-space">
            @csrf
            <input type="hidden" name="revision" value="{{ $entry->revision }}">
            <button class="btn primary" type="submit">Publish Home Banner</button>
        </form>

        <div class="locked section-space">
            <small>Safety boundary</small>
            <strong>CTA behavior is limited to compiled Browse, Search or None. No URLs, HTML, scripts, coupon logic or commerce overrides are accepted.</strong>
        </div>
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
                            <form method="post" action="{{ route('admin.content.home.banner.restore') }}">
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
