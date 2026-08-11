<?php

namespace App\Services\Content;

use App\Models\ProductVariant;
use Illuminate\Validation\ValidationException;

final class HomeFeaturedCatalogValidator
{
    /**
     * @param  array{collection_variant_ids: list<string>, editorial_variant_id: string}  $payload
     * @return array{collection_variant_ids: list<string>, editorial_variant_id: string}
     */
    public function validate(array $payload): array
    {
        $ids = array_values(array_unique([
            ...$payload['collection_variant_ids'],
            $payload['editorial_variant_id'],
        ]));

        $variants = ProductVariant::query()
            ->whereIn('id', $ids)
            ->get(['id', 'product_id'])
            ->keyBy('id');

        foreach ($ids as $id) {
            if (! $variants->has($id)) {
                throw ValidationException::withMessages([
                    'variant_ids' => [sprintf('Unknown WALKA variant ID: %s.', $id)],
                ]);
            }
        }

        $collectionProductIds = array_map(
            fn (string $id): string => (string) $variants->get($id)->product_id,
            $payload['collection_variant_ids'],
        );

        if (count(array_unique($collectionProductIds)) !== count($collectionProductIds)) {
            throw ValidationException::withMessages([
                'collection_variant_ids' => [
                    'Home collection must feature two different WALKA product families.',
                ],
            ]);
        }

        return $payload;
    }
}
