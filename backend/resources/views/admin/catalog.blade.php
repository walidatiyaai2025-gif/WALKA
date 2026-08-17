@extends('admin.layout')

@section('title', 'WALKA Admin · Dynamic Catalog')
@section('topbar', 'Dynamic catalog management')

@section('content')
<div class="page-head">
    <div>
        <p class="eyebrow">Database source of truth</p>
        <h1>Categories, products & colors</h1>
        <p class="lead">Everything listed here is stored in the database and delivered through the catalog API. Create, edit, order, show/hide or delete catalog entities without changing Flutter code.</p>
    </div>
    <span class="badge good">DB → API → APP</span>
</div>

@if ($errors->any())
    <section class="card" style="border-color:#b42318">
        <strong>Please fix the catalog validation errors.</strong>
        <ul>@foreach ($errors->all() as $error)<li>{{ $error }}</li>@endforeach</ul>
    </section>
@endif

<section class="card section-space">
    <p class="eyebrow">Categories</p>
    <h2>Create category</h2>
    <form method="post" action="{{ route('admin.catalog.categories.store') }}" class="grid two">
        @csrf
        <div class="field"><label>Category key</label><input name="id" placeholder="office-organization" maxlength="80" required></div>
        <div class="field"><label>Display name</label><input name="name" placeholder="Office Organization" maxlength="120" required></div>
        <div class="field"><label>Sort order</label><input type="number" name="sort_order" min="0" max="65535" value="{{ $categories->count() }}" required></div>
        <label style="display:flex;gap:8px;align-items:center"><input type="checkbox" name="is_visible" value="1" checked> Visible in app</label>
        <div><button class="btn navy" type="submit">Add category</button></div>
    </form>

    @if ($categories->isNotEmpty())
        <div class="table-wrap section-space">
            <table>
                <thead><tr><th>Key</th><th>Name</th><th>Order</th><th>Visible</th><th>Revision</th><th>Actions</th></tr></thead>
                <tbody>
                @foreach ($categories as $category)
                    <tr>
                        <td><code>{{ $category->id }}</code></td>
                        <td>
                            <form id="category-{{ md5($category->id) }}" method="post" action="{{ route('admin.catalog.categories.update', ['category' => $category->id]) }}">
                                @csrf @method('PATCH')
                                <input type="hidden" name="revision" value="{{ $category->revision }}">
                                <input name="name" value="{{ $category->name }}" maxlength="120" required>
                            </form>
                        </td>
                        <td><input form="category-{{ md5($category->id) }}" type="number" name="sort_order" min="0" max="65535" value="{{ $category->sort_order }}" required></td>
                        <td><input form="category-{{ md5($category->id) }}" type="checkbox" name="is_visible" value="1" {{ $category->is_visible ? 'checked' : '' }}></td>
                        <td>{{ $category->revision }}</td>
                        <td style="display:flex;gap:8px;flex-wrap:wrap">
                            <button class="btn secondary" type="submit" form="category-{{ md5($category->id) }}">Save</button>
                            <form method="post" action="{{ route('admin.catalog.categories.destroy', ['category' => $category->id]) }}" onsubmit="return confirm('Delete this category? Products must be moved first.')">
                                @csrf @method('DELETE')
                                <input type="hidden" name="revision" value="{{ $category->revision }}">
                                <button class="btn secondary" type="submit">Delete</button>
                            </form>
                        </td>
                    </tr>
                @endforeach
                </tbody>
            </table>
        </div>
    @endif
</section>

