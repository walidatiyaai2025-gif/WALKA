<?php

namespace Tests\Feature;

use App\Exceptions\ContentRevisionConflictException;
use App\Models\ContentRevision;
use App\Services\ContentRevisionService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class Cms052RollbackAuditTest extends TestCase
{
    use RefreshDatabase;

    public function test_reasoned_rollback_creates_a_new_private_draft_receipt_without_changing_live_snapshot(): void
    {
        $actor = hash('sha256', 'cms-052-owner');
        $service = app(ContentRevisionService::class);

        $service->saveDraft('home.hero', 'home.hero', ['title' => 'A'], 0, $actor);
        $service->publish('home.hero', 1, $actor);
        $service->saveDraft('home.hero', 'home.hero', ['title' => 'B'], 2, $actor);

        $restored = $service->restoreDraftFromRevision(
            contentKey: 'home.hero',
            revisionToRestore: 1,
            expectedRevision: 3,
            actorFingerprint: $actor,
            reason: 'Owner rollback after editorial review',
        );

        $this->assertSame(4, $restored->revision);
        $this->assertSame(2, $restored->published_revision);
        $this->assertSame(['title' => 'A'], $restored->published_payload);
        $this->assertSame(['title' => 'A'], $restored->draft_payload);

        $receipt = ContentRevision::query()->where('revision', 4)->firstOrFail();
        $this->assertSame('draft_restored', $receipt->action);
        $this->assertSame(1, $receipt->source_revision);
        $this->assertSame('Owner rollback after editorial review', $receipt->reason);
        $this->assertSame($actor, $receipt->actor_fingerprint);
    }

    public function test_rollback_is_optimistically_locked_and_invalid_reason_does_not_mutate_history(): void
    {
        $actor = hash('sha256', 'cms-052-owner');
        $service = app(ContentRevisionService::class);
        $service->saveDraft('home.hero', 'home.hero', ['title' => 'A'], 0, $actor);
        $service->saveDraft('home.hero', 'home.hero', ['title' => 'B'], 1, $actor);

        try {
            $service->restoreDraftFromRevision('home.hero', 1, 1, $actor, 'stale attempt');
            $this->fail('Expected stale rollback to be rejected.');
        } catch (ContentRevisionConflictException) {
            $this->assertSame(2, ContentRevision::query()->count());
        }

        try {
            $service->restoreDraftFromRevision('home.hero', 1, 2, $actor, str_repeat('x', 281));
            $this->fail('Expected rollback reason validation to fail.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey('reason', $exception->errors());
            $this->assertSame(2, ContentRevision::query()->count());
        }
    }
}
