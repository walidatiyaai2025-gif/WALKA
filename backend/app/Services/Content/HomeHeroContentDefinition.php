<?php

namespace App\Services\Content;

use Illuminate\Support\Facades\Validator;

final class HomeHeroContentDefinition
{
    public const KEY = 'home.hero';

    public const TYPE = 'home.hero';

    public const SCHEMA_VERSION = 1;

    /**
     * @return array<string, string>
     */
    public static function defaultPayload(): array
    {
        return [
            'eyebrow' => "PREMIUM ORGANIZATION\nELEVATED EVERYDAY.",
            'title' => "Organize Better.\nLive Better.",
            'body' => 'Premium drawer organizers and stainless steel lunch boxes designed for calm, everyday order.',
            'shop_label' => 'SHOP PRODUCTS',
            'search_label' => 'SEARCH COLLECTION',
        ];
    }

    /**
     * Normalize an arbitrary CMS payload into the exact public Home Hero shape.
     * Unknown keys are intentionally discarded so generic CMS authoring cannot
     * accidentally make unrelated/private values public through this endpoint.
     *
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
     * Merge an incomplete/legacy draft onto safe defaults for owner editing.
     * This method does not declare the result publishable; save/publish paths
     * must still use validateAndNormalize().
     *
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

    /**
     * @return array<string, array<int, string>>
     */
    public static function rules(): array
    {
        return [
            'eyebrow' => ['required', 'string', 'max:120'],
            'title' => ['required', 'string', 'max:160'],
            'body' => ['required', 'string', 'max:500'],
            'shop_label' => ['required', 'string', 'max:64'],
            'search_label' => ['required', 'string', 'max:64'],
        ];
    }
}
