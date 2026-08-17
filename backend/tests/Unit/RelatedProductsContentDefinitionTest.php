<?php

namespace Tests\Unit;

use App\Services\Content\RelatedProductsContentDefinition;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class RelatedProductsContentDefinitionTest extends TestCase
{
    public function test_arbitrary_dynamic_catalog_ids_are_normalized_without_commerce_fields(): void
    {
        $payload = RelatedProductsContentDefinition::validateAndNormalize([
            'relationships' => [
                [
                    'product_id' => 'travel-mug',
                    'related_product_ids' => ['desk-organizer', 'bento-pro'],
                    'url' => 'https://example.com/forbidden',
                    'asin' => 'FORBIDDEN',
                ],
                [
                    'product_id' => 'bento-pro',
                    'related_product_ids' => ['travel-mug'],
                ],
            ],
        ]);

        $this->assertSame(['bento-pro', 'travel-mug'], array_column($payload['relationships'], 'product_id'));
        $this->assertSame(
            ['travel-mug'],
            $payload['relationships'][0]['related_product_ids'],
        );
        $this->assertArrayNotHasKey('url', $payload['relationships'][1]);
        $this->assertArrayNotHasKey('asin', $payload['relationships'][1]);
    }

    public function test_self_duplicates_and_more_than_four_targets_fail_closed(): void
    {
        $this->expectValidation([
            'relationships' => [[
                'product_id' => 'alpha',
                'related_product_ids' => ['alpha'],
            ]],
        ]);

        $this->expectValidation([
            'relationships' => [[
                'product_id' => 'alpha',
                'related_product_ids' => ['beta', 'beta'],
            ]],
        ]);

        $this->expectValidation([
            'relationships' => [[
                'product_id' => 'alpha',
                'related_product_ids' => ['beta', 'gamma', 'delta', 'epsilon', 'zeta'],
            ]],
        ]);
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    private function expectValidation(array $payload): void
    {
        try {
            RelatedProductsContentDefinition::validateAndNormalize($payload);
            $this->fail('Expected related-products validation to fail.');
        } catch (ValidationException $exception) {
            $this->assertNotEmpty($exception->errors());
        }
    }
}
