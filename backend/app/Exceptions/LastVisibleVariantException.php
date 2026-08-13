<?php

namespace App\Exceptions;

use RuntimeException;

final class LastVisibleVariantException extends RuntimeException
{
    public function __construct(public readonly string $productId)
    {
        parent::__construct("Product {$productId} must retain at least one visible variant.");
    }
}
