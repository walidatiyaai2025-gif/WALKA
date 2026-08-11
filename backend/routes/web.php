<?php

use App\Http\Controllers\Admin\AdminDashboardController;
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
            Route::get('/audits', [AdminDashboardController::class, 'audits'])->name('audits');
            Route::post('/logout', [AdminDashboardController::class, 'logout'])->name('logout');
        });
    });
