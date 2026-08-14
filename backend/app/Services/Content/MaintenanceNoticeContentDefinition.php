<?php

namespace App\Services\Content;

use Carbon\CarbonImmutable;
use Illuminate\Validation\ValidationException;

final class MaintenanceNoticeContentDefinition
{
    public const KEY = 'app.maintenance_notice';

    public const TYPE = 'app.maintenance_notice';

    public const SCHEMA_VERSION = 1;

    /** @return array<string, mixed> */
    public static function defaultPayload(): array
    {
        return [
            'enabled' => false,
            'severity' => 'info',
            'title' => 'WALKA service update',
            'body' => 'We are making a few improvements. Product discovery and official Amazon purchase links remain available.',
            'starts_at' => null,
            'ends_at' => null,
        ];
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array<string, mixed>
     */
    public static function validateAndNormalize(array $payload): array
    {
        $enabled = $payload['enabled'] ?? null;
        if (is_bool($enabled) === false) {
            self::fail('enabled', 'Enabled must be a boolean.');
        }

        $severity = trim((string) ($payload['severity'] ?? ''));
        if (in_array($severity, ['info', 'warning', 'maintenance'], true) === false) {
            self::fail('severity', 'Severity must be info, warning or maintenance.');
        }

        $title = self::safeText($payload, 'title', 140);
        $body = self::safeText($payload, 'body', 700);
        $startsAt = self::timestamp($payload['starts_at'] ?? null, 'starts_at');
        $endsAt = self::timestamp($payload['ends_at'] ?? null, 'ends_at');

        if ($startsAt !== null && $endsAt !== null && $endsAt->lessThanOrEqualTo($startsAt)) {
            self::fail('ends_at', 'End time must be after start time.');
        }

        return [
            'enabled' => $enabled,
            'severity' => $severity,
            'title' => $title,
            'body' => $body,
            'starts_at' => $startsAt?->toIso8601ZuluString(),
            'ends_at' => $endsAt?->toIso8601ZuluString(),
        ];
    }

    /** @param array<string, mixed> $payload */
    public static function isActiveAt(array $payload, ?CarbonImmutable $at = null): bool
    {
        $normalized = self::validateAndNormalize($payload);
        if ($normalized['enabled'] !== true) {
            return false;
        }

        $at = ($at ?? CarbonImmutable::now('UTC'))->utc();
        $startsAt = self::timestamp($normalized['starts_at'], 'starts_at');
        $endsAt = self::timestamp($normalized['ends_at'], 'ends_at');

        if ($startsAt !== null && $at->lessThan($startsAt)) {
            return false;
        }
        if ($endsAt !== null && $at->greaterThanOrEqualTo($endsAt)) {
            return false;
        }

        return true;
    }

    /** @param array<string, mixed> $payload */
    private static function safeText(array $payload, string $key, int $max): string
    {
        $value = trim((string) ($payload[$key] ?? ''));
        if ($value === '' || mb_strlen($value) > $max) {
            self::fail($key, sprintf('%s must contain between 1 and %d characters.', $key, $max));
        }
        if ($value !== strip_tags($value) || preg_match('/<\/?(?:script|style|iframe|object|embed)\b/i', $value) === 1) {
            self::fail($key, 'HTML and executable markup are not allowed.');
        }

        return $value;
    }

    private static function timestamp(mixed $value, string $field): ?CarbonImmutable
    {
        if ($value === null || trim((string) $value) === '') {
            return null;
        }

        try {
            $timestamp = CarbonImmutable::parse((string) $value);
        } catch (\Throwable) {
            self::fail($field, 'Timestamp must be a valid ISO-8601 value.');
        }

        if ($timestamp->getOffset() !== 0) {
            self::fail($field, 'Timestamp must use UTC.');
        }

        return $timestamp->utc();
    }

    private static function fail(string $field, string $message): never
    {
        throw ValidationException::withMessages([$field => [$message]]);
    }
}
