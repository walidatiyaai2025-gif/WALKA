<?php

namespace App\Services;

use App\Exceptions\ContentRevisionConflictException;
use App\Models\ContentEntry;
use App\Models\ContentRevision;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;
use JsonException;

final class ContentRevisionService
{
    private const MAX_PAYLOAD_BYTES = 65536;

    public function __construct(private readonly GovernedContentPayloadService $governance) {}

    public function saveDraft(
        string $contentKey,
        string $contentType,
        array $payload,
        int $expectedRevision,
        string $actorFingerprint,
    ): ContentEntry {
        $payload = $this->validateAndNormalize(
            contentKey: $contentKey,
            contentType: $contentType,
            payload: $payload,
            expectedRevision: $expectedRevision,
            actorFingerprint: $actorFingerprint,
        );

        return DB::transaction(function () use (
            $contentKey,
            $contentType,
            $payload,
            $expectedRevision,
            $actorFingerprint,
        ): ContentEntry {
            $entry = ContentEntry::query()
                ->where('content_key', $contentKey)
                ->lockForUpdate()
                ->first();

            if ($entry === null) {
                $this->assertRevision($contentKey, $expectedRevision, 0);

                $entry = ContentEntry::query()->create([
                    'content_key' => $contentKey,
                    'content_type' => $contentType,
                    'revision' => 1,
                    'published_revision' => null,
                    'draft_payload' => $payload,
                    'published_payload' => null,
                    'published_at' => null,
                ]);

                $this->recordRevision(
                    entry: $entry,
                    revision: 1,
                    action: 'draft_created',
                    payload: $payload,
                    sourceRevision: null,
                    actorFingerprint: $actorFingerprint,
                );

                return $entry->refresh();
            }

            $this->assertContentType($entry, $contentType);
            $this->assertRevision($contentKey, $expectedRevision, $entry->revision);

            if ($this->payloadsEqual($entry->draft_payload, $payload)) {
                return $entry->refresh();
            }

            $nextRevision = $entry->revision + 1;
            $entry->draft_payload = $payload;
            $entry->revision = $nextRevision;
            $entry->save();

            $this->recordRevision(
                entry: $entry,
                revision: $nextRevision,
                action: 'draft_updated',
                payload: $payload,
                sourceRevision: null,
                actorFingerprint: $actorFingerprint,
            );

            return $entry->refresh();
        });
    }

    public function publish(
        string $contentKey,
        int $expectedRevision,
        string $actorFingerprint,
    ): ContentEntry {
        $this->validateExistingWrite($contentKey, $expectedRevision, $actorFingerprint);

        return DB::transaction(function () use ($contentKey, $expectedRevision, $actorFingerprint): ContentEntry {
            $entry = ContentEntry::query()
                ->where('content_key', $contentKey)
                ->lockForUpdate()
                ->firstOrFail();

            $this->assertRevision($contentKey, $expectedRevision, $entry->revision);
            $this->governance->validate($entry->content_type, $entry->draft_payload ?? []);

            if (
                $entry->published_revision !== null
                && $this->payloadsEqual($entry->published_payload, $entry->draft_payload)
            ) {
                return $entry->refresh();
            }

            $sourceRevision = $entry->revision;
            $nextRevision = $sourceRevision + 1;
            $entry->published_payload = $entry->draft_payload;
            $entry->published_revision = $nextRevision;
            $entry->published_at = now();
            $entry->revision = $nextRevision;
            $entry->save();

            $this->recordRevision(
                entry: $entry,
                revision: $nextRevision,
                action: 'published',
                payload: $entry->draft_payload,
                sourceRevision: $sourceRevision,
                actorFingerprint: $actorFingerprint,
            );

            return $entry->refresh();
        });
    }

    public function restoreDraftFromRevision(
        string $contentKey,
        int $revisionToRestore,
        int $expectedRevision,
        string $actorFingerprint,
        ?string $reason = null,
    ): ContentEntry {
        $this->validateExistingWrite($contentKey, $expectedRevision, $actorFingerprint);
        $reason = $this->normalizeRestoreReason($reason);

        Validator::make(
            ['revision_to_restore' => $revisionToRestore],
            ['revision_to_restore' => ['required', 'integer', 'min:1']],
        )->validate();

        return DB::transaction(function () use (
            $contentKey,
            $revisionToRestore,
            $expectedRevision,
            $actorFingerprint,
            $reason,
        ): ContentEntry {
            $entry = ContentEntry::query()
                ->where('content_key', $contentKey)
                ->lockForUpdate()
                ->firstOrFail();

            $this->assertRevision($contentKey, $expectedRevision, $entry->revision);

            $source = ContentRevision::query()
                ->where('content_entry_id', $entry->id)
                ->where('revision', $revisionToRestore)
                ->firstOrFail();

            $restoredPayload = $this->governance->validate($entry->content_type, $source->payload ?? []);

            if ($this->payloadsEqual($entry->draft_payload, $restoredPayload)) {
                return $entry->refresh();
            }

            $nextRevision = $entry->revision + 1;
            $entry->draft_payload = $restoredPayload;
            $entry->revision = $nextRevision;
            $entry->save();

            $this->recordRevision(
                entry: $entry,
                revision: $nextRevision,
                action: 'draft_restored',
                payload: $restoredPayload,
                sourceRevision: $revisionToRestore,
                actorFingerprint: $actorFingerprint,
                reason: $reason,
            );

            return $entry->refresh();
        });
    }

