<?php

namespace App\Contracts;

use App\Data\ProductData;

interface CatalogRepository
{
    /**
     * @return list<ProductData>
     */
    public function all(): array;
}
