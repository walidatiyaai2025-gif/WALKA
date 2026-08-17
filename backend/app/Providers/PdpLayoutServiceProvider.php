<?php

namespace App\Providers;

use App\Http\Controllers\Admin\AdminPdpLayoutController;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\ServiceProvider;

final class PdpLayoutServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        Route::middleware(['web', 'walka.dashboard.headers', 'walka.dashboard'])
            ->prefix('admin')
            ->name('admin.')
            ->group(function (): void {
                Route::get('/content/pdp/layout', [AdminPdpLayoutController::class, 'edit'])
                    ->middleware('walka.dashboard.can:content.view')
                    ->name('content.pdp.layout.edit');
                Route::patch('/content/pdp/layout', [AdminPdpLayoutController::class, 'update'])
                    ->middleware('walka.dashboard.can:content.write')
                    ->name('content.pdp.layout.update');
                Route::post('/content/pdp/layout/publish', [AdminPdpLayoutController::class, 'publish'])
                    ->middleware('walka.dashboard.can:content.publish')
                    ->name('content.pdp.layout.publish');
                Route::post('/content/pdp/layout/restore', [AdminPdpLayoutController::class, 'restore'])
                    ->middleware('walka.dashboard.can:content.restore')
                    ->name('content.pdp.layout.restore');
            });
    }
}
