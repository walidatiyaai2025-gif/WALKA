<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use App\Services\ContentDeliveryMetadataService;
use App\Services\ContentHealthService;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class Cms053ContentHealthTest extends TestCase
{
    use RefreshDatabase;

    public function test_health_report_classifies_published_private_and_stale_schedule_states_without_payloads(): void
    {
        $at = CarbonImmutable::parse('2026-08-14T09:00:00Z');

        ContentEntry::query()->create([
            'content_key' => 'home.hero',
            'content_type' => 'home.hero',
            'revision' => 4,
            'published_revision' => 3,
            'draft_payload' => ['title' => 'Draft secret copy'],
            'published_payload' => ['title' => 'Live copy'],
            'published_at' => $at->subMinutes(30),
        ]);
        ContentEntry::query()->create([
            'content_key' => 'private.test',
            'content_type' => 'private.test',
            'revision' => 1,
            'draft_payload' => ['private' => 'must never appear in health report'],
        ]);
        ContentEntry::query()->create([
            'content_key' => 'app.config',
            'content_type' => 'app.config',
            'revision' => 5,
            'published_revision' => 5,
            'draft_payload' => ['flags' => []],
            'published_payload' => ['flags' => []],
            'published_at' => $at->subDays(2),
            'scheduled_publish_at' => $at->addHour(),
            'schedule_revision' => 4,
        ]);

        $report = app(ContentHealthService::class)->report($at);

        $this->assertSame(3, $report['summary']['total']);
        $this->assertSame(1, $report['summary']['healthy']);
        $this->assertSame(2, $report['summary']['attention']);
        $this->assertSame(1, $report['summary']['unpublished']);
        $this->assertSame(1, $report['summary']['changes_waiting']);
        $this->assertSame(1, $report['summary']['stale_schedules']);

        $hero = collect($report['entries'])->firstWhere('key', 'home.hero');
        $this->assertSame('fresh', $hero['freshness']);
        $this->assertSame('changes_waiting', $hero['draft_state']);
        $this->assertSame('"walka-home-hero-r3"', $hero['delivery']['etag']);
        $this->assertSame(ContentDeliveryMetadataService::CACHE_CONTROL, $hero['delivery']['cache_control']);

        $json = json_encode($report, JSON_THROW_ON_ERROR);
        $this->assertStringNotContainsString('Draft secret copy', $json);
        $this->assertStringNotContainsString('must never appear', $json);
    }

    public function test_health_json_is_not_publicly_available_without_dashboard_session(): void
    {
        $this->get('/admin/content/health.json')
            ->assertRedirect('/admin/login');
    }
}
