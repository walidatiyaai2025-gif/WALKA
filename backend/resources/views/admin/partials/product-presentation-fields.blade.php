<input type="hidden" name="presentation_controls" value="1">
<div class="field">
    <label for="description-{{ $product->id }}">Short description</label>
    <textarea id="description-{{ $product->id }}" name="short_description" maxlength="500">{{ $product->short_description }}</textarea>
</div>
<div class="field">
    <label for="highlights-{{ $product->id }}">Editorial highlights · one per line</label>
    <textarea id="highlights-{{ $product->id }}" name="highlights_text" maxlength="3000">{{ implode("\n", $product->highlights ?? []) }}</textarea>
</div>
<div class="field">
    <label for="presentation-order-{{ $product->id }}">Presentation order</label>
    <input id="presentation-order-{{ $product->id }}" name="presentation_order" type="number" min="0" max="65535" value="{{ $product->presentation_order }}" required>
</div>
<div class="actions">
    <label><input type="checkbox" name="is_visible" value="1" {{ $product->is_visible ? 'checked' : '' }}> Visible in public catalog</label>
    <label><input type="checkbox" name="is_featured" value="1" {{ $product->is_featured ? 'checked' : '' }}> Featured product</label>
</div>
