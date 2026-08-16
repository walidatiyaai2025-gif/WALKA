<?php

namespace App\Services\Content;

use Illuminate\Support\Facades\Validator;

final class StorefrontCopyContentDefinition
{
    public const KEY = 'storefront.copy';

    public const TYPE = 'storefront.copy';

    public const SCHEMA_VERSION = 1;

    /**
     * @return array<string, string>
     */
    public static function defaultPayload(): array
    {
        return [
            'categories_heading' => 'Categories',
            'categories_body' => 'Explore the current WALKA catalog by collection.',
            'favorites_heading' => 'Favorites',
            'favorites_body' => 'Saved picks from your current WALKA catalog.',
            'favorites_empty_title' => 'No saved products yet.',
            'favorites_empty_body' => 'Save a color from any product page and it will appear here.',
            'favorites_explore_label' => 'Explore products',
            'favorites_remove_label' => 'Remove',
            'pdp_unavailable' => 'This product is no longer available.',
            'pdp_colors_label' => 'Colors',
            'pdp_features_label' => 'Features',
            'pdp_details_label' => 'Details',
            'pdp_buy_label' => 'Buy on Amazon',
            'pdp_asin_label' => 'ASIN',
            'pdp_favorite_add_label' => 'Save favorite',
            'pdp_favorite_remove_label' => 'Remove favorite',
        ];
    }

    /**
     * @return array<string, array<int, string>>
     */
    public static function rules(): array
    {
        return [
            'categories_heading' => ['required', 'string', 'max:80'],
            'categories_body' => ['required', 'string', 'max:240'],
            'favorites_heading' => ['required', 'string', 'max:80'],
            'favorites_body' => ['required', 'string', 'max:240'],
            'favorites_empty_title' => ['required', 'string', 'max:100'],
            'favorites_empty_body' => ['required', 'string', 'max:240'],
            'favorites_explore_label' => ['required', 'string', 'max:80'],
            'favorites_remove_label' => ['required', 'string', 'max:60'],
            'pdp_unavailable' => ['required', 'string', 'max:160'],
            'pdp_colors_label' => ['required', 'string', 'max:60'],
            'pdp_features_label' => ['required', 'string', 'max:60'],
            'pdp_details_label' => ['required', 'string', 'max:60'],
            'pdp_buy_label' => ['required', 'string', 'max:80'],
            'pdp_asin_label' => ['required', 'string', 'max:40'],
            'pdp_favorite_add_label' => ['required', 'string', 'max:80'],
            'pdp_favorite_remove_label' => ['required', 'string', 'max:80'],
        ];
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array<string, string>
     */
    public static function validateAndNormalize(array $payload): array
    {
        $normalized = [];
        foreach (array_keys(self::defaultPayload()) as $key) {
            $value = $payload[$key] ?? null;
            $normalized[$key] = is_string($value) ? trim($value) : $value;
        }

        return Validator::make($normalized, self::rules())->validate();
    }

    /**
     * @param  array<string, mixed>|null  $payload
     * @return array<string, string>
     */
    public static function editableFields(?array $payload): array
    {
        $fields = self::defaultPayload();
        foreach (array_keys($fields) as $key) {
            $value = $payload[$key] ?? null;
            if (is_string($value)) {
                $fields[$key] = $value;
            }
        }

        return $fields;
    }
}
