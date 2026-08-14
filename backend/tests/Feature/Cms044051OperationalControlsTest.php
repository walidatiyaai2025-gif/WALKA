<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use App\Services\Content\AppConfigContentDefinition;
use App\Services\Content\MaintenanceNoticeContentDefinition;
use App\Services\ContentDiffService;
use App\Services\ContentRevisionService;
use App\Services\ContentScheduleService;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class Cms044051OperationalControlsTest extends TestCase
{
    use RefreshDatabase;

    private const ACTOR = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

    public function test_maintenance_notice_is_typed_scheduled_and_html_free(): void
    {
        $payload = MaintenanceNoticeContentDefinition::validateAndNormalize([
            'enabled' => true,
            'severity' => 'maintenance',
            'title' => 'Short maintenance window',
            'body' => 'Product discovery remains available.',
            'starts_at' => '2026-08-14T08:00:00Z',
            'ends_at' => '2026-08-14T09:00:00Z',
            'url' => 'https://evil.example',
        ]);

        $this->assertSame([
            'enabled', 'severity', 'title', 'body', 'starts_at', 'ends_at',
        ], array_keys($payload));
        $this->assertTrue(MaintenanceNoticeContentDefinition::isActiveAt(
            $payload,
            CarbonImmutable::parse('2026-08-14T08:30:00Z'),
        ));
        $this->assertFalse(MaintenanceNoticeContentDefinition::isActiveAt(
            $payload,
            CarbonImmutable::parse('2026-08-14T09:00:00Z'),
        ));

        $this->expectException(ValidationException::class);
        MaintenanceNoticeContentDefinition::validateAndNormalize([
            ...$payload,
            'body' => '<script>alert(1)</script>',
        ]);
    }

    public function test_app_config_accepts_only_compiled_boolean_flags(): void
    {
        $normalized = AppConfigContentDefinition::validateAndNormalize([
            'flags' => [
                'show_operational_notice' => true,
                'show_account_service_note' => false,
            ],
        ]);
        $this->assertSame(AppConfigContentDefinition::flagIds(), array_keys($normalized['flags']));

        $this->expectException(ValidationException::class);
        AppConfigContentDefinition::validateAndNormalize([
            'flags' => [
                'show_operational_notice' => true,
                'show_account_service_note' => false,
                'disable_authentication' => true,
            ],
        ]);
    }

    public function test_public_operational_endpoints_are_published_only_allowlisted_and_etagged(): void
    {
        /** @var ContentRevisionService $content */
        $content = app(ContentRevisionService::class);
        $notice = $content->saveDraft(
            MaintenanceNoticeContentDefinition::KEY,
            MaintenanceNoticeContentDefinition::TYPE,
            MaintenanceNoticeContentDefinition::defaultPayload(),
            0,
            self::ACTOR,
        );
        $content->saveDraft(
            MaintenanceNoticeContentDefinition::KEY,
            MaintenanceNoticeContentDefinition::TYPE,
            MaintenanceNoticeContentDefinition::validateAndNormalize([
                ...MaintenanceNoticeContentDefinition::defaultPayload(),
                'enabled' => true,
                'title' => 'Published notice',
            ]),
            $notice->revision,
            self::ACTOR,
        );
        $notice = ContentEntry::query()->where('content_key', MaintenanceNoticeContentDefinition::KEY)->firstOrFail();
        $notice = $content->publish($notice->content_key, $notice->revision, self::ACTOR);

        $config = $content->saveDraft(
            AppConfigContentDefinition::KEY,
            AppConfigContentDefinition::TYPE,
            AppConfigContentDefinition::defaultPayload(),
            0,
            self::ACTOR,
        );
        $config = $content->publish($config->content_key, $config->revision, self::ACTOR);

        $noticeResponse = $this->getJson('/api/v1/content/maintenance-notice')
            ->assertOk()
            ->assertJsonPath('data.key', MaintenanceNoticeContentDefinition::KEY)
            ->assertJsonPath('data.schema_version', 1)
            ->assertJsonMissingPath('data.payload.url')
            ->assertJsonStructure(['meta' => ['api_version', 'active', 'schedule_evaluated_at']]);
        $this->assertSame('"walka-maintenance-notice-r'.$notice->published_revision.'"', $noticeResponse->headers->get('ETag'));

        $configResponse = $this->getJson('/api/v1/content/app-config')
            ->assertOk()
            ->assertJsonPath('data.key', AppConfigContentDefinition::KEY)
            ->assertJsonPath('data.payload.flags.show_operational_notice', true);
        $this->assertSame('"walka-app-config-r'.$config->published_revision.'"', $configResponse->headers->get('ETag'));
    }

    public function test_scheduled_publish_and_unpublish_are_revision_safe_idempotent_and_publicly_isolated(): void
    {
        /** @var ContentRevisionService $content */
        $content = app(ContentRevisionService::class);
        /** @var ContentScheduleService $schedules */
        $schedules = app(ContentScheduleService::class);

        $entry = $content->saveDraft('ops.test', 'ops.test', ['title' => 'Draft'], 0, self::ACTOR);
        $publishAt = CarbonImmutable::parse('2026-08-14T10:00:00Z');
        $unpublishAt = CarbonImmutable::parse('2026-08-14T11:00:00Z');
        $entry = $schedules->schedule(
            $entry->content_key,
            $entry->revision,
            $publishAt,
            $unpublishAt,
            self::ACTOR,
        );
        $this->assertSame($entry->revision, $entry->schedule_revision);
        $this->assertNull($entry->published_payload);

        $result = $schedules->runDue($publishAt);
        $this->assertSame(['published' => 1, 'unpublished' => 0, 'stale' => 0], $result);
        $entry->refresh();
        $this->assertSame(['title' => 'Draft'], $entry->published_payload);
        $this->assertSame($entry->revision, $entry->schedule_revision);
        $this->assertNull($entry->scheduled_publish_at);
        $this->assertNotNull($entry->scheduled_unpublish_at);

        $result = $schedules->runDue($unpublishAt);
        $this->assertSame(['published' => 0, 'unpublished' => 1, 'stale' => 0], $result);
        $entry->refresh();
        $this->assertNull($entry->published_payload);
        $this->assertNull($entry->published_revision);
        $this->assertNull($entry->schedule_revision);

        $this->assertSame(
            ['published' => 0, 'unpublished' => 0, 'stale' => 0],
            $schedules->runDue($unpublishAt->addMinute()),
        );
        $this->assertSame(
            ['draft_created', 'schedule_updated', 'scheduled_published', 'scheduled_unpublished'],
            $entry->revisions()->orderBy('revision')->pluck('action')->all(),
        );
    }

    public function test_catch_up_run_prefers_final_unpublished_state_when_both_boundaries_are_due(): void
    {
        /** @var ContentRevisionService $content */
        $content = app(ContentRevisionService::class);
        /** @var ContentScheduleService $schedules */
        $schedules = app(ContentScheduleService::class);

        $entry = $content->saveDraft('ops.catch-up', 'ops.catch-up', ['title' => 'Transient'], 0, self::ACTOR);
        $entry = $schedules->schedule(
            $entry->content_key,
            $entry->revision,
            CarbonImmutable::parse('2026-08-14T10:00:00Z'),
            CarbonImmutable::parse('2026-08-14T11:00:00Z'),
            self::ACTOR,
        );

        $this->assertSame(
            ['published' => 0, 'unpublished' => 1, 'stale' => 0],
            $schedules->runDue(CarbonImmutable::parse('2026-08-14T12:00:00Z')),
        );
        $entry->refresh();
        $this->assertNull($entry->published_payload);
        $this->assertNull($entry->published_revision);
        $this->assertNull($entry->scheduled_publish_at);
        $this->assertNull($entry->scheduled_unpublish_at);
        $this->assertSame(
            ['draft_created', 'schedule_updated', 'scheduled_unpublished'],
            $entry->revisions()->orderBy('revision')->pluck('action')->all(),
        );
    }

    public function test_schedule_does_not_execute_after_later_draft_revision(): void
    {
        /** @var ContentRevisionService $content */
        $content = app(ContentRevisionService::class);
        /** @var ContentScheduleService $schedules */
        $schedules = app(ContentScheduleService::class);

        $entry = $content->saveDraft('ops.stale', 'ops.stale', ['value' => 1], 0, self::ACTOR);
        $due = CarbonImmutable::parse('2026-08-14T10:00:00Z');
        $entry = $schedules->schedule($entry->content_key, $entry->revision, $due, null, self::ACTOR);
        $entry = $content->saveDraft($entry->content_key, $entry->content_type, ['value' => 2], $entry->revision, self::ACTOR);

        $this->assertNotSame($entry->revision, $entry->schedule_revision);
        $this->assertSame(['published' => 0, 'unpublished' => 0, 'stale' => 1], $schedules->runDue($due));
        $entry->refresh();
        $this->assertNull($entry->published_payload);
    }

    public function test_rich_diff_is_deterministic_nested_and_excludes_sensitive_keys(): void
    {
        /** @var ContentDiffService $diffs */
        $diffs = app(ContentDiffService::class);
        $rows = $diffs->diff(
            [
                'title' => 'Old',
                'items' => [['id' => 'a', 'body' => 'Before']],
                'admin_token' => 'secret-old',
            ],
            [
                'title' => 'New',
                'items' => [['id' => 'a', 'body' => 'After'], ['id' => 'b', 'body' => 'Added']],
                'admin_token' => 'secret-new',
            ],
        );

        $paths = array_column($rows, 'path');
        $this->assertSame($paths, collect($paths)->sort()->values()->all());
        $this->assertContains('items[0].body', $paths);
        $this->assertContains('items[1]', $paths);
        $this->assertContains('title', $paths);
        $this->assertNotContains('admin_token', $paths);
    }
}
