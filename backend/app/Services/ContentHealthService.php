<?php

namespace App\Services;

use App\Models\ContentEntry;
use Carbon\CarbonImmutable;

final class ContentHealthService
{
    public function __construct(
        private readonly ContentDeliveryMetadataService $deliveryMetadata,
    ) {}

    /**
     * @return array{
     *   generated_at:string,
     *   summary:array{total:int,healthy:int,attention:int,unpublished:int,changes_waiting:int,stale_schedules:int},
     *   entries:list<array<string,mixed>>
     * }
     */
    public function report(?CarbonImmutable $at = null): array
    {
        $at = ($at ?? CarbonImmutable::now('UTC'))->utc();
        $publicKeys = array_flip($this->deliveryMetadata->publicContentKeys());
        $rows = [];
        $summary = [
            'total' => 0,
            'healthy' => 0,
            'attention' => 0,
            'unpublished' => 0,
            'changes_waiting' => 0,
            'stale_schedules' => 0,
        ];

        foreach (ContentEntry::query()->orderBy('content_key')->get() as $entry) {
            $hasPublished = $entry->published_revision !== null && $entry->published_payload !== null;
            $changesWaiting = $hasPublished && $entry->draft_payload !== $entry->published_payload;
            $hasSchedule = $entry->scheduled_publish_at !== null || $entry->scheduled_unpublish_at !== null;
            $scheduleState = $hasSchedule
                ? ($entry->schedule_revision === $entry->revision ? 'armed' : 'stale')
                : 'none';
            $publishedAgeSeconds = $hasPublished && $entry->published_at !== null
                ? max(0, $entry->published_at->utc()->diffInSeconds($at, false))
                : null;
            $freshness = $this->freshness($publishedAgeSeconds);
            $health = $hasPublished && $scheduleState !== 'stale' ? 'healthy' : 'attention';
            $delivery = null;

            if ($hasPublished && isset($publicKeys[$entry->content_key])) {
                $delivery = $this->deliveryMetadata->forPublishedRevision(
                    $entry->content_key,
                    (int) $entry->published_revision,
                );
            }

            $rows[] = [
                'key' => $entry->content_key,
                'type' => $entry->content_type,
                'health' => $health,
                'current_revision' => (int) $entry->revision,
                'published_revision' => $entry->published_revision,
                'published_at' => $entry->published_at?->utc()->toIso8601ZuluString(),
                'published_age_seconds' => $publishedAgeSeconds,
                'freshness' => $freshness,
                'draft_state' => $changesWaiting ? 'changes_waiting' : ($hasPublished ? 'synced' : 'private_only'),
                'schedule_state' => $scheduleState,
                'scheduled_publish_at' => $entry->scheduled_publish_at?->utc()->toIso8601ZuluString(),
                'scheduled_unpublish_at' => $entry->scheduled_unpublish_at?->utc()->toIso8601ZuluString(),
                'delivery' => $delivery,
            ];

            $summary['total']++;
            $summary[$health]++;
            if (! $hasPublished) {
                $summary['unpublished']++;
            }
            if ($changesWaiting) {
                $summary['changes_waiting']++;
            }
            if ($scheduleState === 'stale') {
                $summary['stale_schedules']++;
            }
        }

        return [
            'generated_at' => $at->toIso8601ZuluString(),
            'summary' => $summary,
            'entries' => $rows,
        ];
    }

    private function freshness(?int $ageSeconds): string
    {
        if ($ageSeconds === null) {
            return 'unpublished';
        }
        if ($ageSeconds <= 3600) {
            return 'fresh';
        }
        if ($ageSeconds <= 86400) {
            return 'recent';
        }

        return 'aged';
    }
}
