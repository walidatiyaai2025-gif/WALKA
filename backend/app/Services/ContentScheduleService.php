<?php

namespace App\Services;

use App\Exceptions\ContentRevisionConflictException;
use App\Models\ContentEntry;
use App\Models\ContentRevision;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

final class ContentScheduleService
{
    /**
     * @return array{published:int, unpublished:int, stale:int}
     */
    public function runDue(?CarbonImmutable $at = null): array
    {
        $at = ($at ?? CarbonImmutable::now('UTC'))->utc();
        $result = ['published' => 0, 'unpublished' => 0, 'stale' => 0];

        $ids = ContentEntry::query()
            ->where(function ($query) use ($at): void {
                $query->where('scheduled_publish_at', '<=', $at)
                    ->orWhere('scheduled_unpublish_at', '<=', $at);
            })
            ->pluck('id');

        foreach ($ids as $id) {
            $outcome = DB::transaction(function () use ($id, $at): string {
                $entry = ContentEntry::query()->lockForUpdate()->find($id);
                if ($entry === null) {
                    return 'stale';
                }

                if ($entry->schedule_revision === null || $entry->schedule_revision !== $entry->revision) {
                    return 'stale';
                }

                $unpublishDue = $entry->scheduled_unpublish_at !== null
                    && ! $entry->scheduled_unpublish_at->greaterThan($at);
                if ($unpublishDue) {
                    $this->applyScheduledUnpublish($entry, $at);
                    return 'unpublished';
                }

                $publishDue = $entry->scheduled_publish_at !== null
                    && ! $entry->scheduled_publish_at->greaterThan($at);
                if ($publishDue) {
                    $this->applyScheduledPublish($entry, $at);
                    return 'published';
                }

                return 'stale';
            });

            $result[$outcome]++;
        }

        return $result;
    }

    public function schedule(
        string $contentKey,
        int $expectedRevision,
        ?CarbonImmutable $publishAt,
        ?CarbonImmutable $unpublishAt,
        string $actorFingerprint,
    ): ContentEntry {
        $this->validateFingerprint($actorFingerprint);
        $publishAt = $publishAt?->utc();
        $unpublishAt = $unpublishAt?->utc();

        if ($publishAt !== null && $unpublishAt !== null && ! $unpublishAt->greaterThan($publishAt)) {
            throw ValidationException::withMessages([
                'scheduled_unpublish_at' => ['Unpublish time must be after publish time.'],
            ]);
        }

        return DB::transaction(function () use (
            $contentKey,
            $expectedRevision,
            $publishAt,
            $unpublishAt,
            $actorFingerprint,
        ): ContentEntry {
            $entry = ContentEntry::query()
                ->where('content_key', $contentKey)
                ->lockForUpdate()
                ->firstOrFail();

            if ($entry->revision !== $expectedRevision) {
                throw new ContentRevisionConflictException($contentKey, $expectedRevision, $entry->revision);
            }

            if ($unpublishAt !== null && $publishAt === null && $entry->published_payload === null) {
                throw ValidationException::withMessages([
                    'scheduled_unpublish_at' => ['Cannot schedule unpublish for content that is not currently published.'],
                ]);
            }

            $same = $this->sameInstant($entry->scheduled_publish_at?->toImmutable(), $publishAt)
                && $this->sameInstant($entry->scheduled_unpublish_at?->toImmutable(), $unpublishAt);
            if ($same) {
                return $entry->refresh();
            }

            $nextRevision = $entry->revision + 1;
            $entry->scheduled_publish_at = $publishAt;
            $entry->scheduled_unpublish_at = $unpublishAt;
            $entry->schedule_revision = ($publishAt === null && $unpublishAt === null) ? null : $nextRevision;
            $entry->revision = $nextRevision;
            $entry->save();

            $this->record(
                $entry,
                $nextRevision,
                ($publishAt === null && $unpublishAt === null) ? 'schedule_cleared' : 'schedule_updated',
                $entry->draft_payload,
                $expectedRevision,
                $actorFingerprint,
            );

            return $entry->refresh();
        });
    }

    private function applyScheduledPublish(ContentEntry $entry, CarbonImmutable $at): void
    {
        $sourceRevision = $entry->revision;
        $nextRevision = $sourceRevision + 1;
        $entry->published_payload = $entry->draft_payload;
        $entry->published_revision = $nextRevision;
        $entry->published_at = $at;
        $entry->scheduled_publish_at = null;
        $entry->revision = $nextRevision;
        $entry->schedule_revision = $entry->scheduled_unpublish_at === null ? null : $nextRevision;
        $entry->save();

        $this->record(
            $entry,
            $nextRevision,
            'scheduled_published',
            $entry->draft_payload,
            $sourceRevision,
            hash('sha256', 'walka|content-scheduler'),
        );
    }

    private function applyScheduledUnpublish(ContentEntry $entry, CarbonImmutable $at): void
    {
        $sourceRevision = $entry->revision;
        $nextRevision = $sourceRevision + 1;
        $entry->published_payload = null;
        $entry->published_revision = null;
        $entry->published_at = null;
        $entry->scheduled_publish_at = null;
        $entry->scheduled_unpublish_at = null;
        $entry->schedule_revision = null;
        $entry->revision = $nextRevision;
        $entry->save();

        $this->record(
            $entry,
            $nextRevision,
            'scheduled_unpublished',
            $entry->draft_payload,
            $sourceRevision,
            hash('sha256', 'walka|content-scheduler|'.$at->toIso8601ZuluString()),
        );
    }

    private function record(
        ContentEntry $entry,
        int $revision,
        string $action,
        array $payload,
        ?int $sourceRevision,
        string $actorFingerprint,
    ): void {
        ContentRevision::query()->create([
            'content_entry_id' => $entry->id,
            'revision' => $revision,
            'action' => $action,
            'payload' => $payload,
            'source_revision' => $sourceRevision,
            'actor_fingerprint' => $actorFingerprint,
            'created_at' => now(),
        ]);
    }

    private function validateFingerprint(string $fingerprint): void
    {
        if (preg_match('/^[a-f0-9]{64}$/', $fingerprint) !== 1) {
            throw ValidationException::withMessages([
                'actor_fingerprint' => ['Actor fingerprint must be a lowercase SHA-256 value.'],
            ]);
        }
    }

    private function sameInstant(?CarbonImmutable $left, ?CarbonImmutable $right): bool
    {
        if ($left === null || $right === null) {
            return $left === $right;
        }

        return $left->utc()->equalTo($right->utc());
    }
}
