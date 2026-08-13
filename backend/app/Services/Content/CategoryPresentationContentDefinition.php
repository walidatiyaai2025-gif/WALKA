<?php

namespace App\Services\Content;

use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

final class CategoryPresentationContentDefinition
{
    public const KEY = 'categories.presentation';

    public const TYPE = 'categories.presentation';

    public const SCHEMA_VERSION = 1;

    /**
     * Preserve the released Categories screen as the bundled/default order.
     * Stable category IDs come from the protected catalog category field.
     *
     * @return array<string, mixed>
     */
    public static function defaultPayload(): array
    {
        return [
            'categories' => [
                [
                    'id' => 'lunch',
                    'display_name' => 'Lunch Boxes',
                    'description' => 'Stainless steel lunch systems for organized everyday meals.',
                    'visible' => true,
                ],
                [
                    'id' => 'drawer-organization',
                    'display_name' => 'Drawer Organizers',
                    'description' => 'Expandable organizers designed to bring calm order to drawers.',
                    'visible' => true,
                ],
            ],
        ];
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array{categories: list<array{id: string, display_name: string, description: string, visible: bool}>}
     */
    public static function validateAndNormalize(array $payload): array
    {
        $categories = $payload['categories'] ?? null;
        if (! is_array($categories) || ! array_is_list($categories) || $categories === []) {
            throw ValidationException::withMessages([
                'categories' => ['Category presentation must contain an ordered category list.'],
            ]);
        }

        $normalized = [];
        foreach ($categories as $index => $category) {
            if (! is_array($category)) {
                throw ValidationException::withMessages([
                    "categories.$index" => ['Category presentation entry must be an object.'],
                ]);
            }

            $candidate = [
                'id' => is_string($category['id'] ?? null) ? trim($category['id']) : $category['id'] ?? null,
                'display_name' => is_string($category['display_name'] ?? null)
                    ? trim($category['display_name'])
                    : $category['display_name'] ?? null,
                'description' => is_string($category['description'] ?? null)
                    ? trim($category['description'])
                    : $category['description'] ?? null,
                'visible' => $category['visible'] ?? null,
            ];

            $validated = Validator::make($candidate, [
                'id' => ['required', 'string', 'regex:/^[a-z0-9][a-z0-9-]*$/', 'max:120'],
                'display_name' => ['required', 'string', 'max:80'],
                'description' => ['required', 'string', 'max:240'],
                'visible' => ['required', 'boolean'],
            ])->validate();

            $normalized[] = [
                'id' => $validated['id'],
                'display_name' => $validated['display_name'],
                'description' => $validated['description'],
                'visible' => (bool) $validated['visible'],
            ];
        }

        $ids = array_column($normalized, 'id');
        if (count(array_unique($ids)) !== count($ids)) {
            throw ValidationException::withMessages([
                'categories' => ['Category IDs must be unique.'],
            ]);
        }

        if (! collect($normalized)->contains(fn (array $category): bool => $category['visible'])) {
            throw ValidationException::withMessages([
                'categories' => ['At least one WALKA category must remain visible.'],
            ]);
        }

        return ['categories' => $normalized];
    }
}
