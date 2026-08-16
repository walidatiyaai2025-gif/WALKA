<?php

namespace App\Services;

use App\Models\ContentEntry;
use App\Models\ContentRevision;
use App\Services\Content\CommerceMapContentDefinition;
use Illuminate\Validation\ValidationException;
use JsonException;

final class CommerceMapService
{
    private readonly ContentRevisionService $content;

    private readonly GovernedContentPayloadService $governance;

    public function __construct(
        ContentRevisionService $content,
        GovernedContentPayloadService $governance,
    ) {
        $this->content = $content;
        $this->governance = $governance;
    }

    /** @param  array<string, mixed>  $payload */
    public function saveDraft(array $payload, int $expectedRevision, string $actorFingerprint): ContentEntry
    {
        return $this->content->saveDraft(
            CommerceMapContentDefinition::KEY,
            CommerceMapContentDefinition::TYPE,
            $this->validateAgainstCatalog($payload),
            $expectedRevision,
            $actorFingerprint,
        );
    }

    public function publish(int $expectedRevision, string $actorFingerprint): ContentEntry
    {
        $entry = $this->entry();
        $this->validateAgainstCatalog($entry->draft_payload ?? []);

        return $this->content->publish(
            CommerceMapContentDefinition::KEY,
            $expectedRevision,
            $actorFingerprint,
        );
    }

    public function restore(
        int $sourceRevision,
        int $expectedRevision,
        string $actorFingerprint,
        ?string $reason = null,
    ): ContentEntry {
        $entry = $this->entry();
        $source = ContentRevision::query()
            ->where('content_entry_id', $entry->id)
            ->where('revision', $sourceRevision)
            ->firstOrFail();

        $this->validateAgainstCatalog($source->payload ?? []);

        return $this->content->restoreDraftFromRevision(
            CommerceMapContentDefinition::KEY,
            $sourceRevision,
            $expectedRevision,
            $actorFingerprint,
            $reason ?? 'Governed CommerceMap restore',
        );
    }

    /**
     * @return array{payload: array{mappings: list<array<string, mixed>>}, verification: array<string, mixed>}|null
     */
    public function publishedSnapshot(): ?array
    {
        $entry = ContentEntry::query()
            ->where('content_key', CommerceMapContentDefinition::KEY)
            ->where('content_type', CommerceMapContentDefinition::TYPE)
            ->whereNotNull('published_revision')
            ->first();

        if ($entry === null || $entry->published_payload === null) {
            return null;
        }

        $payload = $this->validateAgainstCatalog($entry->published_payload);
        $payload['mappings'] = array_values(array_filter(
            $payload['mappings'],
            static fn (array $mapping): bool => $mapping['active'] === true,
        ));

        return [
            'payload' => $payload,
            'verification' => $this->verification($payload, (int) $entry->published_revision),
        ];
    }

    /** @return array<string, mixed>|null */
    public function resolve(string $variantId, string $market): ?array
    {
        $market = CommerceMapContentDefinition::normalizeMarket($market);
        $snapshot = $this->publishedSnapshot();
        if ($snapshot === null) {
            return null;
        }

        foreach ($snapshot['payload']['mappings'] as $mapping) {
            if ($mapping['variant_id'] === $variantId && $mapping['region_market'] === $market) {
                return [
                    'variant_id' => $mapping['variant_id'],
                    'region_market' => $mapping['region_market'],
                    'asin' => $mapping['asin'],
                    'destination_url' => $mapping['destination_url'],
                    'cta_key' => $mapping['cta_key'],
                    'disclosure_key' => $mapping['disclosure_key'],
                    'entitlements' => $mapping['entitlements'],
                    'trace' => $mapping['trace'],
                    'verification_digest' => $snapshot['verification']['digest'],
                ];
            }
        }

        return null;
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array{mappings: list<array<string, mixed>>}
     */
    public function validateAgainstCatalog(array $payload): array
    {
        /** @var array{mappings: list<array<string, mixed>>} $validated */
        $validated = $this->governance->validate(CommerceMapContentDefinition::TYPE, $payload);

        return $validated;
    }

    /** @param  array{mappings: list<array<string, mixed>>}  $payload */
    public function verification(array $payload, int $publishedRevision): array
    {
        try {
            $encoded = json_encode([
                'schema_version' => CommerceMapContentDefinition::SCHEMA_VERSION,
                'published_revision' => $publishedRevision,
                'payload' => $payload,
            ], JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);
        } catch (JsonException) {
            $this->fail('payload', 'CommerceMap verification payload could not be encoded.');
        }

        $markets = array_values(array_unique(array_map(
            static fn (array $mapping): string => $mapping['region_market'],
            $payload['mappings'],
        )));
        sort($markets);

        return [
            'algorithm' => 'sha256',
            'digest' => hash('sha256', $encoded),
            'schema_version' => CommerceMapContentDefinition::SCHEMA_VERSION,
            'published_revision' => $publishedRevision,
            'active_mapping_count' => count($payload['mappings']),
            'markets' => $markets,
        ];
    }

    private function entry(): ContentEntry
    {
        return ContentEntry::query()
            ->where('content_key', CommerceMapContentDefinition::KEY)
            ->where('content_type', CommerceMapContentDefinition::TYPE)
            ->firstOrFail();
    }

    private function fail(string $field, string $message): never
    {
        throw ValidationException::withMessages([$field => [$message]]);
    }
}
