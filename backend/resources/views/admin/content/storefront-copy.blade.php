@extends('admin.layout')

@section('title', 'Storefront Copy · WALKA Admin')
@section('topbar', 'Storefront copy')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">LIVE-CONTROLLED COPY</p>
        <h1>Storefront copy</h1>
        <p class="lead">Control storefront labels plus Account, FAQ, Contact, Privacy, Terms and official destinations. Draft changes remain private until Publish.</p>
    </div>
</div>

@if ($errors->any())
    <section class="card"><strong>Save blocked.</strong><ul>@foreach ($errors->all() as $error)<li>{{ $error }}</li>@endforeach</ul></section>
@endif

<section class="card">
    <form method="post" action="{{ route('admin.content.storefront.copy.update') }}" class="stack">
        @csrf
        @method('PATCH')
        <input type="hidden" name="revision" value="{{ $entry->revision }}">

        <h2>Categories screen</h2>
        <div class="field"><label for="categories_heading">Heading</label><input id="categories_heading" name="categories_heading" maxlength="80" required value="{{ old('categories_heading', $draft['categories_heading']) }}"></div>
        <div class="field"><label for="categories_body">Supporting copy</label><textarea id="categories_body" name="categories_body" maxlength="240" required>{{ old('categories_body', $draft['categories_body']) }}</textarea></div>

        <h2 class="section-space">Favorites screen</h2>
        <div class="grid two">
            <div class="field"><label for="favorites_heading">Heading</label><input id="favorites_heading" name="favorites_heading" maxlength="80" required value="{{ old('favorites_heading', $draft['favorites_heading']) }}"></div>
            <div class="field"><label for="favorites_explore_label">Explore CTA label</label><input id="favorites_explore_label" name="favorites_explore_label" maxlength="80" required value="{{ old('favorites_explore_label', $draft['favorites_explore_label']) }}"></div>
            <div class="field"><label for="favorites_empty_title">Empty-state title</label><input id="favorites_empty_title" name="favorites_empty_title" maxlength="100" required value="{{ old('favorites_empty_title', $draft['favorites_empty_title']) }}"></div>
            <div class="field"><label for="favorites_remove_label">Remove action label</label><input id="favorites_remove_label" name="favorites_remove_label" maxlength="60" required value="{{ old('favorites_remove_label', $draft['favorites_remove_label']) }}"></div>
        </div>
        <div class="field"><label for="favorites_body">Supporting copy</label><textarea id="favorites_body" name="favorites_body" maxlength="240" required>{{ old('favorites_body', $draft['favorites_body']) }}</textarea></div>
        <div class="field"><label for="favorites_empty_body">Empty-state body</label><textarea id="favorites_empty_body" name="favorites_empty_body" maxlength="240" required>{{ old('favorites_empty_body', $draft['favorites_empty_body']) }}</textarea></div>

        <h2 class="section-space">Product detail</h2>
        <div class="field"><label for="pdp_unavailable">Unavailable message</label><input id="pdp_unavailable" name="pdp_unavailable" maxlength="160" required value="{{ old('pdp_unavailable', $draft['pdp_unavailable']) }}"></div>
        <div class="grid two">
            <div class="field"><label for="pdp_colors_label">Colors label</label><input id="pdp_colors_label" name="pdp_colors_label" maxlength="60" required value="{{ old('pdp_colors_label', $draft['pdp_colors_label']) }}"></div>
            <div class="field"><label for="pdp_features_label">Features label</label><input id="pdp_features_label" name="pdp_features_label" maxlength="60" required value="{{ old('pdp_features_label', $draft['pdp_features_label']) }}"></div>
            <div class="field"><label for="pdp_details_label">Details label</label><input id="pdp_details_label" name="pdp_details_label" maxlength="60" required value="{{ old('pdp_details_label', $draft['pdp_details_label']) }}"></div>
            <div class="field"><label for="pdp_buy_label">Amazon CTA label</label><input id="pdp_buy_label" name="pdp_buy_label" maxlength="80" required value="{{ old('pdp_buy_label', $draft['pdp_buy_label']) }}"></div>
            <div class="field"><label for="pdp_asin_label">ASIN label</label><input id="pdp_asin_label" name="pdp_asin_label" maxlength="40" required value="{{ old('pdp_asin_label', $draft['pdp_asin_label']) }}"></div>
            <div class="field"><label for="pdp_favorite_add_label">Favorite add label</label><input id="pdp_favorite_add_label" name="pdp_favorite_add_label" maxlength="80" required value="{{ old('pdp_favorite_add_label', $draft['pdp_favorite_add_label']) }}"></div>
            <div class="field"><label for="pdp_favorite_remove_label">Favorite remove label</label><input id="pdp_favorite_remove_label" name="pdp_favorite_remove_label" maxlength="80" required value="{{ old('pdp_favorite_remove_label', $draft['pdp_favorite_remove_label']) }}"></div>
        </div>

        <h2 class="section-space">Account, FAQ & legal information</h2>
        <p class="muted">This JSON is the live source for Our Story, FAQ, Contact, Amazon Store, Social, Privacy and Terms. HTTPS destinations and required page structures are validated before save/publish.</p>
        <div class="field">
            <label for="information_json">Information JSON</label>
            <textarea id="information_json" name="information_json" maxlength="30000" rows="28" required style="font-family:monospace">{{ old('information_json', $draft['information_json']) }}</textarea>
        </div>

        <button class="btn navy" type="submit">Save private draft</button>
    </form>
</section>

<div class="grid two section-space">
    <section class="card">
        <p class="eyebrow">PUBLISH</p>
        <h2>Make this revision live</h2>
        <p class="muted">Current live revision: {{ $entry->published_revision ?? 'none' }}.</p>
        <form method="post" action="{{ route('admin.content.storefront.copy.publish') }}">
            @csrf
            <input type="hidden" name="revision" value="{{ $entry->revision }}">
            <button class="btn primary" type="submit">Publish current draft</button>
        </form>
    </section>
    <section class="card">
        <p class="eyebrow">HISTORY</p>
        <h2>Restore to private draft</h2>
        @forelse ($entry->revisions as $revision)
            <form method="post" action="{{ route('admin.content.storefront.copy.restore') }}" class="section-space">
                @csrf
                <input type="hidden" name="revision" value="{{ $entry->revision }}">
                <input type="hidden" name="source_revision" value="{{ $revision->revision }}">
                <button class="btn secondary" type="submit">Restore revision {{ $revision->revision }}</button>
            </form>
        @empty
            <p class="muted">No historical revisions yet.</p>
        @endforelse
    </section>
</div>
@endsection
