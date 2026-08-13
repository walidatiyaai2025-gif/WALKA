<?php

use App\Http\Controllers\Admin\AdminCategoryPresentationController;
use App\Http\Controllers\Admin\AdminContentController;
use App\Http\Controllers\Admin\AdminDashboardController;
use App\Http\Controllers\Admin\AdminHomeBannerController;
use App\Http\Controllers\Admin\AdminHomeFeaturedController;
use App\Http\Controllers\Admin\AdminHomeHeroController;
use App\Http\Controllers\Admin\AdminHomeLayoutController;
use App\Http\Controllers\Admin\AdminMediaController;
use App\Http\Controllers\Admin\AdminMediaGalleryController;
use App\Http\Controllers\Admin\AdminSearchPresentationController;
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

            Route::get('/media', [AdminMediaController::class, 'index'])->name('media.index');
            Route::post('/media/uploads', [AdminMediaController::class, 'store'])->name('media.store');
            Route::get('/media/galleries', [AdminMediaGalleryController::class, 'index'])
                ->name('media.galleries.index');
            Route::put('/media/galleries/products/{product}', [AdminMediaGalleryController::class, 'updateProduct'])
                ->name('media.galleries.products.update');
            Route::put('/media/galleries/variants/{variant}', [AdminMediaGalleryController::class, 'updateVariant'])
                ->where('variant', '.*')
                ->name('media.galleries.variants.update');

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

            Route::get('/content/home/banner', [AdminHomeBannerController::class, 'edit'])
                ->name('content.home.banner.edit');
            Route::patch('/content/home/banner', [AdminHomeBannerController::class, 'update'])
                ->name('content.home.banner.update');
            Route::post('/content/home/banner/publish', [AdminHomeBannerController::class, 'publish'])
                ->name('content.home.banner.publish');
            Route::post('/content/home/banner/restore', [AdminHomeBannerController::class, 'restore'])
                ->name('content.home.banner.restore');

            Route::get('/content/categories', [AdminCategoryPresentationController::class, 'edit'])
                ->name('content.categories.edit');
            Route::patch('/content/categories', [AdminCategoryPresentationController::class, 'update'])
                ->name('content.categories.update');
            Route::post('/content/categories/publish', [AdminCategoryPresentationController::class, 'publish'])
                ->name('content.categories.publish');
            Route::post('/content/categories/restore', [AdminCategoryPresentationController::class, 'restore'])
                ->name('content.categories.restore');

            Route::get('/content/search', [AdminSearchPresentationController::class, 'edit'])
                ->name('content.search.edit');
            Route::patch('/content/search', [AdminSearchPresentationController::class, 'update'])
                ->name('content.search.update');
            Route::post('/content/search/publish', [AdminSearchPresentationController::class, 'publish'])
                ->name('content.search.publish');
            Route::post('/content/search/restore', [AdminSearchPresentationController::class, 'restore'])
                ->name('content.search.restore');

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
