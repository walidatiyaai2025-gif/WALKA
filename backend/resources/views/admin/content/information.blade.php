@extends('admin.layout')

@section('title', 'Information Content · WALKA Admin')
@section('topbar', 'Information content')

@section('content')
@php
    $labels = [
        'about' => ['About / Story', 'CMS-040'],
        'faq' => ['FAQ', 'CMS-041'],
        'support' => ['Support / Contact', 'CMS-042'],
        'legal' => ['Privacy / Terms', 'CMS-043'],
    ];
@endphp

<div class="page-head">
    <div>
        <p class="eyebrow">{{ $labels[$section][1] }} · INFORMATION CONTROL</p>
        <h1>{{ $labels[$section][0] }}</h1>
        <p class="lead">Edit the released information presentation without shipping a new app build. All four Information panels share one validated revision so clients never receive a partially-updated information snapshot.</p>
    </div>
</div>

<div class="card" style="margin-bottom:18px">
    <div style="display:flex;flex-wrap:wrap;gap:8px">
        @foreach ($labels as $id => $meta)
            <a class="btn {{ $section === $id ? 'navy' : 'secondary' }}" href="{{ route('admin.content.information.edit', ['section' => $id]) }}">{{ $meta[0] }}</a>
        @endforeach
    </div>
</div>

@if ($errors->any())
    <section class="card" style="border-color:#efb5b5;margin-bottom:18px">
        <strong>Review the highlighted information fields.</strong>
        <ul>
            @foreach ($errors->all() as $error)<li>{{ $error }}</li>@endforeach
        </ul>
    </section>
@endif

@if (session('status'))
    <section class="card" style="border-color:#b7dcc3;margin-bottom:18px"><strong>{{ session('status') }}</strong></section>
@endif

