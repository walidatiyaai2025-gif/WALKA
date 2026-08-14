<?php

namespace Tests\Unit;

use App\Services\Content\PdpLayoutContentDefinition;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class PdpLayoutContentDefinitionTest extends TestCase
{
    public function test_default_payload_contains_every_allowlisted_section_once(): void
    {
        $payload = PdpLayoutContentDefinition::validateAndNormalize(
            PdpLayoutContentDefinition::defaultPayload(),
        );

        $ids = array_column($payload['sections'], 'id');

        $this->assertSame(PdpLayoutContentDefinition::sectionIds(), $ids);
        $this->assertCount(count(PdpLayoutContentDefinition::sectionIds()), array_unique($ids));
        $this->assertTrue(collect($payload['sections'])->every(
            static fn (array $section): bool => $section['visible'] === true,
        ));
    }

    public function test_optional_usage_and_editorial_sections_may_be_hidden(): void
    {
        $payload = PdpLayoutContentDefinition::defaultPayload();

        foreach ($payload['sections'] as &$section) {
            if (in_array($section['id'], [
                PdpLayoutContentDefinition::USAGE,
                PdpLayoutContentDefinition::EDITORIAL,
            ], true)) {
                $section['visible'] = false;
            }
        }
        unset($section);

        $normalized = PdpLayoutContentDefinition::validateAndNormalize($payload);

        $visibility = collect($normalized['sections'])
            ->mapWithKeys(static fn (array $section): array => [$section['id'] => $section['visible']]);

        $this->assertFalse($visibility[PdpLayoutContentDefinition::USAGE]);
        $this->assertFalse($visibility[PdpLayoutContentDefinition::EDITORIAL]);
    }

    public function test_required_product_truth_sections_cannot_be_hidden(): void
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

            try {
                PdpLayoutContentDefinition::validateAndNormalize($payload);
                $this->fail(sprintf('Expected %s to be protected from hiding.', $requiredId));
            } catch (ValidationException $exception) {
                $this->assertNotEmpty($exception->errors());
            }
        }
    }

    public function test_unknown_duplicate_and_missing_sections_fail_closed(): void
    {
        $unknown = PdpLayoutContentDefinition::defaultPayload();
        $unknown['sections'][0]['id'] = 'remote_html';
        $this->assertInvalid($unknown);

        $duplicate = PdpLayoutContentDefinition::defaultPayload();
        $duplicate['sections'][1]['id'] = $duplicate['sections'][0]['id'];
        $this->assertInvalid($duplicate);

        $missing = PdpLayoutContentDefinition::defaultPayload();
        array_pop($missing['sections']);
        $this->assertInvalid($missing);
    }

    public function test_normalization_strips_unrecognized_section_metadata(): void
    {
        $payload = PdpLayoutContentDefinition::defaultPayload();
        $payload['sections'][0]['private_note'] = 'do-not-publish';
        $payload['sections'][1]['remote_widget'] = ['type' => 'script'];

        $normalized = PdpLayoutContentDefinition::validateAndNormalize($payload);

        $this->assertArrayNotHasKey('private_note', $normalized['sections'][0]);
        $this->assertArrayNotHasKey('remote_widget', $normalized['sections'][1]);
        $this->assertSame(['id', 'visible'], array_keys($normalized['sections'][0]));
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    private function assertInvalid(array $payload): void
    {
        try {
            PdpLayoutContentDefinition::validateAndNormalize($payload);
            $this->fail('Expected PDP layout validation to fail.');
        } catch (ValidationException $exception) {
            $this->assertNotEmpty($exception->errors());
        }
    }
}
