<?php

namespace App\Http\Requests\Api\V1\Admin;

use Illuminate\Foundation\Http\FormRequest;

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
            'name' => ['required_without:features', 'filled', 'string', 'max:160'],
            'features' => ['required_without:name', 'array', 'max:20'],
            'features.*' => ['filled', 'string', 'max:180'],

            'id' => ['prohibited'],
            'category' => ['prohibited'],
            'facts' => ['prohibited'],
            'sort_order' => ['prohibited'],
            'variants' => ['prohibited'],
        ];
    }
}
