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
        foreach ($normalized['mappings'] as $index => $mapping) {
            $variant = ProductVariant::query()->find($mapping['variant_id']);
            if ($variant === null) {
                $this->fail("mappings.$index.variant_id", 'Commerce mapping references an unknown canonical variant.');
            }
            if ((int) $variant->revision !== (int) $mapping['variant_revision']) {
                $this->fail("mappings.$index.variant_revision", 'Commerce mapping is stale because the canonical variant revision changed.');
            }
        }

        return $normalized;
    }

    private function fail(string $field, string $message): never
    {
        throw ValidationException::withMessages([$field => [$message]]);
    }
}