    public function history(string $contentKey): Collection
    {
        Validator::make(
            ['content_key' => $contentKey],
            ['content_key' => $this->contentKeyRules()],
        )->validate();

        $entry = ContentEntry::query()->where('content_key', $contentKey)->firstOrFail();

        return ContentRevision::query()
            ->where('content_entry_id', $entry->id)
            ->orderBy('revision')
            ->get();
    }

    public function publishedPayload(string $contentKey): ?array
    {
        Validator::make(
            ['content_key' => $contentKey],
            ['content_key' => $this->contentKeyRules()],
        )->validate();

        return ContentEntry::query()
            ->where('content_key', $contentKey)
            ->value('published_payload');
    }

    private function validateAndNormalize(
        string $contentKey,
        string $contentType,
        array $payload,
        int $expectedRevision,
        string $actorFingerprint,
    ): array {
        Validator::make([
            'content_key' => $contentKey,
            'content_type' => $contentType,
            'payload' => $payload,
            'expected_revision' => $expectedRevision,
            'actor_fingerprint' => $actorFingerprint,
        ], [
            'content_key' => $this->contentKeyRules(),
            'content_type' => ['required', 'string', 'max:64', 'regex:/^[a-z][a-z0-9._-]*$/'],
            'payload' => ['present', 'array'],
            'expected_revision' => ['required', 'integer', 'min:0'],
            'actor_fingerprint' => ['required', 'string', 'size:64', 'regex:/^[a-f0-9]{64}$/'],
        ])->validate();

        $normalized = $this->normalizeValue($payload);
        $normalized = $this->governance->validate($contentType, $normalized);
        $this->assertPayloadSize($normalized);

        return $normalized;
    }

    private function validateExistingWrite(
        string $contentKey,
        int $expectedRevision,
        string $actorFingerprint,
    ): void {
        Validator::make([
            'content_key' => $contentKey,
            'expected_revision' => $expectedRevision,
            'actor_fingerprint' => $actorFingerprint,
        ], [
            'content_key' => $this->contentKeyRules(),
            'expected_revision' => ['required', 'integer', 'min:1'],
            'actor_fingerprint' => ['required', 'string', 'size:64', 'regex:/^[a-f0-9]{64}$/'],
        ])->validate();
    }

    private function normalizeRestoreReason(?string $reason): string
    {
        $reason = trim((string) $reason);
        if ($reason === '') {
            $reason = 'Historical revision restore';
        }

        Validator::make(
            ['reason' => $reason],
            ['reason' => ['required', 'string', 'min:3', 'max:280']],
        )->validate();

        return $reason;
    }

    private function contentKeyRules(): array
    {
        return ['required', 'string', 'max:160', 'regex:/^[a-z0-9][a-z0-9._:-]*$/'];
    }

    private function assertContentType(ContentEntry $entry, string $contentType): void
    {
        if ($entry->content_type === $contentType) {
            return;
        }

        throw ValidationException::withMessages([
            'content_type' => ['The content type is immutable for an existing content key.'],
        ]);
    }

    private function assertRevision(string $contentKey, int $expected, int $current): void
    {
        if ($expected !== $current) {
            throw new ContentRevisionConflictException($contentKey, $expected, $current);
        }
    }

    private function recordRevision(
        ContentEntry $entry,
        int $revision,
        string $action,
        array $payload,
        ?int $sourceRevision,
        string $actorFingerprint,
        ?string $reason = null,
    ): void {
        ContentRevision::query()->create([
            'content_entry_id' => $entry->id,
            'revision' => $revision,
            'action' => $action,
            'payload' => $payload,
            'source_revision' => $sourceRevision,
            'reason' => $reason,
            'actor_fingerprint' => $actorFingerprint,
            'created_at' => now(),
        ]);
    }

    private function payloadsEqual(?array $left, ?array $right): bool
    {
        return $left === $right;
    }

    private function normalizeValue(mixed $value): mixed
    {
        if (! is_array($value)) {
            return $value;
        }

        if (array_is_list($value)) {
            return array_map(fn (mixed $item): mixed => $this->normalizeValue($item), $value);
        }

        ksort($value);

        foreach ($value as $key => $item) {
            $value[$key] = $this->normalizeValue($item);
        }

        return $value;
    }

    private function assertPayloadSize(array $payload): void
    {
        try {
            $json = json_encode($payload, JSON_THROW_ON_ERROR);
        } catch (JsonException) {
            throw ValidationException::withMessages([
                'payload' => ['The content payload must be valid JSON data.'],
            ]);
        }

        if (strlen($json) > self::MAX_PAYLOAD_BYTES) {
            throw ValidationException::withMessages([
                'payload' => ['The content payload may not exceed 65536 encoded bytes.'],
            ]);
        }
    }
}
