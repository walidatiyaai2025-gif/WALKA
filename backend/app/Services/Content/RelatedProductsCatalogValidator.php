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

        $knownIds = Product::query()
            ->whereIn('id', $ids)
            ->pluck('id')
            ->map(static fn ($id): string => (string) $id)
            ->all();
        $known = array_fill_keys($knownIds, true);

        foreach ($ids as $id) {
            if (! isset($known[$id])) {
                throw ValidationException::withMessages([
                    'product_ids' => [sprintf('Unknown WALKA stable product ID: %s.', $id)],
                ]);
            }
        }

        return $payload;
    }
}
