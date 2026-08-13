@extends('admin.layout')

@section('title', 'Media Library · WALKA Admin')
@section('topbar', 'Media library')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">GOVERNED MEDIA INGEST</p>
        <h1>Media library</h1>
        <p class="lead">Validate production-image bytes before they enter WALKA media workflows. Uploads are stored in private quarantine and registered as Draft only; assignment remains restricted to separately admitted Product media.</p>
    </div>
    <a class="btn primary" href="{{ route('admin.media.galleries.index') }}">Manage product galleries →</a>
</div>

<div class="grid metrics">
    <div class="card metric">
        <div class="metric-label">Registered sources</div>
        <div class="metric-value">{{ $assets->count() }}</div>
        <div class="metric-note">Latest 100 shown below</div>
    </div>
    <div class="card metric">
        <div class="metric-label">Source limit</div>
        <div class="metric-value" style="font-size:24px">{{ intdiv($maxBytes, 1024 * 1024) }} MiB</div>
        <div class="metric-note">Server-verified bytes</div>
    </div>
    <div class="card metric">
        <div class="metric-label">Dimension range</div>
        <div class="metric-value" style="font-size:22px">{{ $minDimension }}–{{ $maxDimension }} px</div>
        <div class="metric-note">Per width / height</div>
    </div>
    <div class="card metric">
        <div class="metric-label">Pixel ceiling</div>
        <div class="metric-value" style="font-size:24px">{{ intdiv($maxPixels, 1000000) }} MP</div>
        <div class="metric-note">PNG · JPEG · WebP only</div>
    </div>
</div>

<div class="grid two section-space">
    <section class="card">
        <p class="eyebrow">PRIVATE QUARANTINE</p>
        <h2>Upload source</h2>
        <p class="muted">The backend detects MIME and dimensions from bytes, validates container integrity, computes SHA-256 itself, rejects duplicate sources and mismatched filename extensions, then writes only to non-public quarantine.</p>

        <form method="post" action="{{ route('admin.media.store') }}" enctype="multipart/form-data" class="stack section-space">
            @csrf
            <div class="field">
                <label for="purpose">Purpose</label>
                <select id="purpose" name="purpose" required style="width:100%;border:1px solid #ccd8e1;border-radius:11px;background:#fff;padding:11px 12px;color:#102235">
                    @foreach ($purposes as $purpose)
                        <option value="{{ $purpose->value }}" @selected(old('purpose') === $purpose->value)>{{ ucfirst($purpose->value) }}</option>
                    @endforeach
                </select>
            </div>
            <div class="field">
                <label for="source_reference">Source / provenance reference</label>
                <input id="source_reference" name="source_reference" maxlength="255" value="{{ old('source_reference') }}" placeholder="Approved source receipt, studio job, or supplier reference" required>
            </div>
            <div class="field">
                <label for="semantic_label">Semantic label</label>
                <input id="semantic_label" name="semantic_label" maxlength="160" value="{{ old('semantic_label') }}" placeholder="Describe the real product shown" required>
            </div>
            <div class="field">
                <label for="file">Raster image</label>
                <input id="file" name="file" type="file" accept="image/png,image/jpeg,image/webp" required>
            </div>
            <button class="btn navy" type="submit">Validate & quarantine source</button>
        </form>
    </section>

    <aside class="card">
        <p class="eyebrow">FAIL-CLOSED CONTRACT</p>
        <h2>What upload does not do</h2>
        <div class="stack section-space">
            <div class="locked"><small>Lifecycle</small><strong>Every successful upload remains Draft. Admission still requires a validated canonical derivative and an explicit governed action.</strong></div>
            <div class="locked"><small>Gallery eligibility</small><strong>Only admitted <code>product</code>-purpose media with a canonical derivative can be assigned from Product Galleries.</strong></div>
            <div class="locked"><small>Runtime</small><strong>No file is copied to <code>mobile/assets/products/**</code>, no protected <code>Images/</code> file is changed, and no public media URL is created here.</strong></div>
            <div class="locked"><small>Product truth</small><strong>Product Master IDs, ASINs, Pantones, variant geometry and Amazon destinations remain outside this editor.</strong></div>
        </div>
    </aside>
</div>

<section class="card section-space">
    <p class="eyebrow">SOURCE INVENTORY</p>
    <h2>Validated source records</h2>
    @if ($assets->isEmpty())
        <div class="locked"><strong>No media sources have been registered yet.</strong></div>
    @else
        <div class="table-wrap">
            <table>
                <thead>
                    <tr><th>Asset</th><th>Purpose</th><th>Lifecycle</th><th>Source</th><th>Image</th><th>SHA-256</th><th>Derivatives</th></tr>
                </thead>
                <tbody>
                @foreach ($assets as $asset)
                    <tr>
                        <td><code>{{ $asset->id }}</code><div class="muted">{{ $asset->original_filename }}</div></td>
                        <td>{{ $asset->purpose->value }}</td>
                        <td><span class="badge {{ $asset->isAdmitted() ? 'good' : 'lock' }}">{{ strtoupper($asset->lifecycle->value) }}</span></td>
                        <td>{{ $asset->source_reference ?? '—' }}<div class="muted">{{ $asset->source_storage_disk ?? 'metadata only' }}</div></td>
                        <td>{{ $asset->original_width }}×{{ $asset->original_height }}<div class="muted">{{ number_format($asset->original_bytes / 1024, 1) }} KiB · {{ $asset->original_mime }}</div></td>
                        <td><code>{{ substr($asset->original_sha256, 0, 16) }}…</code></td>
                        <td>{{ $asset->derivatives_count }}</td>
                    </tr>
                @endforeach
                </tbody>
            </table>
        </div>
    @endif
</section>
@endsection
