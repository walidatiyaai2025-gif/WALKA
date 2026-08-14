<?php

namespace Tests\Unit;

use App\Services\Content\RelatedProductsContentDefinition;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class RelatedProductsContentDefinitionTest extends TestCase
{
    public function test_default_payload_is_canonical_and_contains_no_commerce_truth(): void
    {
        $normalized = RelatedProductsContentDefinition::validateAndNormalize(
            RelatedProductsContentDefinition::defaultPayload(),
        );

        $this->assertSame(
            ['drawer-organizer', 'stainless-steel-bento-lunch-box'],
            array_column($normalized['relationships'], 'product_id'),
        );
        $this->assertSame(
            ['product_id', 'related_product_ids'],
            array_keys($normalized['relationships'][0]),
        );
        $this->assertArrayNotHasKey('url', $normalized['relationships'][0]);
        $this->assertArrayNotHasKey('asin', $normalized['relationships'][0]);
    }

    public function test_related_order_is_preserved_while_source_relationships_are_canonicalized(): void
    {
        $payload = [
            'relationships' => [
                [
                    'product_id' => 'product-z',
                    'related_product_ids' => ['product-c', 'product-b'],
                ],
                [
                    'product_id' => 'product-a',
                    'related_product_ids' => ['product-d'],
                ],
            ],
        ];

        $normalized = RelatedProductsContentDefinition::validateAndNormalize($payload);

        $this->assertSame(['product-a', 'product-z'], array_column($normalized['relationships'], 'product_id'));
        $this->assertSame(['product-c', 'product-b'], $normalized['relationships'][1]['related_product_ids']);
    }

    public function test_self_reference_duplicate_and_excess_related_ids_fail_closed(): void
    {
        $this->assertInvalid([
            'relationships' => [[
                'product_id' => 'drawer-organizer',
                'related_product_ids' => ['drawer-organizer'],
            ]],
        ]);

        $this->assertInvalid([
            'relationships' => [[
                'product_id' => 'drawer-organizer',
                'related_product_ids' => ['lunch-box', 'lunch-box'],
            ]],
        ]);

        $this->assertInvalid([
            'relationships' => [[
                'product_id' => 'drawer-organizer',
                'related_product_ids' => ['a', 'b', 'c', 'd', 'e'],
            ]],
        ]);
    }

    public function test_duplicate_source_and_invalid_ids_fail_closed(): void
    {
        $this->assertInvalid([
            'relationships' => [
                ['product_id' => 'drawer-organizer', 'related_product_ids' => []],
                ['product_id' => 'drawer-organizer', 'related_product_ids' => []],
            ],
        ]);

        $this->assertInvalid([
            'relationships' => [[
                'product_id' => 'https://example.com',
                'related_product_ids' => [],
            ]],
        ]);
    }

    public function test_unknown_private_fields_are_stripped(): void
    {
        $payload = RelatedProductsContentDefinition::defaultPayload();
        $payload['private_note'] = 'never-public';
        $payload['relationships'][0]['amazon_url'] = 'https://example.com';
        $payload['relationships'][0]['script'] = '<script>bad</script>';

        $normalized = RelatedProductsContentDefinition::validateAndNormalize($payload);

        $this->assertSame(['relationships'], array_keys($normalized));
        $this->assertSame(
            ['product_id', 'related_product_ids'],
            array_keys($normalized['relationships'][0]),
        );
    }

    /** @param array<string, mixed> $payload */
    private function assertInvalid(array $payload): void
    {
        try {
            RelatedProductsContentDefinition::validateAndNormalize($payload);
            $this->fail('Expected related-product payload validation to fail.');
        } catch (ValidationException $exception) {
            $this->assertNotEmpty($exception->errors());
        }
    }
}
