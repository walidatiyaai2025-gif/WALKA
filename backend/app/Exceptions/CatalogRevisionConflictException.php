<?php

namespace App\Exceptions;

use Illuminate\Http\JsonResponse;
use RuntimeException;

final class CatalogRevisionConflictException extends RuntimeException
{
    public function __construct(
        private readonly string $targetType,
        private readonly string $targetId,
        private readonly int $expectedRevision,
        private readonly int $currentRevision,
    ) {
        parent::__construct('The catalog record changed after the supplied revision was read.');
    }

    public function render(): JsonResponse
    {
        return response()->json([
            'error' => [
                'code' => 'catalog_revision_conflict',
                'message' => 'The catalog record changed after the supplied revision was read.',
                'details' => [
                    'target_type' => $this->targetType,
                    'target_id' => $this->targetId,
                    'expected_revision' => $this->expectedRevision,
                    'current_revision' => $this->currentRevision,
                ],
            ],
        ], 409);
    }
}
