<?php

namespace App\Services\Content;

use Illuminate\Validation\ValidationException;

final class HomeFeaturedContentDefinition
{
    public const KEY = 'home.featured';

    public const TYPE = 'home.featured';

    public const SCHEMA_VERSION = 1;

    /**
     * Validate presentation structure only. The two collection identities and
     * editorial identity always come from the current Dashboard catalog through
     * the Admin bootstrap/validator; no Product or Variant IDs belong here.
     *
     * @param  array<string, mixed>  $payload
     * @return array{collection_variant_ids: list<string>, editorial_variant_id: string}
     */
    public static function validateAndNormalize(array $payload): array
    {
        $collection = $payload['collection_variant_ids'] ?? null;
        $editorial = $payload['editorial_variant_id'] ?? null;

        if (! is_array($collection) || ! array_is_list($collection) || count($collection) !== 2) {
            self::fail('collection_variant_ids', 'Home collection must contain exactly two ordered Dashboard variant IDs.');
        }

        $normalizedCollection = [];
        foreach ($collection as $index => $variantId) {
            if (! is_string($variantId)) {
                self::fail("collection_variant_ids.$index", 'Variant ID must be a string.');
            }

            $variantId = trim($variantId);
            if (! self::validVariantId($variantId)) {
                self::fail("collection_variant_ids.$index", 'Variant ID has an invalid format.');
            }
            $normalizedCollection[] = $variantId;
        }

        if (count(array_unique($normalizedCollection)) !== 2) {
            self::fail('collection_variant_ids', 'Home collection variant IDs must be unique.');
        }

        if (! is_string($editorial)) {
            self::fail('editorial_variant_id', 'Editorial variant ID must be a string.');
        }
        $editorial = trim($editorial);
        if (! self::validVariantId($editorial)) {
            self::fail('editorial_variant_id', 'Editorial variant ID has an invalid format.');
        }

        return [
            'collection_variant_ids' => $normalizedCollection,
            'editorial_variant_id' => $editorial,
        ];
    }

    private static function validVariantId(string $variantId): bool
    {
        return preg_match('/^[a-z0-9][a-z0-9-]*:[a-z0-9][a-z0-9-]*$/', $variantId) === 1;
    }

    private static function fail(string $field, string $message): never
    {
        throw ValidationException::withMessages([$field => [$message]]);
    }
}
