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
            'color' => ['required', 'filled', 'string', 'max:80'],

            'id' => ['prohibited'],
            'product_id' => ['prohibited'],
            'pantone' => ['prohibited'],
            'asin' => ['prohibited'],
            'sort_order' => ['prohibited'],
            'purchase_url' => ['prohibited'],
        ];
    }
}
