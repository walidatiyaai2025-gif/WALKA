<?php

use App\Http\Controllers\Api\V1\Admin\CatalogAdminController;
use App\Http\Controllers\Api\V1\Admin\CatalogAuditController;
use App\Http\Controllers\Api\V1\CatalogController;
use App\Http\Controllers\Api\V1\ConfigController;
use App\Http\Controllers\Api\V1\HealthController;
use App\Http\Controllers\Api\V1\ProductMediaGalleryController;
use App\Http\Controllers\Api\V1\PublishedContentController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->name('api.v1.')->group(function (): void {
    Route::get('/health', HealthController::class)->name('health');
    Route::get('/config', ConfigController::class)->name('config');
    Route::get('/catalog', CatalogController::class)->name('catalog');
    Route::get('/media/product-galleries', ProductMediaGalleryController::class)
        ->name('media.product-galleries');
    Route::get('/content/home', [PublishedContentController::class, 'home'])->name('content.home');
    Route::get('/content/home-layout', [PublishedContentController::class, 'homeLayout'])
        ->name('content.home-layout');
    Route::get('/content/home-featured', [PublishedContentController::class, 'homeFeatured'])
        ->name('content.home-featured');
    Route::get('/content/home-banner', [PublishedContentController::class, 'homeBanner'])
        ->name('content.home-banner');
    Route::get('/content/categories', [PublishedContentController::class, 'categories'])
        ->name('content.categories');
    Route::get('/content/search', [PublishedContentController::class, 'search'])
        ->name('content.search');

    Route::prefix('admin/catalog')
        ->middleware('catalog.admin')
        ->name('admin.catalog.')
        ->group(function (): void {
            Route::get('/', [CatalogAdminController::class, 'index'])->name('index');
            Route::get('/audits', [CatalogAuditController::class, 'index'])->name('audits.index');
            Route::patch('/products/{product}', [CatalogAdminController::class, 'updateProduct'])
                ->name('products.update');
            Route::patch('/variants/{variant}', [CatalogAdminController::class, 'updateVariant'])
                ->name('variants.update');
        });
});
