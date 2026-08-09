<?php

namespace App\Data;

final readonly class ProductVariantData
{
    public function __construct(
        public string $id,
        public string $color,
        public string $asin,
        public ?string $pantone = null,
    ) {}

    /**
     * @return array{id: string, color: string, asin: string, pantone: string|null, purchase_url: string}
     */
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'color' => $this->color,
            'asin' => $this->asin,
            'pantone' => $this->pantone,
            'purchase_url' => "https://www.amazon.com/dp/{$this->asin}",
        ];
    }
}
