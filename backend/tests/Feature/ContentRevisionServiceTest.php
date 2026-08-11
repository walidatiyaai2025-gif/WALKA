<?php

namespace Tests\Feature;

use App\Exceptions\ContentRevisionConflictException;
use App\Models\ContentEntry;
use App\Models\ContentRevision;
use App\Services\ContentRevisionService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class ContentRevisionServiceTest extends TestCase
{
    use RefreshDatabase;

    private string $actorFingerprint;

    protected function setUp(): void
    {
        parent::setUp();

        $this->actorFingerprint = hash('sha256', 'cms-001-test-actor');
    }

    public function test_it_creates_an_unpublished_draft_with_an_immutable_first_revision(): void
    {
        $entry = $this->service()->saveDraft(
            contentKey: 'home.hero',
            contentType: 'home.hero',
            payload: ['title' => 'Organize beautifully', 'subtitle' => 'Premium WALKA storage'],
            expectedRevision: 0,
            actorFingerprint: $this->actorFingerprint,
        );

        $this->assertSame(1, $entry->revision);
        $this->assertNull($entry->published_revision);
        $this->assertNull($entry->published_payload);
        $this->assertSame('Organize beautifully', $entry->draft_payload['title']);

        $revision = ContentRevision::query()->firstOrFail();
        $this->assertSame('draft_created', $revision->action);
        $this->assertSame(1, $revision->revision);
        $this->assertSame($this->actorFingerprint, $revision->actor_fingerprint);
        $this->assertSame($entry->draft_payload, $revision->payload);
    }

    public function test_draft_updates_increment_revision_and_preserve_prior_history(): void
    {
        $service = $this->service();
        $service->saveDraft('home.hero', 'home.hero', ['title' => 'First'], 0, $this->actorFingerprint);

        $entry = $service->saveDraft(
            'home.hero',
            'home.hero',
            ['title' => 'Second'],
            1,
            $this->actorFingerprint,
        );

        $this->assertSame(2, $entry->revision);
        $this->assertSame(['title' => 'Second'], $entry->draft_payload);

        $history = $service->history('home.hero');
        $this->assertCount(2, $history);
        $this->assertSame(['title' => 'First'], $history[0]->payload);
        $this->assertSame(['title' => 'Second'], $history[1]->payload);
        $this->assertSame('draft_updated', $history[1]->action);
    }

    public function test_stale_writes_are_rejected_without_mutating_content_or_history(): void
    {
        $service = $this->service();
        $service->saveDraft('home.hero', 'home.hero', ['title' => 'First'], 0, $this->actorFingerprint);
        $service->saveDraft('home.hero', 'home.hero', ['title' => 'Second'], 1, $this->actorFingerprint);

        try {
            $service->saveDraft('home.hero', 'home.hero', ['title' => 'Stale'], 1, $this->actorFingerprint);
            $this->fail('Expected a content revision conflict.');
        } catch (ContentRevisionConflictException) {
            // Expected.
        }

        $entry = ContentEntry::query()->where('content_key', 'home.hero')->firstOrFail();
        $this->assertSame(2, $entry->revision);
        $this->assertSame(['title' => 'Second'], $entry->draft_payload);
        $this->assertSame(2, ContentRevision::query()->count());
    }

    public function test_publish_snapshots_the_current_draft_without_erasing_draft_history(): void
    {
        $service = $this->service();
        $service->saveDraft('home.hero', 'home.hero', ['title' => 'Live hero'], 0, $this->actorFingerprint);

        $entry = $service->publish('home.hero', 1, $this->actorFingerprint);

        $this->assertSame(2, $entry->revision);
        $this->assertSame(2, $entry->published_revision);
        $this->assertSame(['title' => 'Live hero'], $entry->published_payload);
        $this->assertNotNull($entry->published_at);
        $this->assertSame(['title' => 'Live hero'], $service->publishedPayload('home.hero'));

        $history = $service->history('home.hero');
        $this->assertCount(2, $history);
        $this->assertSame('published', $history[1]->action);
        $this->assertSame(1, $history[1]->source_revision);
    }

    public function test_identical_draft_and_publish_operations_are_noops(): void
    {
        $service = $this->service();
        $service->saveDraft('home.hero', 'home.hero', ['title' => 'Same'], 0, $this->actorFingerprint);
        $published = $service->publish('home.hero', 1, $this->actorFingerprint);

        $sameDraft = $service->saveDraft(
            'home.hero',
            'home.hero',
            ['title' => 'Same'],
            $published->revision,
            $this->actorFingerprint,
        );
        $samePublish = $service->publish('home.hero', $sameDraft->revision, $this->actorFingerprint);

        $this->assertSame(2, $samePublish->revision);
        $this->assertSame(2, ContentRevision::query()->count());
    }

    public function test_restore_creates_a_new_draft_revision_and_leaves_published_snapshot_untouched(): void
    {
        $service = $this->service();
        $service->saveDraft('home.hero', 'home.hero', ['title' => 'A'], 0, $this->actorFingerprint);
        $service->publish('home.hero', 1, $this->actorFingerprint);
        $service->saveDraft('home.hero', 'home.hero', ['title' => 'B'], 2, $this->actorFingerprint);
        $service->saveDraft('home.hero', 'home.hero', ['title' => 'C'], 3, $this->actorFingerprint);

        $entry = $service->restoreDraftFromRevision(
            contentKey: 'home.hero',
            revisionToRestore: 3,
            expectedRevision: 4,
            actorFingerprint: $this->actorFingerprint,
        );

        $this->assertSame(5, $entry->revision);
        $this->assertSame(['title' => 'B'], $entry->draft_payload);
        $this->assertSame(['title' => 'A'], $entry->published_payload);
        $this->assertSame(2, $entry->published_revision);

        $restored = ContentRevision::query()
            ->where('content_entry_id', $entry->id)
            ->where('revision', 5)
            ->firstOrFail();
        $this->assertSame('draft_restored', $restored->action);
        $this->assertSame(3, $restored->source_revision);
    }

    public function test_empty_payload_is_explicit_content_while_null_means_not_published(): void
    {
        $entry = $this->service()->saveDraft(
            'app.notice',
            'notice',
            [],
            0,
            $this->actorFingerprint,
        );

        $this->assertSame([], $entry->draft_payload);
        $this->assertNull($entry->published_payload);
    }

    public function test_content_type_is_immutable_and_payload_size_is_bounded(): void
    {
        $service = $this->service();
        $service->saveDraft('home.hero', 'home.hero', ['title' => 'A'], 0, $this->actorFingerprint);

        try {
            $service->saveDraft('home.hero', 'different.type', ['title' => 'B'], 1, $this->actorFingerprint);
            $this->fail('Expected immutable content type validation failure.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey('content_type', $exception->errors());
        }

        try {
            $service->saveDraft(
                'home.large',
                'home.hero',
                ['copy' => str_repeat('x', 70000)],
                0,
                $this->actorFingerprint,
            );
            $this->fail('Expected payload size validation failure.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey('payload', $exception->errors());
        }

        $this->assertSame(1, ContentRevision::query()->count());
    }

    private function service(): ContentRevisionService
    {
        return app(ContentRevisionService::class);
    }
}
