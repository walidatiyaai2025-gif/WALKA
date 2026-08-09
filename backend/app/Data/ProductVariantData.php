<?php

namespace App\Data;

final readonly class ProductVariantData
{
    public function __construct(
        public string $id,
        public string $color,
        public string $asin,
    ) {}

    /**
     * @return array{id: string, color: string, asin: string, purchase_url: string}
     */
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'color' => $this->color,
            'asin' => $this->asin,
            'purchase_url' => "https://www.amazon.com/dp/{$this->asin}",
        ];
    }
}
