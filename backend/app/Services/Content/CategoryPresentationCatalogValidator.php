<?php

namespace App\Services\Content;

use App\Models\Product;
use Illuminate\Validation\ValidationException;

final class CategoryPresentationCatalogValidator
{
    /**
     * Category presentation may change only copy/order/visibility. It must
     * contain exactly the category identities currently defined by Product
     * Master relationships and cannot create/delete/reassign membership.
     *
     * @param  array{categories: list<array{id: string, display_name: string, description: string, visible: bool}>}  $payload
     * @return array{categories: list<array{id: string, display_name: string, description: string, visible: bool}>}
     */
    public function validate(array $payload): array
    {
        $catalogIds = Product::query()
            ->orderBy('sort_order')
            ->pluck('category')
            ->filter(fn (mixed $value): bool => is_string($value) && $value !== '')
            ->unique()
            ->values()
            ->all();

        $payloadIds = array_column($payload['categories'], 'id');
        $missing = array_values(array_diff($catalogIds, $payloadIds));
        $unknown = array_values(array_diff($payloadIds, $catalogIds));

        if ($missing !== [] || $unknown !== [] || count($payloadIds) !== count($catalogIds)) {
            throw ValidationException::withMessages([
                'categories' => [sprintf(
                    'Category presentation must preserve the complete Product Master category set. Missing: %s. Unknown: %s.',
                    $missing === [] ? 'none' : implode(', ', $missing),
                    $unknown === [] ? 'none' : implode(', ', $unknown),
                )],
            ]);
        }

        return $payload;
    }
}
