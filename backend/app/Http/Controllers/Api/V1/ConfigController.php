<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;

final class ConfigController extends Controller
{
    public function __invoke(): JsonResponse
    {
        return response()->json([
            'data' => [
                'brand' => config('walka.brand'),
                'release' => config('walka.release'),
                'api_version' => config('walka.api_version'),
                'purchase_mode' => config('walka.purchase_mode'),
            ],
        ]);
    }
}
