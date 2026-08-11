<?php

namespace App\Services\Content;

use Illuminate\Validation\ValidationException;

final class HomeLayoutContentDefinition
{
    public const KEY = 'home.layout';

    public const TYPE = 'home.layout';

    public const SCHEMA_VERSION = 1;

    public const HERO = 'hero';

    public const BENEFITS = 'benefits';

    public const COLLECTION = 'collection';

    public const SMALL_CHANGES = 'small_changes';

    public const TRUST = 'trust';

    /**
     * @return list<string>
     */
    public static function sectionIds(): array
    {
        return [
            self::HERO,
            self::BENEFITS,
            self::COLLECTION,
            self::SMALL_CHANGES,
            self::TRUST,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public static function defaultPayload(): array
    {
        return [
            'sections' => [
                ['id' => self::HERO, 'visible' => true],
                ['id' => self::BENEFITS, 'visible' => true],
                [
                    'id' => self::COLLECTION,
                    'visible' => true,
                    'eyebrow' => 'OUR COLLECTION',
                    'title' => 'Everything in Its Place',
                ],
                [
                    'id' => self::SMALL_CHANGES,
                    'visible' => true,
                    'title' => "Small Changes,\nBetter Living",
                    'body' => 'Simple solutions that bring order, beauty and peace of mind.',
                ],
                ['id' => self::TRUST, 'visible' => true],
            ],
        ];
    }

    /**
     * Validate and normalize the exact public Home layout contract.
     *
     * @param  array<string, mixed>  $payload
     * @return array<string, mixed>
     */
    public static function validateAndNormalize(array $payload): array
    {
        $sections = $payload['sections'] ?? null;
        if (! is_array($sections) || ! array_is_list($sections)) {
            self::fail('sections', 'Home layout sections must be an ordered array.');
        }

        if (count($sections) !== count(self::sectionIds())) {
            self::fail('sections', 'Home layout must contain every supported section exactly once.');
        }

        $seen = [];
        $normalized = [];

        foreach ($sections as $index => $section) {
            if (! is_array($section)) {
                self::fail("sections.$index", 'Each Home layout section must be an object.');
            }

            $id = $section['id'] ?? null;
            if (! is_string($id) || ! in_array($id, self::sectionIds(), true)) {
                self::fail("sections.$index.id", 'Unknown Home layout section ID.');
            }
            if (isset($seen[$id])) {
                self::fail("sections.$index.id", 'Home layout section IDs must be unique.');
            }
            $seen[$id] = true;

            $visible = $section['visible'] ?? null;
            if (! is_bool($visible)) {
                self::fail("sections.$index.visible", 'Section visibility must be a boolean.');
            }
            if (in_array($id, [self::HERO, self::COLLECTION], true) && ! $visible) {
                self::fail(
                    "sections.$index.visible",
                    sprintf('The %s section is required and cannot be hidden.', $id),
                );
            }

            $normalized[] = self::normalizeSection($id, $visible, $section, $index);
        }

        foreach (self::sectionIds() as $id) {
            if (! isset($seen[$id])) {
                self::fail('sections', sprintf('Missing required Home layout section: %s.', $id));
            }
        }

        return ['sections' => $normalized];
    }

    /**
     * @param  array<string, mixed>|null  $payload
     * @return array<string, mixed>
     */
    public static function editablePayload(?array $payload): array
    {
        if ($payload === null) {
            return self::defaultPayload();
        }

        try {
            return self::validateAndNormalize($payload);
        } catch (ValidationException) {
            return self::defaultPayload();
        }
    }

    /**
     * @param  array<string, mixed>  $section
     * @return array<string, mixed>
     */
    private static function normalizeSection(string $id, bool $visible, array $section, int $index): array
    {
        return match ($id) {
            self::COLLECTION => [
                'id' => $id,
                'visible' => $visible,
                'eyebrow' => self::boundedString($section, 'eyebrow', 80, $index),
                'title' => self::boundedString($section, 'title', 120, $index),
            ],
            self::SMALL_CHANGES => [
                'id' => $id,
                'visible' => $visible,
                'title' => self::boundedString($section, 'title', 120, $index),
                'body' => self::boundedString($section, 'body', 300, $index),
            ],
            default => [
                'id' => $id,
                'visible' => $visible,
            ],
        };
    }

    /**
     * @param  array<string, mixed>  $section
     */
    private static function boundedString(array $section, string $key, int $max, int $index): string
    {
        $value = $section[$key] ?? null;
        if (! is_string($value)) {
            self::fail("sections.$index.$key", sprintf('%s must be a string.', $key));
        }

        $value = trim($value);
        $length = mb_strlen($value);
        if ($length < 1 || $length > $max) {
            self::fail(
                "sections.$index.$key",
                sprintf('%s must contain between 1 and %d characters.', $key, $max),
            );
        }

        return $value;
    }

    private static function fail(string $field, string $message): never
    {
        throw ValidationException::withMessages([$field => [$message]]);
    }
}
