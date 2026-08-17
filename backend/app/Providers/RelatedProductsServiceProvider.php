<?php

namespace App\Providers;

use App\Http\Controllers\Admin\AdminRelatedProductsController;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\ServiceProvider;

final class RelatedProductsServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        Route::middleware(['web', 'walka.dashboard.headers', 'walka.dashboard'])
            ->prefix('admin')
            ->name('admin.')
            ->group(function (): void {
                Route::get('/content/pdp/related-products', [AdminRelatedProductsController::class, 'edit'])
                    ->middleware('walka.dashboard.can:content.view')
                    ->name('content.pdp.related-products.edit');
                Route::patch('/content/pdp/related-products', [AdminRelatedProductsController::class, 'update'])
                    ->middleware('walka.dashboard.can:content.write')
                    ->name('content.pdp.related-products.update');
                Route::post('/content/pdp/related-products/publish', [AdminRelatedProductsController::class, 'publish'])
                    ->middleware('walka.dashboard.can:content.publish')
                    ->name('content.pdp.related-products.publish');
                Route::post('/content/pdp/related-products/restore', [AdminRelatedProductsController::class, 'restore'])
                    ->middleware('walka.dashboard.can:content.restore')
                    ->name('content.pdp.related-products.restore');
            });
    }
}
