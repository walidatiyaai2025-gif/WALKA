<?php

use App\Http\Controllers\Admin\AdminContentController;
use App\Http\Controllers\Admin\AdminDashboardController;
use App\Http\Controllers\Admin\AdminHomeFeaturedController;
use App\Http\Controllers\Admin\AdminHomeHeroController;
use App\Http\Controllers\Admin\AdminHomeLayoutController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::prefix('admin')
    ->name('admin.')
    ->middleware('walka.dashboard.headers')
    ->group(function (): void {
        Route::get('/login', [AdminDashboardController::class, 'loginForm'])->name('login');
        Route::post('/login', [AdminDashboardController::class, 'authenticate'])
            ->middleware('throttle:10,1')
            ->name('authenticate');

        Route::middleware('walka.dashboard')->group(function (): void {
            Route::get('/', [AdminDashboardController::class, 'dashboard'])->name('dashboard');
            Route::get('/catalog', [AdminDashboardController::class, 'catalog'])->name('catalog');
            Route::patch('/catalog/products/{product}', [AdminDashboardController::class, 'updateProduct'])
                ->name('catalog.products.update');
            Route::patch('/catalog/variants/{variant}', [AdminDashboardController::class, 'updateVariant'])
                ->where('variant', '.*')
                ->name('catalog.variants.update');

            Route::get('/content', [AdminContentController::class, 'index'])->name('content.index');
            Route::post('/content', [AdminContentController::class, 'store'])->name('content.store');

            Route::get('/content/home/hero', [AdminHomeHeroController::class, 'edit'])
                ->name('content.home.hero.edit');
            Route::patch('/content/home/hero', [AdminHomeHeroController::class, 'update'])
                ->name('content.home.hero.update');
            Route::post('/content/home/hero/publish', [AdminHomeHeroController::class, 'publish'])
                ->name('content.home.hero.publish');
            Route::post('/content/home/hero/restore', [AdminHomeHeroController::class, 'restore'])
                ->name('content.home.hero.restore');

            Route::get('/content/home/layout', [AdminHomeLayoutController::class, 'edit'])
                ->name('content.home.layout.edit');
            Route::patch('/content/home/layout', [AdminHomeLayoutController::class, 'update'])
                ->name('content.home.layout.update');
            Route::post('/content/home/layout/publish', [AdminHomeLayoutController::class, 'publish'])
                ->name('content.home.layout.publish');
            Route::post('/content/home/layout/restore', [AdminHomeLayoutController::class, 'restore'])
                ->name('content.home.layout.restore');

            Route::get('/content/home/featured', [AdminHomeFeaturedController::class, 'edit'])
                ->name('content.home.featured.edit');
            Route::patch('/content/home/featured', [AdminHomeFeaturedController::class, 'update'])
                ->name('content.home.featured.update');
            Route::post('/content/home/featured/publish', [AdminHomeFeaturedController::class, 'publish'])
                ->name('content.home.featured.publish');
            Route::post('/content/home/featured/restore', [AdminHomeFeaturedController::class, 'restore'])
                ->name('content.home.featured.restore');

            Route::get('/content/{content}', [AdminContentController::class, 'show'])->name('content.show');
            Route::patch('/content/{content}/draft', [AdminContentController::class, 'updateDraft'])
                ->name('content.draft.update');
            Route::post('/content/{content}/publish', [AdminContentController::class, 'publish'])
                ->name('content.publish');
            Route::post('/content/{content}/restore', [AdminContentController::class, 'restore'])
                ->name('content.restore');

            Route::get('/audits', [AdminDashboardController::class, 'audits'])->name('audits');
            Route::post('/logout', [AdminDashboardController::class, 'logout'])->name('logout');
        });
    });
