<?php

namespace Tests\Unit;

use App\Services\Content\HomeBannerContentDefinition;
use Carbon\CarbonImmutable;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class HomeBannerContentDefinitionTest extends TestCase
{
    public function test_default_banner_is_safe_and_disabled(): void
    {
        $payload = HomeBannerContentDefinition::validateAndNormalize(
            HomeBannerContentDefinition::defaultPayload(),
        );

        $this->assertFalse($payload['enabled']);
        $this->assertFalse(HomeBannerContentDefinition::isActiveAt(
            $payload,
            CarbonImmutable::parse('2026-08-13T12:00:00Z'),
        ));
        $this->assertSame('browse', $payload['cta_action']);
    }

    public function test_schedule_uses_inclusive_start_and_exclusive_end(): void
    {
        $payload = HomeBannerContentDefinition::validateAndNormalize([
            'enabled' => true,
            'eyebrow' => 'LIMITED NOTE',
            'title' => 'A scheduled WALKA moment',
            'body' => 'A safe announcement with no remote executable behavior.',
            'cta_label' => 'BROWSE WALKA',
            'cta_action' => 'browse',
            'starts_at' => '2026-08-13T10:00:00Z',
            'ends_at' => '2026-08-13T12:00:00Z',
        ]);

        $this->assertFalse(HomeBannerContentDefinition::isActiveAt(
            $payload,
            CarbonImmutable::parse('2026-08-13T09:59:59Z'),
        ));
        $this->assertTrue(HomeBannerContentDefinition::isActiveAt(
            $payload,
            CarbonImmutable::parse('2026-08-13T10:00:00Z'),
        ));
        $this->assertTrue(HomeBannerContentDefinition::isActiveAt(
            $payload,
            CarbonImmutable::parse('2026-08-13T11:59:59Z'),
        ));
        $this->assertFalse(HomeBannerContentDefinition::isActiveAt(
            $payload,
            CarbonImmutable::parse('2026-08-13T12:00:00Z'),
        ));
    }

    public function test_open_ended_schedule_is_supported(): void
    {
        $payload = HomeBannerContentDefinition::validateAndNormalize([
            'enabled' => true,
            'eyebrow' => 'WALKA NOTE',
            'title' => 'Open ended announcement',
            'body' => 'This remains visible after its validated start.',
            'cta_label' => null,
            'cta_action' => 'none',
            'starts_at' => '2026-08-13T10:00:00+00:00',
            'ends_at' => null,
        ]);

        $this->assertSame('2026-08-13T10:00:00Z', $payload['starts_at']);
        $this->assertNull($payload['cta_label']);
        $this->assertTrue(HomeBannerContentDefinition::isActiveAt(
            $payload,
            CarbonImmutable::parse('2027-01-01T00:00:00Z'),
        ));
    }

    public function test_invalid_schedule_and_remote_action_fail_closed(): void
    {
        $base = [
            'enabled' => true,
            'eyebrow' => 'WALKA NOTE',
            'title' => 'Safe announcement',
            'body' => 'Safe supporting content.',
            'cta_label' => 'OPEN',
            'cta_action' => 'browse',
            'starts_at' => '2026-08-13T12:00:00Z',
            'ends_at' => '2026-08-13T10:00:00Z',
        ];

        $this->expectException(ValidationException::class);
        HomeBannerContentDefinition::validateAndNormalize($base);
    }

    public function test_arbitrary_url_action_is_not_accepted(): void
    {
        $this->expectException(ValidationException::class);
        HomeBannerContentDefinition::validateAndNormalize([
            'enabled' => true,
            'eyebrow' => 'WALKA NOTE',
            'title' => 'Unsafe remote action attempt',
            'body' => 'This must not become executable navigation.',
            'cta_label' => 'OPEN',
            'cta_action' => 'https://example.invalid',
            'starts_at' => null,
            'ends_at' => null,
        ]);
    }
}
