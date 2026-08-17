<?php

namespace App\Http\Requests\Api\V1\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

final class UpdateCatalogProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'revision' => ['required', 'integer', 'min:1'],
            'name' => ['sometimes', 'filled', 'string', 'max:160'],
            'short_description' => ['sometimes', 'nullable', 'string', 'max:500'],
            'category_id' => ['sometimes', 'string', Rule::exists('catalog_categories', 'id')],
            'features' => ['sometimes', 'array', 'max:20'],
            'features.*' => ['filled', 'string', 'max:180'],
            'facts' => ['sometimes', 'array'],
            'sort_order' => ['sometimes', 'integer', 'min:0', 'max:65535'],
            'is_visible' => ['sometimes', 'boolean'],

            'id' => ['missing'],
            'category' => ['missing'],
            'variants' => ['missing'],
        ];
    }
}
