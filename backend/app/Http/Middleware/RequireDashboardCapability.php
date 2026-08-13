<?php

namespace App\Http\Middleware;

use App\Enums\DashboardCapability;
use App\Enums\DashboardRole;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

final class RequireDashboardCapability
{
    public function handle(Request $request, Closure $next, string $requiredCapability): Response
    {
        $role = DashboardRole::tryFrom(
            trim((string) config('walka_dashboard.role', '')),
        );
        $capability = DashboardCapability::tryFrom($requiredCapability);

        if ($role === null || $capability === null || ! $role->allows($capability)) {
            abort(403);
        }

        return $next($request);
    }
}
