<?php

namespace App\Http\Requests\Api\V1\Admin;

use Illuminate\Foundation\Http\FormRequest;

final class UpdateCatalogVariantRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'revision' => ['required', 'integer', 'min:1'],
            'color' => ['sometimes', 'filled', 'string', 'max:80'],
            'swatch_hex' => ['sometimes', 'nullable', 'regex:/^#[0-9A-Fa-f]{6}$/'],
            'pantone' => ['sometimes', 'nullable', 'string', 'max:80'],
            'asin' => ['sometimes', 'string', 'size:10', 'regex:/^[A-Za-z0-9]{10}$/'],
            'sort_order' => ['sometimes', 'integer', 'min:0', 'max:65535'],
            'is_visible' => ['sometimes', 'boolean'],

            'id' => ['prohibited'],
            'product_id' => ['prohibited'],
            'purchase_url' => ['prohibited'],
        ];
    }

    protected function prepareForValidation(): void
    {
        if ($this->has('asin')) {
            $this->merge(['asin' => strtoupper((string) $this->input('asin'))]);
        }
        if ($this->filled('swatch_hex')) {
            $this->merge(['swatch_hex' => strtoupper((string) $this->input('swatch_hex'))]);
        }
    }
}
