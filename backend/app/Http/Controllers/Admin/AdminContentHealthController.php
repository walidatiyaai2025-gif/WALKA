<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\ContentHealthService;
use Illuminate\Http\JsonResponse;
use Illuminate\View\View;

final class AdminContentHealthController extends Controller
{
    public function __construct(
        private readonly ContentHealthService $health,
    ) {}

    public function index(): View
    {
        return view('admin.content.health', [
            'report' => $this->health->report(),
        ]);
    }

    public function json(): JsonResponse
    {
        return response()->json([
            'data' => $this->health->report(),
            'meta' => [
                'schema_version' => 1,
                'payloads_included' => false,
            ],
        ])->header('Cache-Control', 'private, no-store');
    }
}
