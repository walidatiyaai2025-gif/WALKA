<?php

use App\Http\Controllers\Admin\AdminCommerceMapController;
use Illuminate\Support\Facades\Route;

Route::prefix('admin')
    ->name('admin.')
    ->middleware(['web', 'walka.dashboard.headers', 'walka.dashboard'])
    ->group(function (): void {
        Route::get('/content/commerce/amazon', [AdminCommerceMapController::class, 'edit'])
            ->middleware('walka.dashboard.can:content.view')
            ->name('content.commerce.edit');
        Route::patch('/content/commerce/amazon', [AdminCommerceMapController::class, 'update'])
            ->middleware('walka.dashboard.can:content.write')
            ->name('content.commerce.update');
        Route::post('/content/commerce/amazon/publish', [AdminCommerceMapController::class, 'publish'])
            ->middleware('walka.dashboard.can:content.publish')
            ->name('content.commerce.publish');
        Route::post('/content/commerce/amazon/restore', [AdminCommerceMapController::class, 'restore'])
            ->middleware('walka.dashboard.can:content.restore')
            ->name('content.commerce.restore');
    });
