@extends('admin.layout')

@section('title', 'Mobile Content · WALKA Admin')
@section('topbar', 'Mobile content')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">CMS CONTROL PLANE</p>
        <h1>Mobile content</h1>
        <p class="lead">Draft, preview and publish owner-changeable mobile content without shipping a new app build. Prefer typed editors for supported surfaces; every entry also exposes immutable history, diff, scheduling and reasoned rollback controls.</p>
    </div>
    <a class="btn secondary" href="{{ route('admin.content.health') }}">Content health →</a>
</div>

<div class="grid metrics">
    <section class="card" style="border-color:#c9e1d5;background:linear-gradient(135deg,#ffffff,#f3fbf7)"><p class="eyebrow">CMS-053 · OPERATIONS</p><h2>Publication health</h2><p class="muted">Review revisions, freshness, ETags/cache metadata and stale schedules without exposing content payloads.</p><a class="btn navy section-space" href="{{ route('admin.content.health') }}">Open health matrix →</a></section>
    <section class="card"><p class="eyebrow">LIVE-CONTROLLED COPY</p><h2>Home Hero</h2><p class="muted">Edit the Home eyebrow, headline, body and CTA labels.</p><a class="btn primary section-space" href="{{ route('admin.content.home.hero.edit') }}">Edit Home Hero →</a></section>
    <section class="card"><p class="eyebrow">LIVE-CONTROLLED COMPOSITION</p><h2>Home Layout</h2><p class="muted">Reorder approved Home modules and hide optional sections.</p><a class="btn navy section-space" href="{{ route('admin.content.home.layout.edit') }}">Edit Home Layout →</a></section>
    <section class="card"><p class="eyebrow">LIVE-CONTROLLED MERCHANDISING</p><h2>Featured Products</h2><p class="muted">Choose approved catalog variants for Home collection/editorial slots.</p><a class="btn navy section-space" href="{{ route('admin.content.home.featured.edit') }}">Edit Featured →</a></section>
    <section class="card"><p class="eyebrow">SCHEDULED ANNOUNCEMENT</p><h2>Home Banner</h2><p class="muted">Publish one safe announcement and let its UTC window control visibility automatically.</p><a class="btn primary section-space" href="{{ route('admin.content.home.banner.edit') }}">Edit Banner →</a></section>
    <section class="card" style="border-color:#d7e4ec;background:linear-gradient(135deg,#ffffff,#f4f8fb)"><p class="eyebrow">DISCOVERY CONTROL</p><h2>Categories</h2><p class="muted">Rename, describe, reorder and show/hide approved Product Master categories.</p><a class="btn navy section-space" href="{{ route('admin.content.categories.edit') }}">Edit Categories →</a></section>
    <section class="card" style="border-color:#d7e4ec;background:linear-gradient(135deg,#ffffff,#f4f8fb)"><p class="eyebrow">SEARCH MERCHANDISING</p><h2>Search</h2><p class="muted">Edit safe Search copy, filter labels and complete-catalog Featured ordering.</p><a class="btn navy section-space" href="{{ route('admin.content.search.edit') }}">Edit Search →</a></section>
    <section class="card" style="border-color:#d7e4ec;background:linear-gradient(135deg,#ffffff,#f4f8fb)"><p class="eyebrow">PRODUCT DETAIL CONTROL</p><h2>PDP Layout</h2><p class="muted">Reorder approved Product Detail modules and hide only optional presentation sections.</p><a class="btn navy section-space" href="{{ route('admin.content.pdp.layout.edit') }}">Edit PDP Layout →</a></section>
    <section class="card" style="border-color:#d7e4ec;background:linear-gradient(135deg,#ffffff,#f4f8fb)"><p class="eyebrow">PDP MERCHANDISING</p><h2>Related Products</h2><p class="muted">Order safe recommendations using existing stable WALKA product IDs only.</p><a class="btn navy section-space" href="{{ route('admin.content.pdp.related-products.edit') }}">Edit Related Products →</a></section>
    <section class="card" style="border-color:#ead8aa;background:linear-gradient(135deg,#ffffff,#fffaf0)"><p class="eyebrow">CMS-060/061 · GOVERNED COMMERCE</p><h2>Amazon Destinations</h2><p class="muted">Enable approved Amazon markets per released variant while Product Master IDs, ASINs and canonical destination paths remain locked and server-derived.</p><a class="btn primary section-space" href="{{ route('admin.content.commerce.edit') }}">Edit Amazon Destinations →</a></section>
    <section class="card" style="border-color:#ead8aa;background:linear-gradient(135deg,#ffffff,#fffaf0)">
        <p class="eyebrow">CMS-040..043 · INFORMATION</p><h2>About, FAQ, Support & Legal</h2><p class="muted">Edit the four released information surfaces as one revision-safe snapshot. Destinations and executable behavior remain protected.</p>
        <div class="section-space" style="display:flex;flex-wrap:wrap;gap:8px"><a class="btn navy" href="{{ route('admin.content.information.edit', ['section' => 'about']) }}">About / Story</a><a class="btn secondary" href="{{ route('admin.content.information.edit', ['section' => 'faq']) }}">FAQ</a><a class="btn secondary" href="{{ route('admin.content.information.edit', ['section' => 'support']) }}">Support</a><a class="btn secondary" href="{{ route('admin.content.information.edit', ['section' => 'legal']) }}">Legal</a></div>
    </section>
    <section class="card" style="border-color:#f0cfaf;background:linear-gradient(135deg,#ffffff,#fff7ef)"><p class="eyebrow">CMS-044 · OPERATIONS</p><h2>Maintenance notice</h2><p class="muted">Publish safe customer-service or maintenance copy with an optional UTC display window.</p><a class="btn primary section-space" href="{{ route('admin.content.maintenance.edit') }}">Edit notice →</a></section>
    @if (session('walka_admin_dashboard_role') === 'owner')
        <section class="card" style="border-color:#cfe2ee;background:linear-gradient(135deg,#ffffff,#f2f8fc)"><p class="eyebrow">CMS-045 · APP CONFIG</p><h2>Presentation switches</h2><p class="muted">Owner-only compiled flags. No security, secrets, Product Master or commerce controls are remotely editable.</p><a class="btn navy section-space" href="{{ route('admin.app-config.edit') }}">Open App Config →</a></section>
    @endif
