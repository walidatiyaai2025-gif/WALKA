<?php

namespace App\Services\Content;

use App\Models\CatalogCategory;
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
        $visibleVariantIds = ProductVariant::query()
            ->where('is_visible', true)
            ->whereHas('product', function ($query): void {
                $query->where('is_visible', true)
                    ->whereHas('categoryEntity', fn ($category) => $category->where('is_visible', true));
            })
            ->pluck('id')
            ->all();

        $unknownVariants = array_values(array_diff(
            $payload['featured_variant_ids'],
            $visibleVariantIds,
        ));
        if ($unknownVariants !== []) {
            throw ValidationException::withMessages([
                'featured_variant_ids' => [sprintf(
                    'Search merchandising contains variants that are not visible in the Dashboard catalog: %s.',
                    implode(', ', $unknownVariants),
                )],
            ]);
        }

        $visibleCategoryIds = CatalogCategory::query()
            ->where('is_visible', true)
            ->pluck('id')
            ->all();
        $allowedFilterIds = ['all', ...$visibleCategoryIds];
        $configuredFilterIds = array_column($payload['filter_labels'], 'id');
        $unknownFilters = array_values(array_diff($configuredFilterIds, $allowedFilterIds));
        if ($unknownFilters !== []) {
            throw ValidationException::withMessages([
                'filter_labels' => [sprintf(
                    'Search filter labels contain categories that are not visible in the Dashboard catalog: %s.',
                    implode(', ', $unknownFilters),
                )],
            ]);
        }

        if (! in_array('all', $configuredFilterIds, true)) {
            throw ValidationException::withMessages([
                'filter_labels' => ['Search presentation must include the stable All filter.'],
            ]);
        }

        return $payload;
    }
}
