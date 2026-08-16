<?php

namespace App\Services;

use App\Models\ProductVariant;
use App\Services\Content\CommerceMapContentDefinition;
use Illuminate\Validation\ValidationException;

final class GovernedContentPayloadService
{
    /** @param array<string, mixed> $payload @return array<string, mixed> */
    public function validate(string $contentType, array $payload): array
    {
        if ($contentType !== CommerceMapContentDefinition::TYPE) {
            return $payload;
        }

        $normalized = CommerceMapContentDefinition::validateAndNormalize($payload);
        $variants = ProductVariant::query()
            ->orderBy('id')
            ->get()
            ->keyBy('id');

        if ($variants->isEmpty()) {
            $this->fail('mappings', 'CommerceMap cannot be validated because the canonical released-variant catalog is empty.');
        }

        $activeUsVariants = [];
        foreach ($normalized['mappings'] as $index => $mapping) {
            $variant = $variants->get($mapping['variant_id']);
            if ($variant === null) {
                $this->fail("mappings.$index.variant_id", 'Commerce mapping references an unknown canonical variant.');
            }

            $canonicalAsin = strtoupper(trim((string) $variant->asin));
            if (preg_match('/^[A-Z0-9]{10}$/', $canonicalAsin) !== 1) {
                $this->fail("mappings.$index.asin", 'The canonical Product Master ASIN is malformed; commerce delivery is blocked.');
            }
            if ($mapping['asin'] !== $canonicalAsin) {
                $this->fail("mappings.$index.asin", 'ASIN is protected Product Master truth and must match the canonical variant ASIN.');
            }
            if ((int) $variant->revision !== (int) $mapping['variant_revision']) {
                $this->fail("mappings.$index.variant_revision", 'Commerce mapping is stale because the canonical variant revision changed.');
            }

            if ($mapping['region_market'] === 'US' && $mapping['active'] === true) {
                $activeUsVariants[$mapping['variant_id']] = true;
            }
        }

        $missingUsVariants = $variants->keys()
            ->reject(static fn (string $variantId): bool => isset($activeUsVariants[$variantId]))
            ->values()
            ->all();

        if ($missingUsVariants !== []) {
            $this->fail(
                'mappings',
                'CommerceMap requires one active US mapping for every released variant. Missing: '.implode(', ', $missingUsVariants).'.',
            );
        }

        return $normalized;
    }

    private function fail(string $field, string $message): never
    {
        throw ValidationException::withMessages([$field => [$message]]);
    }
}
