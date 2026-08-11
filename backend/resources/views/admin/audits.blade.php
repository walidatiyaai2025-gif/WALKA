@extends('admin.layout')

@section('title', 'WALKA Admin · Audit log')
@section('topbar', 'Audit log')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">Traceability</p>
        <h1>Catalog audit log</h1>
        <p class="lead">Newest-first immutable authoring events. The dashboard stores only a SHA-256 actor fingerprint; no raw admin password or Bearer token is written to the audit table.</p>
    </div>
    <span class="badge lock">LATEST 100</span>
</div>

<section class="card">
    @if ($audits->isEmpty())
        <div class="locked">
            <strong>No audit events yet.</strong>
            <div class="muted" style="font-size:12px;margin-top:5px">Effective product or variant changes will be recorded automatically.</div>
        </div>
    @else
        <div class="table-wrap">
            <table>
                <thead>
                    <tr><th>Timestamp</th><th>Target</th><th>Action</th><th>Revision</th><th>Changed fields</th><th>Actor fingerprint</th></tr>
                </thead>
                <tbody>
                @foreach ($audits as $audit)
                    <tr>
                        <td>{{ $audit->created_at?->format('Y-m-d H:i:s') }}</td>
                        <td><code>{{ $audit->target_type }}:{{ $audit->target_id }}</code></td>
                        <td>{{ strtoupper($audit->action) }}</td>
                        <td>{{ $audit->from_revision }} → {{ $audit->to_revision }}</td>
                        <td>
                            @foreach (array_keys($audit->changes ?? []) as $field)
                                <span class="badge lock" style="display:inline-block;margin:2px">{{ $field }}</span>
                            @endforeach
                        </td>
                        <td><code title="{{ $audit->actor_fingerprint }}">{{ substr($audit->actor_fingerprint, 0, 12) }}…</code></td>
                    </tr>
                @endforeach
                </tbody>
            </table>
        </div>
    @endif
</section>
@endsection
