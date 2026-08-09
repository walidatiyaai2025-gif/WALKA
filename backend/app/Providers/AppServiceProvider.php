<?php

namespace App\Providers;

use App\Contracts\CatalogRepository;
use App\Repositories\EloquentCatalogRepository;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(CatalogRepository::class, EloquentCatalogRepository::class);
    }

    public function boot(): void
    {
        //
    }
}
