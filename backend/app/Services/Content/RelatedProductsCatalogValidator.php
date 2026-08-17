<?php

namespace App\Services\Content;

use App\Models\Product;
use Illuminate\Validation\ValidationException;

final class RelatedProductsCatalogValidator
{
    /**
     * @param  array{relationships: list<array{product_id: string, related_product_ids: list<string>}>}  $payload
     * @return array{relationships: list<array{product_id: string, related_product_ids: list<string>}>}
     */
    public function validate(array $payload): array
    {
        $ids = [];
        foreach ($payload['relationships'] as $relationship) {
            $ids[] = $relationship['product_id'];
            array_push($ids, ...$relationship['related_product_ids']);
        }
        $ids = array_values(array_unique($ids));

        if ($ids === []) {
            return $payload;
        }

        $visibleIds = Product::query()
            ->whereIn('id', $ids)
            ->where('is_visible', true)
            ->whereHas('categoryEntity', fn ($query) => $query->where('is_visible', true))
            ->whereHas('variants', fn ($query) => $query->where('is_visible', true))
            ->pluck('id')
            ->map(static fn ($id): string => (string) $id)
            ->all();
        $visible = array_fill_keys($visibleIds, true);

        foreach ($ids as $id) {
            if (! isset($visible[$id])) {
                throw ValidationException::withMessages([
                    'product_ids' => [sprintf('Related-products content references an absent or hidden catalog product: %s.', $id)],
                ]);
            }
        }

        return $payload;
    }
}
