<?php

namespace App\Data;

final readonly class ProductData
{
    /**
     * @param  list<string>  $features
     * @param  array<string, mixed>  $facts
     * @param  list<ProductVariantData>  $variants
     */
    public function __construct(
        public string $id,
        public string $name,
        public string $category,
        public array $features,
        public array $facts,
        public array $variants,
    ) {}

    /**
     * @param array{
     *   id: string,
     *   name: string,
     *   category: string,
     *   features: list<string>,
     *   facts: array<string, mixed>,
     *   variants: list<array{id: string, color: string, asin: string, pantone?: string|null}>
     * } $data
     */
    public static function fromArray(array $data): self
    {
        return new self(
            id: $data['id'],
            name: $data['name'],
            category: $data['category'],
            features: $data['features'],
            facts: $data['facts'],
            variants: array_map(
                static fn (array $variant): ProductVariantData => new ProductVariantData(
                    id: $variant['id'],
                    color: $variant['color'],
                    asin: $variant['asin'],
                    pantone: $variant['pantone'] ?? null,
                ),
                $data['variants'],
            ),
        );
    }

    /**
     * @return array{
     *   id: string,
     *   name: string,
     *   category: string,
     *   features: list<string>,
     *   facts: array<string, mixed>,
     *   variants: list<array{id: string, color: string, asin: string, pantone: string|null, purchase_url: string}>
     * }
     */
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'category' => $this->category,
            'features' => $this->features,
            'facts' => $this->facts,
            'variants' => array_map(
                static fn (ProductVariantData $variant): array => $variant->toArray(),
                $this->variants,
            ),
        ];
    }
}
