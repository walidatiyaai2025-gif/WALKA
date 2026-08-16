<?php

namespace App\Services\Content;

use Illuminate\Validation\ValidationException;

final class CommerceMapContentDefinition
{
    public const KEY = 'commerce.map';

    public const TYPE = 'commerce.map';

    public const SCHEMA_VERSION = 1;

    /** @var array<string, string> */
    private const MARKET_HOSTS = [
        'US' => 'www.amazon.com',
        'CA' => 'www.amazon.ca',
        'MX' => 'www.amazon.com.mx',
    ];

    /** @return array{mappings: list<array<string, mixed>>} */
    public static function defaultPayload(): array
    {
        return ['mappings' => []];
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array{mappings: list<array<string, mixed>>}
     */
    public static function validateAndNormalize(array $payload): array
    {
        $mappings = $payload['mappings'] ?? null;
        if (is_array($mappings) === false || array_is_list($mappings) === false) {
            self::fail('mappings', 'Commerce mappings must be an ordered list.');
        }
        if (count($mappings) > 100) {
            self::fail('mappings', 'Commerce mappings may not contain more than 100 entries.');
        }

        $normalized = [];
        $seen = [];
        foreach ($mappings as $index => $mapping) {
            if (is_array($mapping) === false) {
                self::fail("mappings.$index", 'Each commerce mapping must be an object.');
            }

            $variantId = self::requiredString($mapping, 'variant_id', $index);
            if (preg_match('/^[a-z0-9][a-z0-9-]*:[a-z0-9][a-z0-9-]*$/', $variantId) !== 1) {
                self::fail("mappings.$index.variant_id", 'Variant ID has an invalid format.');
            }

            $market = strtoupper(self::requiredString($mapping, 'region_market', $index));
            if (isset(self::MARKET_HOSTS[$market]) === false) {
                self::fail("mappings.$index.region_market", 'Region market is not an approved Amazon market.');
            }

            $asin = strtoupper(self::requiredString($mapping, 'asin', $index));
            if (preg_match('/^[A-Z0-9]{10}$/', $asin) !== 1) {
                self::fail("mappings.$index.asin", 'ASIN must contain exactly 10 alphanumeric characters.');
            }

            $variantRevision = $mapping['variant_revision'] ?? null;
            if (is_int($variantRevision) === false || $variantRevision < 1) {
                self::fail("mappings.$index.variant_revision", 'Variant revision must be a positive integer.');
            }

            $ctaKey = self::machineKey($mapping, 'cta_key', $index);
            $disclosureKey = self::machineKey($mapping, 'disclosure_key', $index);
            $entitlements = self::entitlements($mapping['entitlements'] ?? null, $index);
            $active = $mapping['active'] ?? null;
            if (is_bool($active) === false) {
                self::fail("mappings.$index.active", 'Active must be a boolean.');
            }

            $trace = self::trace($mapping['trace'] ?? null, $index);
            $identity = $variantId.'|'.$market;
            if (isset($seen[$identity])) {
                self::fail("mappings.$index", 'Variant/market mappings must be unique.');
            }
            $seen[$identity] = true;

            $normalized[] = [
                'variant_id' => $variantId,
                'variant_revision' => $variantRevision,
                'region_market' => $market,
                'asin' => $asin,
                'destination_url' => self::canonicalDestination($market, $asin),
                'cta_key' => $ctaKey,
                'disclosure_key' => $disclosureKey,
                'entitlements' => $entitlements,
                'active' => $active,
                'trace' => $trace,
            ];
        }

        usort($normalized, static fn (array $left, array $right): int => [
            $left['variant_id'], $left['region_market'],
        ] <=> [
            $right['variant_id'], $right['region_market'],
        ]);

        return ['mappings' => $normalized];
    }

    public static function canonicalDestination(string $market, string $asin): string
    {
        $market = strtoupper(trim($market));
        $asin = strtoupper(trim($asin));
        if (isset(self::MARKET_HOSTS[$market]) === false || preg_match('/^[A-Z0-9]{10}$/', $asin) !== 1) {
            self::fail('destination', 'Cannot build an Amazon destination from an unapproved market or malformed ASIN.');
        }

        return 'https://'.self::MARKET_HOSTS[$market].'/dp/'.$asin;
    }

    public static function normalizeMarket(string $market): string
    {
        $market = strtoupper(trim($market));
        if (isset(self::MARKET_HOSTS[$market]) === false) {
            self::fail('region_market', 'Region market is not an approved Amazon market.');
        }

        return $market;
    }

    /** @param  array<string, mixed>  $mapping */
    private static function requiredString(array $mapping, string $field, int $index): string
    {
        $value = $mapping[$field] ?? null;
        if (is_string($value) === false || trim($value) === '') {
            self::fail("mappings.$index.$field", ucfirst(str_replace('_', ' ', $field)).' is required.');
        }
        $value = trim($value);
        if (strlen($value) > 160) {
            self::fail("mappings.$index.$field", ucfirst(str_replace('_', ' ', $field)).' is too long.');
        }

        return $value;
    }

    /** @param  array<string, mixed>  $mapping */
    private static function machineKey(array $mapping, string $field, int $index): string
    {
        $value = self::requiredString($mapping, $field, $index);
        if (preg_match('/^[a-z][a-z0-9._-]{1,63}$/', $value) !== 1) {
            self::fail("mappings.$index.$field", 'Key must be a stable lowercase machine key.');
        }

        return $value;
    }

    /** @return list<string> */
    private static function entitlements(mixed $value, int $index): array
    {
        if (is_array($value) === false || array_is_list($value) === false || $value === [] || count($value) > 8) {
            self::fail("mappings.$index.entitlements", 'Entitlements must contain between 1 and 8 stable keys.');
        }
        $normalized = [];
        foreach ($value as $entitlementIndex => $entitlement) {
            if (is_string($entitlement) === false) {
                self::fail("mappings.$index.entitlements.$entitlementIndex", 'Entitlement must be a string.');
            }
            $entitlement = trim($entitlement);
            if (preg_match('/^[a-z][a-z0-9._-]{1,63}$/', $entitlement) !== 1) {
                self::fail("mappings.$index.entitlements.$entitlementIndex", 'Entitlement must be a stable lowercase machine key.');
            }
            $normalized[] = $entitlement;
        }
        $normalized = array_values(array_unique($normalized));
        sort($normalized);

        return $normalized;
    }

    /** @return array{source: string, reference: string|null} */
    private static function trace(mixed $value, int $index): array
    {
        if (is_array($value) === false) {
            self::fail("mappings.$index.trace", 'Trace metadata is required.');
        }
        $source = $value['source'] ?? null;
        $reference = $value['reference'] ?? null;
        if (is_string($source) === false || preg_match('/^[a-z][a-z0-9._-]{1,63}$/', trim($source)) !== 1) {
            self::fail("mappings.$index.trace.source", 'Trace source must be a stable lowercase machine key.');
        }
        if ($reference !== null && (is_string($reference) === false || trim($reference) === '' || strlen(trim($reference)) > 160)) {
            self::fail("mappings.$index.trace.reference", 'Trace reference must be null or a non-empty string up to 160 characters.');
        }

        return [
            'source' => trim($source),
            'reference' => $reference === null ? null : trim($reference),
        ];
    }

    private static function fail(string $field, string $message): never
    {
        throw ValidationException::withMessages([$field => [$message]]);
    }
}
