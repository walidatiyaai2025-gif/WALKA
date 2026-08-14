<?php

namespace App\Services\Content;

use Illuminate\Validation\ValidationException;

final class AppConfigContentDefinition
{
    public const KEY = 'app.config';

    public const TYPE = 'app.config';

    public const SCHEMA_VERSION = 1;

    /** @return list<string> */
    public static function flagIds(): array
    {
        return [
            'show_operational_notice',
            'show_account_service_note',
        ];
    }

    /** @return array<string, mixed> */
    public static function defaultPayload(): array
    {
        return [
            'flags' => [
                'show_operational_notice' => true,
                'show_account_service_note' => false,
            ],
        ];
    }

    /** @param array<string, mixed> $payload
     *  @return array<string, mixed>
     */
    public static function validateAndNormalize(array $payload): array
    {
        $flags = $payload['flags'] ?? null;
        if (! is_array($flags) || array_is_list($flags)) {
            self::fail('flags', 'Flags must be an object keyed by compiled flag ID.');
        }

        $unknown = array_values(array_diff(array_keys($flags), self::flagIds()));
        if ($unknown !== []) {
            self::fail('flags', 'Unknown presentation flag: '.implode(', ', $unknown));
        }

        $normalized = [];
        foreach (self::flagIds() as $id) {
            if (! array_key_exists($id, $flags) || ! is_bool($flags[$id])) {
                self::fail("flags.$id", 'Every compiled presentation flag must be present as a boolean.');
            }
            $normalized[$id] = $flags[$id];
        }

        return ['flags' => $normalized];
    }

    private static function fail(string $field, string $message): never
    {
        throw ValidationException::withMessages([$field => [$message]]);
    }
}
