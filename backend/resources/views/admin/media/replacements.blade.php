@extends('admin.layout')

@section('title', 'Media Replacement · WALKA Admin')
@section('topbar', 'Media replacement & rollback')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">IMMUTABLE MEDIA HISTORY</p>
        <h1>Replacement & rollback</h1>
        <p class="lead">Replace an assigned admitted asset without changing target order or media binaries. Every operation records immutable before/after assignment snapshots; rollback is allowed only while those exact affected assignments remain unchanged.</p>
    </div>
    <div class="actions">
        <a class="btn secondary" href="{{ route('admin.media.index') }}">← Media library</a>
        <a class="btn secondary" href="{{ route('admin.media.galleries.index') }}">Product galleries</a>
        <a class="btn secondary" href="{{ route('admin.media.surfaces.index') }}">Surface media</a>
    </div>
</div>

<div class="locked">
    <small>CMS-034 SAFETY BOUNDARY</small>
    <strong>Replacement changes assignment references only. Source/replacement must be distinct, admitted, canonical and the same purpose. No file is copied/deleted, no lifecycle is changed, and rollback never overwrites intervening owner edits.</strong>
</div>

<section class="card section-space">
    <p class="eyebrow">CURRENT ASSIGNMENTS</p>
    <h2>Replace assigned media</h2>
    @if ($sources->isEmpty())
        <div class="locked section-space"><strong>No admitted media currently has governed assignments.</strong></div>
    @else
        <div class="stack section-space">
        @foreach ($sources as $source)
            @php $asset = $source['asset']; @endphp
            <div class="locked" style="padding:18px">
                <div class="actions" style="justify-content:space-between;align-items:flex-start">
                    <div>
                        <small>{{ strtoupper($asset->purpose->value) }} · {{ count($source['assignments']) }} ASSIGNMENT(S)</small>
                        <strong>{{ $asset->semantic_label }}</strong>
                        <div class="muted"><code>{{ $asset->id }}</code></div>
                    </div>
                    <span class="badge good">ADMITTED + CANONICAL</span>
                </div>
                <div class="table-wrap section-space">
                    <table>
                        <thead><tr><th>Family</th><th>Target</th><th>Position</th></tr></thead>
                        <tbody>
                        @foreach ($source['assignments'] as $assignment)
                            <tr>
                                <td>{{ $assignment['family'] }}</td>
                                <td><code>{{ $assignment['target_id'] }}</code></td>
                                <td>{{ $assignment['position'] }}</td>
                            </tr>
                        @endforeach
                        </tbody>
                    </table>
                </div>
                <form method="post" action="{{ route('admin.media.replacements.store') }}" class="stack section-space">
                    @csrf
                    <input type="hidden" name="source_media_asset_id" value="{{ $asset->id }}">
                    <input type="hidden" name="expected_fingerprint" value="{{ $source['fingerprint'] }}">
                    <div class="field">
                        <label for="replacement-{{ $asset->id }}">Replacement asset · same {{ $asset->purpose->value }} purpose</label>
                        <select id="replacement-{{ $asset->id }}" name="replacement_media_asset_id" required style="width:100%;border:1px solid #ccd8e1;border-radius:11px;background:#fff;padding:11px 12px;color:#102235">
                            <option value="">Select admitted replacement…</option>
                            @foreach ($source['candidates'] as $candidate)
                                <option value="{{ $candidate->id }}">{{ $candidate->semantic_label }} · {{ $candidate->id }} · {{ $candidate->canonicalDerivative->width }}×{{ $candidate->canonicalDerivative->height }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="actions">
                        <button class="btn navy" type="submit" @disabled($source['candidates']->isEmpty())>Replace all current references</button>
                        <span class="muted">Fingerprint <code>{{ substr($source['fingerprint'], 0, 12) }}…</code></span>
                    </div>
                </form>
            </div>
        @endforeach
        </div>
    @endif
</section>

<section class="card section-space">
    <p class="eyebrow">IMMUTABLE AUDIT</p>
    <h2>Replacement history</h2>
    @if ($events->isEmpty())
        <div class="locked section-space"><strong>No replacement events yet.</strong></div>
    @else
        <div class="table-wrap section-space">
            <table>
                <thead><tr><th>Event</th><th>Operation</th><th>From → To</th><th>Assignments</th><th>Actor</th><th>Time</th><th>Action</th></tr></thead>
                <tbody>
                @foreach ($events as $event)
                    <tr>
                        <td><code>{{ $event->id }}</code></td>
                        <td><span class="badge {{ $event->isRollback() ? 'warn' : 'good' }}">{{ strtoupper($event->operation) }}</span></td>
                        <td>
                            <div>{{ $event->sourceAsset?->semantic_label ?? $event->source_media_asset_id }}</div>
                            <div class="muted">→ {{ $event->replacementAsset?->semantic_label ?? $event->replacement_media_asset_id }}</div>
                            @if ($event->rollback_of_event_id)
                                <div class="muted">rollback of <code>{{ $event->rollback_of_event_id }}</code></div>
                            @endif
                        </td>
                        <td>{{ count($event->after_assignments ?? []) }}</td>
                        <td><code>{{ substr($event->actor_fingerprint, 0, 12) }}…</code></td>
                        <td>{{ $event->created_at?->toIso8601String() }}</td>
                        <td>
                            @if ($event->isReplacement() && $event->rollbackEvent === null)
                                <form method="post" action="{{ route('admin.media.replacements.rollback', ['event' => $event->id]) }}">
                                    @csrf
                                    <input type="hidden" name="expected_after_fingerprint" value="{{ $event->after_fingerprint }}">
                                    <button class="btn secondary" type="submit">Rollback exact snapshot</button>
                                </form>
                            @elseif ($event->isReplacement())
                                <span class="badge lock">ROLLED BACK</span>
                            @else
                                <span class="muted">History only</span>
                            @endif
                        </td>
                    </tr>
                @endforeach
                </tbody>
            </table>
        </div>
    @endif
</section>
@endsection
