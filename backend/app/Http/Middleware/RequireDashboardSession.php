<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

final class RequireDashboardSession
{
    public function handle(Request $request, Closure $next): Response|RedirectResponse
    {
        if ($request->session()->get('walka_admin_dashboard_authenticated') !== true) {
            return redirect()->guest(route('admin.login'));
        }

        return $next($request);
    }
}
