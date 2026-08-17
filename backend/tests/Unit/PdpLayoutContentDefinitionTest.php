<?php

namespace Tests\Unit;

use App\Services\Content\PdpLayoutContentDefinition;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class PdpLayoutContentDefinitionTest extends TestCase
{
    public function test_default_payload_contains_every_allowlisted_section_once(): void
    {
        $payload = PdpLayoutContentDefinition::validateAndNormalize(PdpLayoutContentDefinition::defaultPayload());
        $ids = array_column($payload['sections'], 'id');

        $this->assertSame(PdpLayoutContentDefinition::sectionIds(), $ids);
        $this->assertCount(count($ids), array_unique($ids));
    }

    public function test_optional_usage_and_editorial_sections_may_be_hidden(): void
    {
        $payload = PdpLayoutContentDefinition::defaultPayload();
        foreach ($payload['sections'] as &$section) {
            if (in_array($section['id'], [PdpLayoutContentDefinition::USAGE, PdpLayoutContentDefinition::EDITORIAL], true)) {
                $section['visible'] = false;
            }
        }
        unset($section);

        $normalized = PdpLayoutContentDefinition::validateAndNormalize($payload);
        $visibility = collect($normalized['sections'])->mapWithKeys(static fn (array $section): array => [$section['id'] => $section['visible']]);

        $this->assertFalse($visibility[PdpLayoutContentDefinition::USAGE]);
        $this->assertFalse($visibility[PdpLayoutContentDefinition::EDITORIAL]);
    }

    public function test_required_sections_cannot_be_hidden(): void
    {
        foreach (PdpLayoutContentDefinition::requiredVisibleSectionIds() as $requiredId) {
            $payload = PdpLayoutContentDefinition::defaultPayload();
            foreach ($payload['sections'] as &$section) {
                if ($section['id'] === $requiredId) {
                    $section['visible'] = false;
                    break;
                }
            }
            unset($section);

            $this->expectValidation($payload);
        }
    }

    public function test_unknown_duplicate_and_missing_sections_fail_closed(): void
    {
        $unknown = PdpLayoutContentDefinition::defaultPayload();
        $unknown['sections'][0]['id'] = 'remote_html';
        $this->expectValidation($unknown);

        $duplicate = PdpLayoutContentDefinition::defaultPayload();
        $duplicate['sections'][1]['id'] = $duplicate['sections'][0]['id'];
        $this->expectValidation($duplicate);

        $missing = PdpLayoutContentDefinition::defaultPayload();
        array_pop($missing['sections']);
        $this->expectValidation($missing);
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    private function expectValidation(array $payload): void
    {
        try {
            PdpLayoutContentDefinition::validateAndNormalize($payload);
            $this->fail('Expected PDP layout validation to fail.');
        } catch (ValidationException $exception) {
            $this->assertNotEmpty($exception->errors());
        }
    }
}
