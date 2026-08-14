<?php

namespace Tests\Unit;

use App\Services\Content\RelatedProductsCatalogValidator;
use App\Services\Content\RelatedProductsContentDefinition;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class RelatedProductsCatalogValidatorTest extends TestCase
{
    use RefreshDatabase;

    public function test_released_stable_product_ids_are_accepted(): void
    {
        $this->seed(WalkaCatalogSeeder::class);

        $payload = RelatedProductsContentDefinition::validateAndNormalize(
            RelatedProductsContentDefinition::defaultPayload(),
        );

        $this->assertSame(
            $payload,
            app(RelatedProductsCatalogValidator::class)->validate($payload),
        );
    }

    public function test_unknown_stable_product_id_is_rejected(): void
    {
        $this->seed(WalkaCatalogSeeder::class);

        $payload = [
            'relationships' => [
                [
                    'product_id' => 'drawer-organizer',
                    'related_product_ids' => ['server-authored-product'],
                ],
            ],
        ];

        $this->expectException(ValidationException::class);
        app(RelatedProductsCatalogValidator::class)->validate($payload);
    }
}
