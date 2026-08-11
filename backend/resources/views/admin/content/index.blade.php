@extends('admin.layout')

@section('title', 'Mobile Content · WALKA Admin')
@section('topbar', 'Mobile content')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">CMS CONTROL PLANE</p>
        <h1>Mobile content</h1>
        <p class="lead">Draft, preview and publish owner-changeable mobile content without shipping a new app build. Prefer typed editors for supported surfaces; the generic structured editor remains available for advanced CMS work.</p>
    </div>
</div>

<div class="grid two">
    <section class="card" style="border-color:#eadba8;background:linear-gradient(135deg,#fffefb,#fbf6e7)">
        <p class="eyebrow">LIVE-CONTROLLED COPY</p>
        <h2>Home Hero</h2>
        <p class="muted">Edit the Home eyebrow, headline, body and CTA labels with typed validation, mobile preview, publish history and rollback.</p>
        <a class="btn primary section-space" href="{{ route('admin.content.home.hero.edit') }}">Edit Home Hero →</a>
    </section>
    <section class="card" style="border-color:#d7e4ec;background:linear-gradient(135deg,#ffffff,#f4f8fb)">
        <p class="eyebrow">LIVE-CONTROLLED COMPOSITION</p>
        <h2>Home Layout</h2>
        <p class="muted">Reorder approved Home modules, hide optional sections and edit safe section headings. Core Hero and Collection modules stay protected.</p>
        <a class="btn navy section-space" href="{{ route('admin.content.home.layout.edit') }}">Edit Home Layout →</a>
    </section>
</div>

<div class="grid two section-space">
    <section class="card">
        <p class="eyebrow">CONTENT REGISTRY</p>
        <h2>Managed entries</h2>
        @if ($entries->isEmpty())
            <div class="locked">
                <strong>No CMS content entries yet.</strong>
                <p class="muted">Opening a typed editor can safely bootstrap its first private draft. Nothing becomes public until Publish is used explicitly.</p>
            </div>
        @else
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr><th>Key</th><th>Type</th><th>State</th><th>Revision</th><th>History</th><th>Action</th></tr>
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
                            <td>
                                @if ($entry->content_key === 'home.hero' && $entry->content_type === 'home.hero')
                                    <a class="btn secondary" href="{{ route('admin.content.home.hero.edit') }}">Typed editor</a>
                                @elseif ($entry->content_key === 'home.layout' && $entry->content_type === 'home.layout')
                                    <a class="btn secondary" href="{{ route('admin.content.home.layout.edit') }}">Typed editor</a>
                                @else
                                    <a class="btn secondary" href="{{ route('admin.content.show', ['content' => $entry->id]) }}">Open</a>
                                @endif
                            </td>
                        </tr>
                    @endforeach
                    </tbody>
                </table>
            </div>
        @endif
    </section>

    <aside class="card">
        <p class="eyebrow">ADVANCED DRAFT</p>
        <h2>Create content entry</h2>
        <p class="muted">Use this structured foundation editor only for content families that do not yet have a typed owner UI. Stable content type cannot be changed after creation.</p>
        <form method="post" action="{{ route('admin.content.store') }}" class="stack section-space">
            @csrf
            <div class="field">
                <label for="content_key">Stable content key</label>
                <input id="content_key" name="content_key" value="{{ old('content_key') }}" placeholder="about.story" required>
            </div>
            <div class="field">
                <label for="content_type">Content type</label>
                <input id="content_type" name="content_type" value="{{ old('content_type') }}" placeholder="about.story" required>
            </div>
            <div class="field">
                <label for="payload_json">Structured JSON draft</label>
                <textarea id="payload_json" name="payload_json" spellcheck="false" required>{{ old('payload_json', "{\n  \"title\": \"\",\n  \"body\": \"\"\n}") }}</textarea>
            </div>
            <button class="btn navy" type="submit">Create private draft</button>
        </form>
        <div class="locked section-space">
            <small>Safety boundary</small>
            <strong>Structured data only. Public APIs expose explicit allowlisted typed fields, never arbitrary generic payload keys.</strong>
        </div>
    </aside>
</div>
@endsection
