@extends('admin.layout')

@section('title', 'Mobile Content · WALKA Admin')
@section('topbar', 'Mobile content')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">CMS CONTROL PLANE</p>
        <h1>Mobile content</h1>
        <p class="lead">Draft, preview and publish structured mobile content without shipping a new app build. This is the advanced foundation editor; typed Home, PDP and media editors will sit on the same revision system.</p>
    </div>
</div>

<div class="grid two">
    <section class="card">
        <p class="eyebrow">CONTENT REGISTRY</p>
        <h2>Managed entries</h2>
        @if ($entries->isEmpty())
            <div class="locked">
                <strong>No CMS content entries yet.</strong>
                <p class="muted">Create the first draft using a stable key. Nothing becomes public until Publish is used explicitly.</p>
            </div>
        @else
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Key</th>
                        <th>Type</th>
                        <th>State</th>
                        <th>Revision</th>
                        <th>History</th>
                        <th>Action</th>
                    </tr>
                    </thead>
                    <tbody>
                    @foreach ($entries as $entry)
                        @php
                            $isPublished = $entry->published_revision !== null;
                            $hasChanges = $isPublished && $entry->draft_payload !== $entry->published_payload;
                        @endphp
                        <tr>
                            <td><code>{{ $entry->content_key }}</code></td>
                            <td>{{ $entry->content_type }}</td>
                            <td>
                                @if (! $isPublished)
                                    <span class="badge warn">DRAFT ONLY</span>
                                @elseif ($hasChanges)
                                    <span class="badge warn">UNPUBLISHED CHANGES</span>
                                @else
                                    <span class="badge good">PUBLISHED</span>
                                @endif
                            </td>
                            <td>{{ $entry->revision }} <span class="muted">/ live {{ $entry->published_revision ?? '—' }}</span></td>
                            <td>{{ $entry->revisions_count }}</td>
                            <td><a class="btn secondary" href="{{ route('admin.content.show', ['content' => $entry->id]) }}">Open</a></td>
                        </tr>
                    @endforeach
                    </tbody>
                </table>
            </div>
        @endif
    </section>

    <aside class="card">
        <p class="eyebrow">NEW DRAFT</p>
        <h2>Create content entry</h2>
        <p class="muted">Use permanent machine-readable keys. The content type cannot be changed after creation.</p>
        <form method="post" action="{{ route('admin.content.store') }}" class="stack section-space">
            @csrf
            <div class="field">
                <label for="content_key">Stable content key</label>
                <input id="content_key" name="content_key" value="{{ old('content_key') }}" placeholder="home.hero" required>
            </div>
            <div class="field">
                <label for="content_type">Content type</label>
                <input id="content_type" name="content_type" value="{{ old('content_type') }}" placeholder="home.hero" required>
            </div>
            <div class="field">
                <label for="payload_json">Structured JSON draft</label>
                <textarea id="payload_json" name="payload_json" spellcheck="false" required>{{ old('payload_json', "{\n  \"title\": \"\",\n  \"subtitle\": \"\"\n}") }}</textarea>
            </div>
            <button class="btn navy" type="submit">Create draft</button>
        </form>
        <div class="locked section-space">
            <small>Safety boundary</small>
            <strong>Structured data only. No HTML/JavaScript execution, secrets, Product Master facts or unrestricted commerce destinations.</strong>
        </div>
    </aside>
</div>
@endsection
