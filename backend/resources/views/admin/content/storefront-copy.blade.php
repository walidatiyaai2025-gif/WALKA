@extends('admin.layout')

@section('title', 'Storefront Copy · WALKA Admin')
@section('topbar', 'Storefront copy')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">LIVE-CONTROLLED COPY</p>
        <h1>Storefront copy</h1>
        <p class="lead">Control generic Categories and Product Detail labels from the Dashboard. Draft changes remain private until Publish.</p>
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

        <h2 class="section-space">Product detail</h2>
        <div class="field"><label for="pdp_unavailable">Unavailable message</label><input id="pdp_unavailable" name="pdp_unavailable" maxlength="160" required value="{{ old('pdp_unavailable', $draft['pdp_unavailable']) }}"></div>
        <div class="grid two">
            <div class="field"><label for="pdp_colors_label">Colors label</label><input id="pdp_colors_label" name="pdp_colors_label" maxlength="60" required value="{{ old('pdp_colors_label', $draft['pdp_colors_label']) }}"></div>
            <div class="field"><label for="pdp_features_label">Features label</label><input id="pdp_features_label" name="pdp_features_label" maxlength="60" required value="{{ old('pdp_features_label', $draft['pdp_features_label']) }}"></div>
            <div class="field"><label for="pdp_details_label">Details label</label><input id="pdp_details_label" name="pdp_details_label" maxlength="60" required value="{{ old('pdp_details_label', $draft['pdp_details_label']) }}"></div>
            <div class="field"><label for="pdp_buy_label">Amazon CTA label</label><input id="pdp_buy_label" name="pdp_buy_label" maxlength="80" required value="{{ old('pdp_buy_label', $draft['pdp_buy_label']) }}"></div>
            <div class="field"><label for="pdp_asin_label">ASIN label</label><input id="pdp_asin_label" name="pdp_asin_label" maxlength="40" required value="{{ old('pdp_asin_label', $draft['pdp_asin_label']) }}"></div>
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