<section class="card section-space">
    <p class="eyebrow">Products</p>
    <h2>Create product</h2>
    @if ($categories->isEmpty())
        <p class="lead">Create a category first.</p>
    @else
        <form method="post" action="{{ route('admin.catalog.products.store') }}" class="stack">
            @csrf
            <div class="grid two">
                <div class="field"><label>Product key</label><input name="id" placeholder="new-product" maxlength="100" required></div>
                <div class="field"><label>Product name</label><input name="name" maxlength="160" required></div>
                <div class="field"><label>Category</label><select name="category_id" required>@foreach ($categories as $category)<option value="{{ $category->id }}">{{ $category->name }}</option>@endforeach</select></div>
                <div class="field"><label>Sort order</label><input type="number" name="sort_order" min="0" max="65535" value="{{ $products->count() }}" required></div>
            </div>
            <div class="field"><label>Short description · customer-facing</label><textarea name="short_description" maxlength="500" placeholder="A concise product description shown on supported storefront surfaces."></textarea></div>
            <div class="field"><label>Features / highlights · one per line</label><textarea name="features_text" maxlength="5000"></textarea></div>
            <div class="field"><label>Facts · JSON object</label><textarea name="facts_json" maxlength="20000">{}</textarea></div>
            <label style="display:flex;gap:8px;align-items:center"><input type="checkbox" name="is_visible" value="1" checked> Visible in app</label>
            <div><button class="btn navy" type="submit">Add product</button></div>
        </form>
    @endif
</section>

@if ($products->isEmpty())
    <section class="card section-space"><h2>No products yet</h2><p class="lead">The app catalog will stay unavailable until a visible product with a visible color/variant exists.</p></section>
