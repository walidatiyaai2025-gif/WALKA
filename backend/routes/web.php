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
use App\Http\Controllers\Admin\AdminMediaReplacementController;
use App\Http\Controllers\Admin\AdminPdpLayoutController;
use App\Http\Controllers\Admin\AdminRelatedProductsController;
use App\Http\Controllers\Admin\AdminSearchPresentationController;
use App\Http\Controllers\Admin\AdminSurfaceMediaController;
use App\Http\Controllers\Admin\ProductPresentationController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::prefix('admin')->name('admin.')->middleware('walka.dashboard.headers')->group(function (): void {
    Route::get('/login', [AdminDashboardController::class, 'loginForm'])->name('login');
    Route::post('/login', [AdminDashboardController::class, 'authenticate'])->middleware('throttle:10,1')->name('authenticate');

    Route::middleware('walka.dashboard')->group(function (): void {
        Route::get('/', [AdminDashboardController::class, 'dashboard'])->middleware('walka.dashboard.can:dashboard.view')->name('dashboard');
        Route::get('/catalog', [AdminDashboardController::class, 'catalog'])->middleware('walka.dashboard.can:catalog.view')->name('catalog');
        Route::patch('/catalog/products/{product}', [ProductPresentationController::class, 'update'])->middleware('walka.dashboard.can:catalog.write')->name('catalog.products.update');
        Route::patch('/catalog/variants/{variant}', [ProductPresentationController::class, 'updateVariant'])->middleware('walka.dashboard.can:catalog.write')->where('variant', '.*')->name('catalog.variants.update');

        Route::get('/media', [AdminMediaController::class, 'index'])->middleware('walka.dashboard.can:media.view')->name('media.index');
        Route::post('/media/uploads', [AdminMediaController::class, 'store'])->middleware('walka.dashboard.can:media.upload')->name('media.store');
        Route::get('/media/galleries', [AdminMediaGalleryController::class, 'index'])->middleware('walka.dashboard.can:media.view')->name('media.galleries.index');
        Route::put('/media/galleries/products/{product}', [AdminMediaGalleryController::class, 'updateProduct'])->middleware('walka.dashboard.can:media.assign')->name('media.galleries.products.update');
        Route::put('/media/galleries/variants/{variant}', [AdminMediaGalleryController::class, 'updateVariant'])->middleware('walka.dashboard.can:media.assign')->where('variant', '.*')->name('media.galleries.variants.update');
        Route::get('/media/surfaces', [AdminSurfaceMediaController::class, 'index'])->middleware('walka.dashboard.can:media.view')->name('media.surfaces.index');
        Route::patch('/media/surfaces/{slot}', [AdminSurfaceMediaController::class, 'update'])->middleware('walka.dashboard.can:media.assign')->where('slot', '.*')->name('media.surfaces.update');
        Route::get('/media/replacements', [AdminMediaReplacementController::class, 'index'])->middleware('walka.dashboard.can:media.view')->name('media.replacements.index');
        Route::post('/media/replacements', [AdminMediaReplacementController::class, 'store'])->middleware('walka.dashboard.can:media.replace')->name('media.replacements.store');
        Route::post('/media/replacements/{event}/rollback', [AdminMediaReplacementController::class, 'rollback'])->middleware('walka.dashboard.can:media.replace')->name('media.replacements.rollback');

        Route::get('/content', [AdminContentController::class, 'index'])->middleware('walka.dashboard.can:content.view')->name('content.index');
        Route::post('/content', [AdminContentController::class, 'store'])->middleware('walka.dashboard.can:content.write')->name('content.store');

        Route::get('/content/home/hero', [AdminHomeHeroController::class, 'edit'])->middleware('walka.dashboard.can:content.view')->name('content.home.hero.edit');
        Route::patch('/content/home/hero', [AdminHomeHeroController::class, 'update'])->middleware('walka.dashboard.can:content.write')->name('content.home.hero.update');
        Route::post('/content/home/hero/publish', [AdminHomeHeroController::class, 'publish'])->middleware('walka.dashboard.can:content.publish')->name('content.home.hero.publish');
        Route::post('/content/home/hero/restore', [AdminHomeHeroController::class, 'restore'])->middleware('walka.dashboard.can:content.restore')->name('content.home.hero.restore');

        Route::get('/content/home/layout', [AdminHomeLayoutController::class, 'edit'])->middleware('walka.dashboard.can:content.view')->name('content.home.layout.edit');
        Route::patch('/content/home/layout', [AdminHomeLayoutController::class, 'update'])->middleware('walka.dashboard.can:content.write')->name('content.home.layout.update');
        Route::post('/content/home/layout/publish', [AdminHomeLayoutController::class, 'publish'])->middleware('walka.dashboard.can:content.publish')->name('content.home.layout.publish');
        Route::post('/content/home/layout/restore', [AdminHomeLayoutController::class, 'restore'])->middleware('walka.dashboard.can:content.restore')->name('content.home.layout.restore');

        Route::get('/content/pdp/layout', [AdminPdpLayoutController::class, 'edit'])->middleware('walka.dashboard.can:content.view')->name('content.pdp.layout.edit');
        Route::patch('/content/pdp/layout', [AdminPdpLayoutController::class, 'update'])->middleware('walka.dashboard.can:content.write')->name('content.pdp.layout.update');
        Route::post('/content/pdp/layout/publish', [AdminPdpLayoutController::class, 'publish'])->middleware('walka.dashboard.can:content.publish')->name('content.pdp.layout.publish');
        Route::post('/content/pdp/layout/restore', [AdminPdpLayoutController::class, 'restore'])->middleware('walka.dashboard.can:content.restore')->name('content.pdp.layout.restore');

        Route::get('/content/pdp/related-products', [AdminRelatedProductsController::class, 'edit'])->middleware('walka.dashboard.can:content.view')->name('content.pdp.related-products.edit');
        Route::patch('/content/pdp/related-products', [AdminRelatedProductsController::class, 'update'])->middleware('walka.dashboard.can:content.write')->name('content.pdp.related-products.update');
        Route::post('/content/pdp/related-products/publish', [AdminRelatedProductsController::class, 'publish'])->middleware('walka.dashboard.can:content.publish')->name('content.pdp.related-products.publish');
        Route::post('/content/pdp/related-products/restore', [AdminRelatedProductsController::class, 'restore'])->middleware('walka.dashboard.can:content.restore')->name('content.pdp.related-products.restore');

        Route::get('/content/home/featured', [AdminHomeFeaturedController::class, 'edit'])->middleware('walka.dashboard.can:content.view')->name('content.home.featured.edit');
        Route::patch('/content/home/featured', [AdminHomeFeaturedController::class, 'update'])->middleware('walka.dashboard.can:content.write')->name('content.home.featured.update');
        Route::post('/content/home/featured/publish', [AdminHomeFeaturedController::class, 'publish'])->middleware('walka.dashboard.can:content.publish')->name('content.home.featured.publish');
        Route::post('/content/home/featured/restore', [AdminHomeFeaturedController::class, 'restore'])->middleware('walka.dashboard.can:content.restore')->name('content.home.featured.restore');

        Route::get('/content/home/banner', [AdminHomeBannerController::class, 'edit'])->middleware('walka.dashboard.can:content.view')->name('content.home.banner.edit');
        Route::patch('/content/home/banner', [AdminHomeBannerController::class, 'update'])->middleware('walka.dashboard.can:content.write')->name('content.home.banner.update');
        Route::post('/content/home/banner/publish', [AdminHomeBannerController::class, 'publish'])->middleware('walka.dashboard.can:content.publish')->name('content.home.banner.publish');
        Route::post('/content/home/banner/restore', [AdminHomeBannerController::class, 'restore'])->middleware('walka.dashboard.can:content.restore')->name('content.home.banner.restore');

        Route::get('/content/categories', [AdminCategoryPresentationController::class, 'edit'])->middleware('walka.dashboard.can:content.view')->name('content.categories.edit');
        Route::patch('/content/categories', [AdminCategoryPresentationController::class, 'update'])->middleware('walka.dashboard.can:content.write')->name('content.categories.update');
        Route::post('/content/categories/publish', [AdminCategoryPresentationController::class, 'publish'])->middleware('walka.dashboard.can:content.publish')->name('content.categories.publish');
        Route::post('/content/categories/restore', [AdminCategoryPresentationController::class, 'restore'])->middleware('walka.dashboard.can:content.restore')->name('content.categories.restore');

        Route::get('/content/search', [AdminSearchPresentationController::class, 'edit'])->middleware('walka.dashboard.can:content.view')->name('content.search.edit');
        Route::patch('/content/search', [AdminSearchPresentationController::class, 'update'])->middleware('walka.dashboard.can:content.write')->name('content.search.update');
        Route::post('/content/search/publish', [AdminSearchPresentationController::class, 'publish'])->middleware('walka.dashboard.can:content.publish')->name('content.search.publish');
        Route::post('/content/search/restore', [AdminSearchPresentationController::class, 'restore'])->middleware('walka.dashboard.can:content.restore')->name('content.search.restore');

        Route::get('/content/{content}', [AdminContentController::class, 'show'])->middleware('walka.dashboard.can:content.view')->name('content.show');
        Route::patch('/content/{content}/draft', [AdminContentController::class, 'updateDraft'])->middleware('walka.dashboard.can:content.write')->name('content.draft.update');
        Route::post('/content/{content}/publish', [AdminContentController::class, 'publish'])->middleware('walka.dashboard.can:content.publish')->name('content.publish');
        Route::post('/content/{content}/restore', [AdminContentController::class, 'restore'])->middleware('walka.dashboard.can:content.restore')->name('content.restore');

        Route::get('/audits', [AdminDashboardController::class, 'audits'])->middleware('walka.dashboard.can:audits.view')->name('audits');
        Route::post('/logout', [AdminDashboardController::class, 'logout'])->name('logout');
    });
});
