<?php

namespace App\Services\Content;

use Illuminate\Validation\ValidationException;

final class RelatedProductsContentDefinition
{
    public const KEY = 'pdp.related_products';

    public const TYPE = 'pdp.related_products';

    public const SCHEMA_VERSION = 1;

    public const MAX_RELATED = 4;

    /**
     * Preserve the current two-family storefront as the safe bundled/default
     * recommendation model. Product truth and purchase destinations are never
     * duplicated into this content payload.
     *
     * @return array{relationships: list<array{product_id: string, related_product_ids: list<string>}>}
     */
    public static function defaultPayload(): array
    {
        return [
            'relationships' => [
                [
                    'product_id' => 'drawer-organizer',
                    'related_product_ids' => ['stainless-steel-bento-lunch-box'],
                ],
                [
                    'product_id' => 'stainless-steel-bento-lunch-box',
                    'related_product_ids' => ['drawer-organizer'],
                ],
            ],
        ];
    }

    /**
     * Validate the public shape only. Stable catalog existence is validated by
     * RelatedProductsCatalogValidator so this definition stays reusable across
     * Admin, API and tests without creating another catalog write path.
     *
     * Unknown/private fields are intentionally discarded.
     *
     * @param  array<string, mixed>  $payload
     * @return array{relationships: list<array{product_id: string, related_product_ids: list<string>}>}
     */
    public static function validateAndNormalize(array $payload): array
    {
        $relationships = $payload['relationships'] ?? null;
        if (! is_array($relationships) || ! array_is_list($relationships)) {
            self::fail('relationships', 'Related-product relationships must be an ordered array.');
        }

        if (count($relationships) > 64) {
            self::fail('relationships', 'Related-product configuration exceeds the supported product-family limit.');
        }

        $seenSources = [];
        $normalized = [];

        foreach ($relationships as $index => $relationship) {
            if (! is_array($relationship)) {
                self::fail("relationships.$index", 'Each related-product relationship must be an object.');
            }

            $productId = $relationship['product_id'] ?? null;
            if (! is_string($productId) || ! self::validProductId(trim($productId))) {
                self::fail("relationships.$index.product_id", 'Source product ID has an invalid stable-ID format.');
            }
            $productId = trim($productId);

            if (isset($seenSources[$productId])) {
                self::fail("relationships.$index.product_id", 'Each source product may appear only once.');
            }
            $seenSources[$productId] = true;

            $relatedIds = $relationship['related_product_ids'] ?? null;
            if (! is_array($relatedIds) || ! array_is_list($relatedIds)) {
                self::fail("relationships.$index.related_product_ids", 'Related product IDs must be an ordered array.');
            }
            if (count($relatedIds) > self::MAX_RELATED) {
                self::fail(
                    "relationships.$index.related_product_ids",
                    sprintf('A product may have at most %d related products.', self::MAX_RELATED),
                );
            }

            $seenRelated = [];
            $normalizedRelated = [];
            foreach ($relatedIds as $relatedIndex => $relatedId) {
                if (! is_string($relatedId) || ! self::validProductId(trim($relatedId))) {
                    self::fail(
                        "relationships.$index.related_product_ids.$relatedIndex",
                        'Related product ID has an invalid stable-ID format.',
                    );
                }
                $relatedId = trim($relatedId);

                if ($relatedId === $productId) {
                    self::fail(
                        "relationships.$index.related_product_ids.$relatedIndex",
                        'A product cannot recommend itself.',
                    );
                }
                if (isset($seenRelated[$relatedId])) {
                    self::fail(
                        "relationships.$index.related_product_ids.$relatedIndex",
                        'Related product IDs must be unique per source product.',
                    );
                }

                $seenRelated[$relatedId] = true;
                $normalizedRelated[] = $relatedId;
            }

            $normalized[] = [
                'product_id' => $productId,
                'related_product_ids' => $normalizedRelated,
            ];
        }

        usort(
            $normalized,
            static fn (array $left, array $right): int => $left['product_id'] <=> $right['product_id'],
        );

        return ['relationships' => $normalized];
    }

    /**
     * @param  array<string, mixed>|null  $payload
     * @return array{relationships: list<array{product_id: string, related_product_ids: list<string>}>}
     */
    public static function editablePayload(?array $payload): array
    {
        if ($payload === null) {
            return self::defaultPayload();
        }

        try {
            return self::validateAndNormalize($payload);
        } catch (ValidationException) {
            return self::defaultPayload();
        }
    }

    private static function validProductId(string $productId): bool
    {
        return preg_match('/^[a-z0-9][a-z0-9-]*$/', $productId) === 1;
    }

    private static function fail(string $field, string $message): never
    {
        throw ValidationException::withMessages([$field => [$message]]);
    }
}