@else
<div class="stack section-space">
@foreach ($products as $product)
    <article class="card">
        <div class="page-head" style="margin-bottom:18px;align-items:center">
            <div>
                <p class="eyebrow">{{ $product->categoryEntity?->name ?? $product->category_id ?? $product->category }}</p>
                <h2>{{ $product->name }}</h2>
                <div class="muted" style="font-size:12px"><code>{{ $product->id }}</code> · revision {{ $product->revision }} · {{ $product->is_visible ? 'VISIBLE' : 'HIDDEN' }}</div>
            </div>
            <span class="badge {{ $product->is_visible ? 'good' : 'lock' }}">{{ $product->variants->count() }} COLOR{{ $product->variants->count() === 1 ? '' : 'S' }}</span>
        </div>

        <form method="post" action="{{ route('admin.catalog.products.update', ['product' => $product->id]) }}" class="stack">
            @csrf @method('PATCH')
            <input type="hidden" name="revision" value="{{ $product->revision }}">
            <div class="grid two">
                <div class="field"><label>Product name</label><input name="name" value="{{ $product->name }}" maxlength="160" required></div>
                <div class="field"><label>Category</label><select name="category_id" required>@foreach ($categories as $category)<option value="{{ $category->id }}" {{ ($product->category_id ?? $product->category) === $category->id ? 'selected' : '' }}>{{ $category->name }}</option>@endforeach</select></div>
                <div class="field"><label>Sort order</label><input type="number" name="sort_order" min="0" max="65535" value="{{ $product->sort_order }}" required></div>
                <label style="display:flex;gap:8px;align-items:center"><input type="checkbox" name="is_visible" value="1" {{ $product->is_visible ? 'checked' : '' }}> Visible in app</label>
            </div>
            <div class="field"><label>Short description · customer-facing</label><textarea name="short_description" maxlength="500">{{ $product->short_description }}</textarea></div>
            <div class="field"><label>Features / highlights · one per line</label><textarea name="features_text" maxlength="5000">{{ implode("\n", $product->features ?? []) }}</textarea></div>
            <div class="field"><label>Facts · JSON object</label><textarea name="facts_json" maxlength="20000">{{ json_encode($product->facts ?? [], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) }}</textarea></div>
            <div style="display:flex;gap:8px;flex-wrap:wrap"><button class="btn navy" type="submit">Save product</button></div>
        </form>
        <form class="section-space" method="post" action="{{ route('admin.catalog.products.destroy', ['product' => $product->id]) }}" onsubmit="return confirm('Delete this product and all of its colors?')">
            @csrf @method('DELETE')
            <input type="hidden" name="revision" value="{{ $product->revision }}">
            <button class="btn secondary" type="submit">Delete product</button>
        </form>

        <div class="section-space">
            <p class="eyebrow">Colors / variants</p>
            <div class="table-wrap">
                <table>
                    <thead><tr><th>ID</th><th>Color</th><th>Swatch</th><th>Pantone</th><th>ASIN</th><th>Order</th><th>Visible</th><th>Actions</th></tr></thead>
                    <tbody>
                    @forelse ($product->variants as $variant)
                        @php($vf = 'variant-'.md5($variant->id))
                        <tr>
                            <td><code>{{ $variant->id }}</code><div class="muted">rev {{ $variant->revision }}</div></td>
                            <td><form id="{{ $vf }}" method="post" action="{{ route('admin.catalog.variants.update', ['variant' => $variant->id]) }}">@csrf @method('PATCH')<input type="hidden" name="revision" value="{{ $variant->revision }}"><input name="color" value="{{ $variant->color }}" maxlength="80" required></form></td>
                            <td><input form="{{ $vf }}" name="swatch_hex" value="{{ $variant->swatch_hex }}" placeholder="#436B73" pattern="#[0-9A-Fa-f]{6}"></td>
                            <td><input form="{{ $vf }}" name="pantone" value="{{ $variant->pantone }}" maxlength="80"></td>
                            <td><input form="{{ $vf }}" name="asin" value="{{ $variant->asin }}" maxlength="10" required></td>
                            <td><input form="{{ $vf }}" type="number" name="sort_order" min="0" max="65535" value="{{ $variant->sort_order }}" required style="width:90px"></td>
                            <td><input form="{{ $vf }}" type="checkbox" name="is_visible" value="1" {{ $variant->is_visible ? 'checked' : '' }}></td>
                            <td style="display:flex;gap:8px;flex-wrap:wrap">
                                <button class="btn secondary" type="submit" form="{{ $vf }}">Save</button>
                                <form method="post" action="{{ route('admin.catalog.variants.destroy', ['variant' => $variant->id]) }}" onsubmit="return confirm('Delete this color/variant?')">@csrf @method('DELETE')<input type="hidden" name="revision" value="{{ $variant->revision }}"><button class="btn secondary" type="submit">Delete</button></form>
                            </td>
                        </tr>
                    @empty
                        <tr><td colspan="8">No colors yet.</td></tr>
                    @endforelse
                    </tbody>
                </table>
            </div>

            <form class="stack section-space" method="post" action="{{ route('admin.catalog.variants.store', ['product' => $product->id]) }}">
                @csrf
                <h3>Add color / variant</h3>
                <div class="grid two">
                    <div class="field"><label>Variant key</label><input name="variant_key" placeholder="navy" maxlength="60" required></div>
                    <div class="field"><label>Display color</label><input name="color" placeholder="Navy" maxlength="80" required></div>
                    <div class="field"><label>Swatch hex</label><input name="swatch_hex" placeholder="#003366" pattern="#[0-9A-Fa-f]{6}"></div>
                    <div class="field"><label>Pantone</label><input name="pantone" maxlength="80"></div>
                    <div class="field"><label>ASIN</label><input name="asin" maxlength="10" required></div>
                    <div class="field"><label>Sort order</label><input type="number" name="sort_order" min="0" max="65535" value="{{ $product->variants->count() }}" required></div>
                </div>
                <label style="display:flex;gap:8px;align-items:center"><input type="checkbox" name="is_visible" value="1" checked> Visible in app</label>
                <div><button class="btn navy" type="submit">Add color</button></div>
            </form>
        </div>
    </article>
@endforeach
</div>
@endif

<section class="card section-space">
    <p class="eyebrow">Runtime rule</p>
    <h2>No compiled catalog fallback</h2>
    <p class="lead">Seed data may initialize a new database once. Runtime products, categories and colors are controlled by this database and public API; the mobile app must use the remote catalog or its last-known-good cache only. Product featured placement remains governed separately by Mobile Content → Home Featured, avoiding a second competing featured flag in Catalog.</p>
</section>
@endsection
