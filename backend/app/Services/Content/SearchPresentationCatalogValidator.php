<?php

namespace App\Services\Content;

use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Validation\ValidationException;

final class SearchPresentationCatalogValidator
{
    /**
     * @param  array{
     *   heading: string,
     *   supporting_copy: string,
     *   placeholder: string,
     *   empty_title: string,
     *   empty_body: string,
     *   featured_variant_ids: list<string>,
     *   filter_labels: list<array{id: string, label: string}>
     * }  $payload
     * @return array<string, mixed>
     */
    public function validate(array $payload): array
    {
        $releasedVariantIds = ProductVariant::query()
            ->pluck('id')
            ->map(fn (string $id): string => $id)
            ->sort()
            ->values()
            ->all();

        $configuredVariantIds = collect($payload['featured_variant_ids'])
            ->sort()
            ->values()
            ->all();

        if ($configuredVariantIds !== $releasedVariantIds) {
            throw ValidationException::withMessages([
                'featured_variant_ids' => [
                    'Search merchandising must contain every released variant exactly once; ordering may change but catalog membership may not.',
                ],
            ]);
        }

        $releasedCategoryIds = Product::query()
            ->pluck('category')
            ->filter(fn (mixed $category): bool => is_string($category) && $category !== '')
            ->unique()
            ->sort()
            ->values()
            ->all();

        $expectedFilterIds = collect(['all', ...$releasedCategoryIds])
            ->sort()
            ->values()
            ->all();
        $configuredFilterIds = collect($payload['filter_labels'])
            ->pluck('id')
            ->sort()
            ->values()
            ->all();

        if ($configuredFilterIds !== $expectedFilterIds) {
            throw ValidationException::withMessages([
                'filter_labels' => [
                    'Search filter labels must cover only the current protected catalog categories plus the All filter.',
                ],
            ]);
        }

        return $payload;
    }
}
