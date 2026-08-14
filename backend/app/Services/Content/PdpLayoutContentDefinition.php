<?php

namespace App\Services\Content;

use Illuminate\Validation\ValidationException;

final class PdpLayoutContentDefinition
{
    public const KEY = 'pdp.layout';

    public const TYPE = 'pdp.layout';

    public const SCHEMA_VERSION = 1;

    public const GALLERY = 'gallery';

    public const IDENTITY = 'identity';

    public const VARIANTS = 'variants';

    public const USAGE = 'usage';

    public const FACTS = 'facts';

    public const EDITORIAL = 'editorial';

    public const SPECIFICATIONS = 'specifications';

    public const AMAZON_TRUST = 'amazon_trust';

    /**
     * @return list<string>
     */
    public static function sectionIds(): array
    {
        return [
            self::GALLERY,
            self::IDENTITY,
            self::VARIANTS,
            self::USAGE,
            self::FACTS,
            self::EDITORIAL,
            self::SPECIFICATIONS,
            self::AMAZON_TRUST,
        ];
    }

    /**
     * Sections that carry product identity, verified facts/specifications, or
     * the official Amazon handoff trust boundary may be reordered but cannot
     * be hidden by remote content configuration.
     *
     * @return list<string>
     */
    public static function requiredVisibleSectionIds(): array
    {
        return [
            self::GALLERY,
            self::IDENTITY,
            self::VARIANTS,
            self::FACTS,
            self::SPECIFICATIONS,
            self::AMAZON_TRUST,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public static function defaultPayload(): array
    {
        return [
            'sections' => array_map(
                static fn (string $id): array => [
                    'id' => $id,
                    'visible' => true,
                ],
                self::sectionIds(),
            ),
        ];
    }

    /**
     * Validate and normalize the exact public PDP layout contract.
     *
     * Unknown fields are intentionally dropped so private/admin metadata can
     * never leak through the public content API.
     *
     * @param  array<string, mixed>  $payload
     * @return array<string, mixed>
     */
    public static function validateAndNormalize(array $payload): array
    {
        $sections = $payload['sections'] ?? null;
        if (! is_array($sections) || ! array_is_list($sections)) {
            self::fail('sections', 'PDP layout sections must be an ordered array.');
        }

        if (count($sections) !== count(self::sectionIds())) {
            self::fail('sections', 'PDP layout must contain every supported section exactly once.');
        }

        $seen = [];
        $normalized = [];

        foreach ($sections as $index => $section) {
            if (! is_array($section)) {
                self::fail("sections.$index", 'Each PDP layout section must be an object.');
            }

            $id = $section['id'] ?? null;
            if (! is_string($id) || ! in_array($id, self::sectionIds(), true)) {
                self::fail("sections.$index.id", 'Unknown PDP layout section ID.');
            }
            if (isset($seen[$id])) {
                self::fail("sections.$index.id", 'PDP layout section IDs must be unique.');
            }
            $seen[$id] = true;

            $visible = $section['visible'] ?? null;
            if (! is_bool($visible)) {
                self::fail("sections.$index.visible", 'PDP section visibility must be a boolean.');
            }
            if (in_array($id, self::requiredVisibleSectionIds(), true) && ! $visible) {
                self::fail(
                    "sections.$index.visible",
                    sprintf('The %s PDP section protects product/commerce truth and cannot be hidden.', $id),
                );
            }

            $normalized[] = [
                'id' => $id,
                'visible' => $visible,
            ];
        }

        foreach (self::sectionIds() as $id) {
            if (! isset($seen[$id])) {
                self::fail('sections', sprintf('Missing required PDP layout section: %s.', $id));
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

    private static function fail(string $field, string $message): never
    {
        throw ValidationException::withMessages([$field => [$message]]);
    }
}
