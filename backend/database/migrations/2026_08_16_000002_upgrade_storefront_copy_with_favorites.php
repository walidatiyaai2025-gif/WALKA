<?php

use App\Services\Content\StorefrontCopyContentDefinition;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::transaction(function (): void {
            $entry = DB::table('content_entries')
                ->where('content_key', StorefrontCopyContentDefinition::KEY)
                ->lockForUpdate()
                ->first();

            if ($entry === null) {
                return;
            }

            $draft = $this->decodePayload($entry->draft_payload);
            $published = $entry->published_payload === null
                ? null
                : $this->decodePayload($entry->published_payload);

            $defaults = StorefrontCopyContentDefinition::defaultPayload();
            $upgradedDraft = array_merge($defaults, $draft);
            $upgradedPublished = $published === null
                ? null
                : array_merge($defaults, $published);

            $draftNeedsUpgrade = $this->needsUpgrade($draft, $defaults);
            $publishedNeedsUpgrade = $published !== null
                && $this->needsUpgrade($published, $defaults);

            if ($draftNeedsUpgrade === false && $publishedNeedsUpgrade === false) {
                return;
            }

            $entryId = (int) $entry->id;
            $currentRevision = (int) $entry->revision;
            $publishedRevision = $entry->published_revision === null
                ? null
                : (int) $entry->published_revision;
            $originalPublishedRevision = $publishedRevision;
            $draftMatchedPublished = $published !== null && $draft === $published;
            $actorFingerprint = hash('sha256', 'migration:storefront-copy-favorites-v1');
            $now = now();

            if ($publishedNeedsUpgrade && $upgradedPublished !== null) {
                $currentRevision++;
                DB::table('content_revisions')->insert([
                    'content_entry_id' => $entryId,
                    'revision' => $currentRevision,
                    'action' => 'publish_migrated',
                    'payload' => $this->encodePayload($upgradedPublished),
                    'source_revision' => $originalPublishedRevision,
                    'actor_fingerprint' => $actorFingerprint,
                    'created_at' => $now,
                ]);
                $publishedRevision = $currentRevision;

                if ($draftMatchedPublished) {
                    $upgradedDraft = $upgradedPublished;
                    $draftNeedsUpgrade = false;
                }
            }

            if ($draftNeedsUpgrade) {
                $sourceRevision = (int) $entry->revision;
                $currentRevision++;
                DB::table('content_revisions')->insert([
                    'content_entry_id' => $entryId,
                    'revision' => $currentRevision,
                    'action' => 'draft_migrated',
                    'payload' => $this->encodePayload($upgradedDraft),
                    'source_revision' => $sourceRevision,
                    'actor_fingerprint' => $actorFingerprint,
                    'created_at' => $now,
                ]);
            }

            DB::table('content_entries')
                ->where('id', $entryId)
                ->update([
                    'revision' => $currentRevision,
                    'published_revision' => $publishedRevision,
                    'draft_payload' => $this->encodePayload($upgradedDraft),
                    'published_payload' => $upgradedPublished === null
                        ? null
                        : $this->encodePayload($upgradedPublished),
                    'updated_at' => $now,
                ]);
        });
    }

    public function down(): void
    {
        // Intentionally irreversible: content revision history is append-only.
    }

    private function decodePayload(mixed $value): array
    {
        if (is_array($value)) {
            return $value;
        }

        return json_decode((string) $value, true, 512, JSON_THROW_ON_ERROR);
    }

    private function encodePayload(array $payload): string
    {
        return json_encode(
            $payload,
            JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE,
        );
    }

    private function needsUpgrade(array $payload, array $defaults): bool
    {
        foreach (array_keys($defaults) as $key) {
            if (array_key_exists($key, $payload) === false) {
                return true;
            }
        }

        return false;
    }
};