<div class="grid two">
    <section class="card">
        <p class="eyebrow">PRIVATE DRAFT · REVISION {{ $entry->revision }}</p>
        <form method="post" action="{{ route('admin.content.information.update', ['section' => $section]) }}" class="stack section-space">
            @csrf
            @method('PATCH')
            <input type="hidden" name="revision" value="{{ $entry->revision }}">

            @if ($section === 'about')
                <div class="field"><label>Hero eyebrow</label><input name="hero_eyebrow" value="{{ old('hero_eyebrow', $sectionDraft['hero_eyebrow']) }}" required></div>
                <div class="field"><label>Hero title</label><textarea name="hero_title" rows="2" required>{{ old('hero_title', $sectionDraft['hero_title']) }}</textarea></div>
                <div class="field"><label>Hero body</label><textarea name="hero_body" rows="3" required>{{ old('hero_body', $sectionDraft['hero_body']) }}</textarea></div>
                <div class="field"><label>Story eyebrow</label><input name="story_eyebrow" value="{{ old('story_eyebrow', $sectionDraft['story_eyebrow']) }}" required></div>
                <div class="field"><label>Story title</label><input name="story_title" value="{{ old('story_title', $sectionDraft['story_title']) }}" required></div>
                <div class="field"><label>Story body</label><textarea name="story_body" rows="4" required>{{ old('story_body', $sectionDraft['story_body']) }}</textarea></div>
                <div class="field"><label>Values eyebrow</label><input name="values_eyebrow" value="{{ old('values_eyebrow', $sectionDraft['values_eyebrow']) }}" required></div>
                @foreach ($sectionDraft['values'] as $item)
                    <div class="locked">
                        <small>Stable value ID · {{ $item['id'] }}</small>
                        <div class="field section-space"><label>Title</label><input name="values[{{ $item['id'] }}][title]" value="{{ old('values.'.$item['id'].'.title', $item['title']) }}" required></div>
                        <div class="field"><label>Body</label><textarea name="values[{{ $item['id'] }}][body]" rows="2" required>{{ old('values.'.$item['id'].'.body', $item['body']) }}</textarea></div>
                    </div>
                @endforeach
                <div class="field"><label>Principles eyebrow</label><input name="principles_eyebrow" value="{{ old('principles_eyebrow', $sectionDraft['principles_eyebrow']) }}" required></div>
                <div class="field"><label>Principles title</label><input name="principles_title" value="{{ old('principles_title', $sectionDraft['principles_title']) }}" required></div>
                @foreach ($sectionDraft['principles'] as $item)
                    <div class="locked">
                        <small>Stable principle ID · {{ $item['id'] }}</small>
                        <div class="field section-space"><label>Title</label><input name="principles[{{ $item['id'] }}][title]" value="{{ old('principles.'.$item['id'].'.title', $item['title']) }}" required></div>
                        <div class="field"><label>Body</label><textarea name="principles[{{ $item['id'] }}][body]" rows="3" required>{{ old('principles.'.$item['id'].'.body', $item['body']) }}</textarea></div>
                    </div>
                @endforeach
                <div class="field"><label>Closing eyebrow</label><input name="closing_eyebrow" value="{{ old('closing_eyebrow', $sectionDraft['closing_eyebrow']) }}" required></div>
                <div class="field"><label>Closing title</label><input name="closing_title" value="{{ old('closing_title', $sectionDraft['closing_title']) }}" required></div>
                <div class="field"><label>Closing body</label><textarea name="closing_body" rows="3" required>{{ old('closing_body', $sectionDraft['closing_body']) }}</textarea></div>
            @elseif ($section === 'faq')
                <div class="field"><label>Eyebrow</label><input name="eyebrow" value="{{ old('eyebrow', $sectionDraft['eyebrow']) }}" required></div>
                <div class="field"><label>Title</label><input name="title" value="{{ old('title', $sectionDraft['title']) }}" required></div>
                <div class="field"><label>Intro</label><textarea name="intro" rows="3" required>{{ old('intro', $sectionDraft['intro']) }}</textarea></div>
                @php $faqRows = array_pad($sectionDraft['items'], 12, ['id' => '', 'question' => '', 'answer' => '']); @endphp
                @foreach ($faqRows as $index => $item)
                    <div class="locked">
                        <small>FAQ row {{ $index + 1 }} · leave all fields blank to omit</small>
                        <div class="field section-space"><label>Stable ID</label><input name="items[{{ $index }}][id]" value="{{ old('items.'.$index.'.id', $item['id']) }}" placeholder="shipping-question"></div>
                        <div class="field"><label>Question</label><input name="items[{{ $index }}][question]" value="{{ old('items.'.$index.'.question', $item['question']) }}"></div>
                        <div class="field"><label>Answer</label><textarea name="items[{{ $index }}][answer]" rows="3">{{ old('items.'.$index.'.answer', $item['answer']) }}</textarea></div>
                    </div>
                @endforeach
            @elseif ($section === 'support')
                <div class="field"><label>Eyebrow</label><input name="eyebrow" value="{{ old('eyebrow', $sectionDraft['eyebrow']) }}" required></div>
                <div class="field"><label>Title</label><input name="title" value="{{ old('title', $sectionDraft['title']) }}" required></div>
                <div class="field"><label>Intro</label><textarea name="intro" rows="3" required>{{ old('intro', $sectionDraft['intro']) }}</textarea></div>
                <div class="field"><label>Amazon order support title</label><input name="amazon_order_title" value="{{ old('amazon_order_title', $sectionDraft['amazon_order_title']) }}" required></div>
                <div class="field"><label>Amazon order support body</label><textarea name="amazon_order_body" rows="3" required>{{ old('amazon_order_body', $sectionDraft['amazon_order_body']) }}</textarea></div>
                <div class="field"><label>WALKA support email</label><input type="email" name="support_email" value="{{ old('support_email', $sectionDraft['support_email']) }}" required><small>Security policy: only validated @walkastore.com addresses are accepted.</small></div>
                <div class="field"><label>Email card title</label><input name="email_title" value="{{ old('email_title', $sectionDraft['email_title']) }}" required></div>
                <div class="field"><label>Email card body</label><textarea name="email_body" rows="2" required>{{ old('email_body', $sectionDraft['email_body']) }}</textarea></div>
                <div class="field"><label>Website card title</label><input name="website_title" value="{{ old('website_title', $sectionDraft['website_title']) }}" required></div>
                <div class="field"><label>Website card body</label><textarea name="website_body" rows="2" required>{{ old('website_body', $sectionDraft['website_body']) }}</textarea></div>
                <div class="field"><label>Instagram card title</label><input name="instagram_title" value="{{ old('instagram_title', $sectionDraft['instagram_title']) }}" required></div>
                <div class="field"><label>Instagram card body</label><textarea name="instagram_body" rows="2" required>{{ old('instagram_body', $sectionDraft['instagram_body']) }}</textarea></div>
                <div class="locked"><small>Destination boundary</small><strong>Website and Instagram URLs are compiled approved destinations and are not editable here.</strong></div>
            @else
                <div class="field"><label>Shared legal eyebrow</label><input name="eyebrow" value="{{ old('eyebrow', $sectionDraft['eyebrow']) }}" required></div>
                <h3>Privacy</h3>
                <div class="field"><label>Title</label><input name="privacy_title" value="{{ old('privacy_title', $sectionDraft['privacy']['title']) }}" required></div>
                <div class="field"><label>Intro</label><textarea name="privacy_intro" rows="3" required>{{ old('privacy_intro', $sectionDraft['privacy']['intro']) }}</textarea></div>
                @php $privacyRows = array_pad($sectionDraft['privacy']['sections'], 8, ['id' => '', 'title' => '', 'body' => '']); @endphp
                @foreach ($privacyRows as $index => $item)
                    <div class="locked">
                        <small>Privacy row {{ $index + 1 }} · leave all fields blank to omit</small>
                        <div class="field section-space"><label>Stable ID</label><input name="privacy_sections[{{ $index }}][id]" value="{{ old('privacy_sections.'.$index.'.id', $item['id']) }}"></div>
                        <div class="field"><label>Title</label><input name="privacy_sections[{{ $index }}][title]" value="{{ old('privacy_sections.'.$index.'.title', $item['title']) }}"></div>
                        <div class="field"><label>Body</label><textarea name="privacy_sections[{{ $index }}][body]" rows="3">{{ old('privacy_sections.'.$index.'.body', $item['body']) }}</textarea></div>
                    </div>
                @endforeach
                <h3>Terms</h3>
                <div class="field"><label>Title</label><input name="terms_title" value="{{ old('terms_title', $sectionDraft['terms']['title']) }}" required></div>
                <div class="field"><label>Intro</label><textarea name="terms_intro" rows="3" required>{{ old('terms_intro', $sectionDraft['terms']['intro']) }}</textarea></div>
                @php $termsRows = array_pad($sectionDraft['terms']['sections'], 8, ['id' => '', 'title' => '', 'body' => '']); @endphp
                @foreach ($termsRows as $index => $item)
                    <div class="locked">
                        <small>Terms row {{ $index + 1 }} · leave all fields blank to omit</small>
                        <div class="field section-space"><label>Stable ID</label><input name="terms_sections[{{ $index }}][id]" value="{{ old('terms_sections.'.$index.'.id', $item['id']) }}"></div>
                        <div class="field"><label>Title</label><input name="terms_sections[{{ $index }}][title]" value="{{ old('terms_sections.'.$index.'.title', $item['title']) }}"></div>
                        <div class="field"><label>Body</label><textarea name="terms_sections[{{ $index }}][body]" rows="3">{{ old('terms_sections.'.$index.'.body', $item['body']) }}</textarea></div>
                    </div>
                @endforeach
                <div class="field"><label>Mandatory legal-review notice title</label><input name="review_notice_title" value="{{ old('review_notice_title', $sectionDraft['review_notice_title']) }}" required></div>
                <div class="field"><label>Mandatory legal-review notice body</label><textarea name="review_notice_body" rows="3" required>{{ old('review_notice_body', $sectionDraft['review_notice_body']) }}</textarea><small>The notice itself cannot be hidden or removed by this CMS.</small></div>
            @endif

            <button class="btn navy" type="submit">Save private draft</button>
        </form>
    </section>

    <aside class="stack">
        <section class="card">
            <p class="eyebrow">PUBLICATION</p>
            <h2>{{ $entry->published_revision === null ? 'Not published yet' : 'Live revision '.$entry->published_revision }}</h2>
            <p class="muted">Publish always validates the complete About + FAQ + Support + Legal snapshot. This prevents a partially updated information experience.</p>
            <form method="post" action="{{ route('admin.content.information.publish', ['section' => $section]) }}" class="section-space">
                @csrf
                <input type="hidden" name="revision" value="{{ $entry->revision }}">
                <button class="btn primary" type="submit">Publish validated snapshot</button>
            </form>
        </section>

        <section class="card">
            <p class="eyebrow">IMMUTABLE HISTORY</p>
            <h2>Restore to draft</h2>
            <p class="muted">Restore never auto-publishes. It copies a historical snapshot into a new private draft for review.</p>
            @forelse ($entry->revisions as $revision)
                <div class="locked section-space">
                    <small>Revision {{ $revision->revision }} · {{ $revision->action }}</small>
                    <form method="post" action="{{ route('admin.content.information.restore', ['section' => $section]) }}" class="section-space">
                        @csrf
                        <input type="hidden" name="revision" value="{{ $entry->revision }}">
                        <input type="hidden" name="source_revision" value="{{ $revision->revision }}">
                        <button class="btn secondary" type="submit">Restore revision {{ $revision->revision }}</button>
                    </form>
                </div>
            @empty
                <p class="muted">No history yet.</p>
            @endforelse
        </section>

        <section class="card">
            <p class="eyebrow">PROTECTED BOUNDARIES</p>
            <div class="locked"><strong>No arbitrary URLs, HTML, JavaScript, Product Master fields, ASIN/Pantone identity or executable navigation are accepted by this content family.</strong></div>
        </section>
    </aside>
</div>
@endsection
