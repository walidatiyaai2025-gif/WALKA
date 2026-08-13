<?php

namespace App\Services\Content;

use Carbon\CarbonImmutable;
use Carbon\CarbonInterface;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

final class HomeBannerContentDefinition
{
    public const KEY = 'home.banner';

    public const TYPE = 'home.banner';

    public const SCHEMA_VERSION = 1;

    public const ACTION_NONE = 'none';

    public const ACTION_BROWSE = 'browse';

    public const ACTION_SEARCH = 'search';

    /**
     * Bundled clients intentionally default to no announcement. Publishing is
     * explicit and the enabled flag remains separately owner-controlled.
     *
     * @return array<string, mixed>
     */
    public static function defaultPayload(): array
    {
        return [
            'enabled' => false,
            'eyebrow' => 'WALKA NOTE',
            'title' => 'A calmer way to organize.',
            'body' => 'Explore thoughtful organization for home and everyday routines.',
            'cta_label' => 'EXPLORE WALKA',
            'cta_action' => self::ACTION_BROWSE,
            'starts_at' => null,
            'ends_at' => null,
        ];
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array{
     *   enabled: bool,
     *   eyebrow: string,
     *   title: string,
     *   body: string,
     *   cta_label: string|null,
     *   cta_action: string,
     *   starts_at: string|null,
     *   ends_at: string|null
     * }
     */
    public static function validateAndNormalize(array $payload): array
    {
        $normalized = [
            'enabled' => $payload['enabled'] ?? null,
            'eyebrow' => self::trimString($payload['eyebrow'] ?? null),
            'title' => self::trimString($payload['title'] ?? null),
            'body' => self::trimString($payload['body'] ?? null),
            'cta_label' => self::nullableTrimmedString($payload['cta_label'] ?? null),
            'cta_action' => self::trimString($payload['cta_action'] ?? null),
            'starts_at' => self::normalizeTimestamp($payload['starts_at'] ?? null, 'starts_at'),
            'ends_at' => self::normalizeTimestamp($payload['ends_at'] ?? null, 'ends_at'),
        ];

        $validated = Validator::make($normalized, [
            'enabled' => ['required', 'boolean'],
            'eyebrow' => ['required', 'string', 'max:80'],
            'title' => ['required', 'string', 'max:140'],
            'body' => ['required', 'string', 'max:320'],
            'cta_label' => ['nullable', 'string', 'max:48', 'required_unless:cta_action,'.self::ACTION_NONE],
            'cta_action' => ['required', 'string', 'in:'.implode(',', self::allowedActions())],
            'starts_at' => ['nullable', 'date'],
            'ends_at' => ['nullable', 'date'],
        ])->validate();

        if ($validated['cta_action'] === self::ACTION_NONE) {
            $validated['cta_label'] = null;
        }

        if ($validated['starts_at'] !== null && $validated['ends_at'] !== null) {
            $startsAt = CarbonImmutable::parse($validated['starts_at']);
            $endsAt = CarbonImmutable::parse($validated['ends_at']);
            if (! $endsAt->greaterThan($startsAt)) {
                throw ValidationException::withMessages([
                    'ends_at' => ['Banner end time must be later than its start time.'],
                ]);
            }
        }

        return $validated;
    }

    /**
     * @return array<string, mixed>
     */
    public static function editableFields(?array $payload): array
    {
        $candidate = array_merge(self::defaultPayload(), $payload ?? []);

        try {
            return self::validateAndNormalize($candidate);
        } catch (ValidationException) {
            return self::defaultPayload();
        }
    }

    /**
     * Schedule evaluation uses an inclusive start and exclusive end so a
     * banner changes state exactly once at each boundary.
     *
     * @param  array<string, mixed>  $payload
     */
    public static function isActiveAt(array $payload, ?CarbonInterface $now = null): bool
    {
        $content = self::validateAndNormalize($payload);
        if (! $content['enabled']) {
            return false;
        }

        $instant = CarbonImmutable::instance($now ?? now())->utc();
        if ($content['starts_at'] !== null && $instant->lessThan(CarbonImmutable::parse($content['starts_at']))) {
            return false;
        }
        if ($content['ends_at'] !== null && ! $instant->lessThan(CarbonImmutable::parse($content['ends_at']))) {
            return false;
        }

        return true;
    }

    /** @return list<string> */
    public static function allowedActions(): array
    {
        return [self::ACTION_NONE, self::ACTION_BROWSE, self::ACTION_SEARCH];
    }

    private static function trimString(mixed $value): mixed
    {
        return is_string($value) ? trim($value) : $value;
    }

    private static function nullableTrimmedString(mixed $value): mixed
    {
        if ($value === null) {
            return null;
        }
        if (! is_string($value)) {
            return $value;
        }

        $value = trim($value);

        return $value === '' ? null : $value;
    }

    private static function normalizeTimestamp(mixed $value, string $field): mixed
    {
        if ($value === null || $value === '') {
            return null;
        }
        if (! is_string($value)) {
            return $value;
        }

        try {
            return CarbonImmutable::parse($value)->utc()->format('Y-m-d\TH:i:s\Z');
        } catch (\Throwable) {
            throw ValidationException::withMessages([
                $field => ['Banner schedule timestamp is invalid.'],
            ]);
        }
    }
}
