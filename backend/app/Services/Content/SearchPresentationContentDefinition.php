<?php

namespace App\Services\Content;

use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

final class SearchPresentationContentDefinition
{
    public const KEY = 'search.presentation';

    public const TYPE = 'search.presentation';

    public const SCHEMA_VERSION = 1;

    /**
     * @return array<string, mixed>
     */
    public static function defaultPayload(): array
    {
        return [
            'heading' => 'Search WALKA',
            'supporting_copy' => 'Explore the complete released WALKA catalog by collection, color, or product detail.',
            'placeholder' => 'Search organizers, colors, details…',
            'empty_title' => 'No WALKA matches yet',
            'empty_body' => 'Try another color, collection, or product detail.',
            'featured_variant_ids' => [
                'drawer-organizer:white',
                'drawer-organizer:gray',
                'lunch-box:blue',
                'lunch-box:pink',
                'lunch-box:green',
            ],
            'filter_labels' => [
                ['id' => 'all', 'label' => 'All'],
                ['id' => 'drawer-organization', 'label' => 'Drawer'],
                ['id' => 'lunch', 'label' => 'Lunch'],
            ],
        ];
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array{
     *   heading: string,
     *   supporting_copy: string,
     *   placeholder: string,
     *   empty_title: string,
     *   empty_body: string,
     *   featured_variant_ids: list<string>,
     *   filter_labels: list<array{id: string, label: string}>
     * }
     */
    public static function validateAndNormalize(array $payload): array
    {
        $candidate = [
            'heading' => self::trimmed($payload['heading'] ?? null),
            'supporting_copy' => self::trimmed($payload['supporting_copy'] ?? null),
            'placeholder' => self::trimmed($payload['placeholder'] ?? null),
            'empty_title' => self::trimmed($payload['empty_title'] ?? null),
            'empty_body' => self::trimmed($payload['empty_body'] ?? null),
        ];

        $validated = Validator::make($candidate, [
            'heading' => ['required', 'string', 'max:80'],
            'supporting_copy' => ['required', 'string', 'max:240'],
            'placeholder' => ['required', 'string', 'max:100'],
            'empty_title' => ['required', 'string', 'max:100'],
            'empty_body' => ['required', 'string', 'max:240'],
        ])->validate();

        $variantIds = $payload['featured_variant_ids'] ?? null;
        if (! is_array($variantIds) || ! array_is_list($variantIds) || $variantIds === []) {
            throw ValidationException::withMessages([
                'featured_variant_ids' => ['Search merchandising must contain an ordered released-variant list.'],
            ]);
        }

        $normalizedVariantIds = [];
        foreach ($variantIds as $index => $variantId) {
            $row = Validator::make(
                ['id' => is_string($variantId) ? trim($variantId) : $variantId],
                ['id' => ['required', 'string', 'regex:/^[a-z0-9][a-z0-9-]*:[a-z0-9][a-z0-9-]*$/', 'max:160']],
            )->validate();
            $normalizedVariantIds[] = $row['id'];
        }

        if (count(array_unique($normalizedVariantIds)) !== count($normalizedVariantIds)) {
            throw ValidationException::withMessages([
                'featured_variant_ids' => ['Search merchandising variant IDs must be unique.'],
            ]);
        }

        $filterLabels = $payload['filter_labels'] ?? null;
        if (! is_array($filterLabels) || ! array_is_list($filterLabels) || $filterLabels === []) {
            throw ValidationException::withMessages([
                'filter_labels' => ['Search presentation must contain the approved filter-label set.'],
            ]);
        }

        $normalizedFilters = [];
        foreach ($filterLabels as $index => $filter) {
            if (! is_array($filter)) {
                throw ValidationException::withMessages([
                    "filter_labels.$index" => ['Filter label entry must be an object.'],
                ]);
            }

            $row = Validator::make([
                'id' => self::trimmed($filter['id'] ?? null),
                'label' => self::trimmed($filter['label'] ?? null),
            ], [
                'id' => ['required', 'string', 'regex:/^[a-z0-9][a-z0-9-]*$/', 'max:120'],
                'label' => ['required', 'string', 'max:40'],
            ])->validate();

            $normalizedFilters[] = [
                'id' => $row['id'],
                'label' => $row['label'],
            ];
        }

        $filterIds = array_column($normalizedFilters, 'id');
        if (count(array_unique($filterIds)) !== count($filterIds)) {
            throw ValidationException::withMessages([
                'filter_labels' => ['Search filter IDs must be unique.'],
            ]);
        }

        return [
            'heading' => $validated['heading'],
            'supporting_copy' => $validated['supporting_copy'],
            'placeholder' => $validated['placeholder'],
            'empty_title' => $validated['empty_title'],
            'empty_body' => $validated['empty_body'],
            'featured_variant_ids' => $normalizedVariantIds,
            'filter_labels' => $normalizedFilters,
        ];
    }

    private static function trimmed(mixed $value): mixed
    {
        return is_string($value) ? trim($value) : $value;
    }
}
