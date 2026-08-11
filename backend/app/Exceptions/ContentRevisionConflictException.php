<?php

namespace App\Exceptions;

use Illuminate\Http\JsonResponse;
use RuntimeException;

final class ContentRevisionConflictException extends RuntimeException
{
    public function __construct(
        private readonly string $contentKey,
        private readonly int $expectedRevision,
        private readonly int $currentRevision,
    ) {
        parent::__construct('The content entry changed after the supplied revision was read.');
    }

    public function render(): JsonResponse
    {
        return response()->json([
            'error' => [
                'code' => 'content_revision_conflict',
                'message' => 'The content entry changed after the supplied revision was read.',
                'details' => [
                    'content_key' => $this->contentKey,
                    'expected_revision' => $this->expectedRevision,
                    'current_revision' => $this->currentRevision,
                ],
            ],
        ], 409);
    }
}
