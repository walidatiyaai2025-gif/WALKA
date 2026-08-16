<?php

use App\Http\Middleware\RequireCatalogAdminToken;
use App\Http\Middleware\RequireDashboardCapability;
use App\Http\Middleware\RequireDashboardSession;
use App\Http\Middleware\SecureDashboardHeaders;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
        then: function (): void {
            require base_path('routes/commerce-admin.php');
        },
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'catalog.admin' => RequireCatalogAdminToken::class,
            'walka.dashboard' => RequireDashboardSession::class,
            'walka.dashboard.can' => RequireDashboardCapability::class,
            'walka.dashboard.headers' => SecureDashboardHeaders::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*'),
        );
    })->create();
