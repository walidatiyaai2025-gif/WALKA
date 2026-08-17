<?php

namespace Tests\Feature;

use App\Models\Product;
use App\Services\Content\RelatedProductsCatalogValidator;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class RelatedProductsCatalogValidatorTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(WalkaCatalogSeeder::class);
    }

    public function test_visible_dynamic_products_are_accepted(): void
    {
        $products = Product::query()
            ->where('is_visible', true)
            ->whereHas('variants', fn ($query) => $query->where('is_visible', true))
            ->limit(2)
            ->get();

        $this->assertCount(2, $products);

        $payload = [
            'relationships' => [[
                'product_id' => $products[0]->id,
                'related_product_ids' => [$products[1]->id],
            ]],
        ];

        $validated = app(RelatedProductsCatalogValidator::class)->validate($payload);
        $this->assertSame($payload, $validated);
    }

    public function test_hidden_or_deleted_target_fails_current_catalog_validation(): void
    {
        $products = Product::query()
            ->where('is_visible', true)
            ->whereHas('variants', fn ($query) => $query->where('is_visible', true))
            ->limit(2)
            ->get();

        $this->assertCount(2, $products);

        $target = $products[1];
        $target->forceFill(['is_visible' => false])->save();

        $this->expectException(ValidationException::class);
        app(RelatedProductsCatalogValidator::class)->validate([
            'relationships' => [[
                'product_id' => $products[0]->id,
                'related_product_ids' => [$target->id],
            ]],
        ]);
    }
}
