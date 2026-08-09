<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\CatalogAudit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

final class CatalogAuditController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $limit = max(1, min($request->integer('limit', 50), 100));

        $audits = CatalogAudit::query()
            ->orderByDesc('id')
            ->limit($limit)
            ->get()
            ->map(static fn (CatalogAudit $audit): array => [
                'id' => $audit->id,
                'actor_fingerprint' => $audit->actor_fingerprint,
                'target_type' => $audit->target_type,
                'target_id' => $audit->target_id,
                'action' => $audit->action,
                'from_revision' => $audit->from_revision,
                'to_revision' => $audit->to_revision,
                'changes' => $audit->changes,
                'created_at' => $audit->created_at?->toISOString(),
            ])
            ->values();

        return response()->json([
            'data' => $audits,
            'meta' => [
                'release' => config('walka.release'),
                'limit' => $limit,
            ],
        ]);
    }
}
