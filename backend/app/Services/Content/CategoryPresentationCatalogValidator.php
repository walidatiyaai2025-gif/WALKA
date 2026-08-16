<?php

namespace App\Services\Content;

use App\Models\CatalogCategory;
use Illuminate\Validation\ValidationException;

final class CategoryPresentationCatalogValidator
{
    /**
     * Presentation is an optional overlay over the dynamic catalog. It may
     * reorder/rename/describe current visible categories, but it cannot invent
     * identities. New Dashboard categories do not invalidate an older
     * published overlay; clients fall back to the catalog category name when a
     * presentation row is absent.
     *
     * @param  array{categories: list<array{id: string, display_name: string, description: string, visible: bool}>}  $payload
     * @return array{categories: list<array{id: string, display_name: string, description: string, visible: bool}>}
     */
    public function validate(array $payload): array
    {
        $catalogIds = CatalogCategory::query()
            ->where('is_visible', true)
            ->orderBy('sort_order')
            ->orderBy('id')
            ->pluck('id')
            ->all();

        $payloadIds = array_column($payload['categories'], 'id');
        $unknown = array_values(array_diff($payloadIds, $catalogIds));

        if ($unknown !== []) {
            throw ValidationException::withMessages([
                'categories' => [sprintf(
                    'Category presentation contains identities that are not visible in the Dashboard catalog: %s.',
                    implode(', ', $unknown),
                )],
            ]);
        }

        return $payload;
    }
}
