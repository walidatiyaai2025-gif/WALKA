<?php

namespace App\Data;

final readonly class ProductData
{
    public function __construct(
        public string $id,
        public string $name,
        public string $category,
        public array $features,
        public array $facts,
        public array $variants,
        public ?string $shortDescription = null,
        public array $highlights = [],
        public bool $featured = false,
        public int $presentationOrder = 0,
    ) {}

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
            shortDescription: $data['short_description'] ?? null,
            highlights: $data['highlights'] ?? [],
            featured: (bool) ($data['featured'] ?? false),
            presentationOrder: (int) ($data['presentation_order'] ?? 0),
        );
    }

    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'category' => $this->category,
            'features' => $this->features,
            'short_description' => $this->shortDescription,
            'highlights' => $this->highlights,
            'featured' => $this->featured,
            'presentation_order' => $this->presentationOrder,
            'facts' => $this->facts,
            'variants' => array_map(
                static fn (ProductVariantData $variant): array => $variant->toArray(),
                $this->variants,
            ),
        ];
    }
}
