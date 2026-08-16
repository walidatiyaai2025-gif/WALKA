<?php

namespace App\Services\Content;

use Illuminate\Support\Facades\Validator;

final class StorefrontCopyContentDefinition
{
    public const KEY = 'storefront.copy';
    public const TYPE = 'storefront.copy';
    public const SCHEMA_VERSION = 1;

    /** @return array<string, string> */
    public static function defaultPayload(): array
    {
        return [
            'categories_heading' => 'Categories',
            'categories_body' => 'Explore the current WALKA catalog by collection.',
            'pdp_unavailable' => 'This product is no longer available.',
            'pdp_colors_label' => 'Colors',
            'pdp_features_label' => 'Features',
            'pdp_details_label' => 'Details',
            'pdp_buy_label' => 'Buy on Amazon',
            'pdp_asin_label' => 'ASIN',
        ];
    }

    /** @return array<string, array<int, string>> */
    public static function rules(): array
    {
        return [
            'categories_heading' => ['required', 'string', 'max:80'],
            'categories_body' => ['required', 'string', 'max:240'],
            'pdp_unavailable' => ['required', 'string', 'max:160'],
            'pdp_colors_label' => ['required', 'string', 'max:60'],
            'pdp_features_label' => ['required', 'string', 'max:60'],
            'pdp_details_label' => ['required', 'string', 'max:60'],
            'pdp_buy_label' => ['required', 'string', 'max:80'],
            'pdp_asin_label' => ['required', 'string', 'max:40'],
        ];
    }

    /** @param array<string, mixed> $payload @return array<string, string> */
    public static function validateAndNormalize(array $payload): array
    {
        $normalized = [];
        foreach (array_keys(self::defaultPayload()) as $key) {
            $value = $payload[$key] ?? null;
            $normalized[$key] = is_string($value) ? trim($value) : $value;
        }

        return Validator::make($normalized, self::rules())->validate();
    }

    /** @param array<string, mixed>|null $payload @return array<string, string> */
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