</div>

<div class="grid two section-space">
    <section class="card">
        <p class="eyebrow">CONTENT REGISTRY</p><h2>Managed entries</h2>
        @if ($entries->isEmpty())
            <div class="locked"><strong>No CMS content entries yet.</strong><p class="muted">Opening a typed editor can safely bootstrap its first private draft. Nothing becomes public until Publish is used explicitly.</p></div>
        @else
            <div class="table-wrap"><table><thead><tr><th>Key</th><th>Type</th><th>State</th><th>Revision</th><th>History</th><th>Schedule</th><th>Action</th></tr></thead><tbody>
            @foreach ($entries as $entry)
                @php $isPublished = $entry->published_revision !== null; $hasChanges = $isPublished && $entry->draft_payload !== $entry->published_payload; $hasSchedule = $entry->scheduled_publish_at || $entry->scheduled_unpublish_at; @endphp
                <tr>
                    <td><code>{{ $entry->content_key }}</code></td><td>{{ $entry->content_type }}</td>
                    <td>@if (! $isPublished)<span class="badge warn">DRAFT ONLY</span>@elseif ($hasChanges)<span class="badge warn">UNPUBLISHED CHANGES</span>@else<span class="badge good">PUBLISHED</span>@endif</td>
                    <td>{{ $entry->revision }} <span class="muted">/ live {{ $entry->published_revision ?? '—' }}</span></td><td>{{ $entry->revisions_count }}</td>
                    <td>@if ($hasSchedule)<span class="badge {{ $entry->schedule_revision === $entry->revision ? 'good' : 'warn' }}">{{ $entry->schedule_revision === $entry->revision ? 'ARMED' : 'STALE' }}</span>@else<span class="muted">—</span>@endif</td>
                    <td><div class="actions">
                        @if ($entry->content_key === 'home.hero' && $entry->content_type === 'home.hero')<a class="btn secondary" href="{{ route('admin.content.home.hero.edit') }}">Typed editor</a>
                        @elseif ($entry->content_key === 'home.layout' && $entry->content_type === 'home.layout')<a class="btn secondary" href="{{ route('admin.content.home.layout.edit') }}">Typed editor</a>
                        @elseif ($entry->content_key === 'home.featured' && $entry->content_type === 'home.featured')<a class="btn secondary" href="{{ route('admin.content.home.featured.edit') }}">Typed editor</a>
                        @elseif ($entry->content_key === 'home.banner' && $entry->content_type === 'home.banner')<a class="btn secondary" href="{{ route('admin.content.home.banner.edit') }}">Typed editor</a>
                        @elseif ($entry->content_key === 'categories.presentation' && $entry->content_type === 'categories.presentation')<a class="btn secondary" href="{{ route('admin.content.categories.edit') }}">Typed editor</a>
                        @elseif ($entry->content_key === 'search.presentation' && $entry->content_type === 'search.presentation')<a class="btn secondary" href="{{ route('admin.content.search.edit') }}">Typed editor</a>
                        @elseif ($entry->content_key === 'pdp.layout' && $entry->content_type === 'pdp.layout')<a class="btn secondary" href="{{ route('admin.content.pdp.layout.edit') }}">Typed editor</a>
                        @elseif ($entry->content_key === 'pdp.related_products' && $entry->content_type === 'pdp.related_products')<a class="btn secondary" href="{{ route('admin.content.pdp.related-products.edit') }}">Typed editor</a>
                        @elseif ($entry->content_key === 'commerce.map' && $entry->content_type === 'commerce.map')<a class="btn secondary" href="{{ route('admin.content.commerce.edit') }}">Typed editor</a>
                        @elseif ($entry->content_key === 'information' && $entry->content_type === 'information')<a class="btn secondary" href="{{ route('admin.content.information.edit', ['section' => 'about']) }}">Typed editors</a>
                        @elseif ($entry->content_key === 'app.maintenance_notice' && $entry->content_type === 'app.maintenance_notice')<a class="btn secondary" href="{{ route('admin.content.maintenance.edit') }}">Typed editor</a>
                        @elseif ($entry->content_key === 'app.config' && $entry->content_type === 'app.config' && session('walka_admin_dashboard_role') === 'owner')<a class="btn secondary" href="{{ route('admin.app-config.edit') }}">App Config</a>
                        @endif
                        <a class="btn secondary" href="{{ route('admin.content.show', ['content' => $entry->id]) }}">History / diff / rollback</a>
                    </div></td>
                </tr>
            @endforeach
            </tbody></table></div>
        @endif
    </section>

    <aside class="card">
        <p class="eyebrow">ADVANCED DRAFT</p><h2>Create content entry</h2><p class="muted">Use this structured foundation editor only for content families that do not yet have a typed owner UI.</p>
        <form method="post" action="{{ route('admin.content.store') }}" class="stack section-space">@csrf<div class="field"><label for="content_key">Stable content key</label><input id="content_key" name="content_key" value="{{ old('content_key') }}" placeholder="about.story" required></div><div class="field"><label for="content_type">Content type</label><input id="content_type" name="content_type" value="{{ old('content_type') }}" placeholder="about.story" required></div><div class="field"><label for="payload_json">Structured JSON draft</label><textarea id="payload_json" name="payload_json" spellcheck="false" required>{{ old('payload_json', "{\n  \"title\": \"\",\n  \"body\": \"\"\n}") }}</textarea></div><button class="btn navy" type="submit">Create private draft</button></form>
        <div class="locked section-space"><small>Safety boundary</small><strong>Public APIs expose explicit typed allowlists, never arbitrary generic payload keys.</strong></div>
    </aside>
</div>
@endsection
