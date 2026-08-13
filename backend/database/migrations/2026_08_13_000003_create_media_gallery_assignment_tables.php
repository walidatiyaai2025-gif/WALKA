<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('product_media_gallery_items', function (Blueprint $table): void {
            $table->ulid('id')->primary();
            $table->string('product_id', 120);
            $table->ulid('media_asset_id');
            $table->unsignedTinyInteger('position');
            $table->char('created_by_fingerprint', 64);
            $table->timestamps();

            $table->foreign('product_id')->references('id')->on('products')->cascadeOnDelete();
            $table->foreign('media_asset_id')->references('id')->on('media_assets')->restrictOnDelete();
            $table->unique(['product_id', 'media_asset_id']);
            $table->unique(['product_id', 'position']);
            $table->index(['media_asset_id', 'product_id']);
        });

        Schema::create('variant_media_gallery_items', function (Blueprint $table): void {
            $table->ulid('id')->primary();
            $table->string('product_variant_id', 160);
            $table->ulid('media_asset_id');
            $table->unsignedTinyInteger('position');
            $table->char('created_by_fingerprint', 64);
            $table->timestamps();

            $table->foreign('product_variant_id')->references('id')->on('product_variants')->cascadeOnDelete();
            $table->foreign('media_asset_id')->references('id')->on('media_assets')->restrictOnDelete();
            $table->unique(['product_variant_id', 'media_asset_id']);
            $table->unique(['product_variant_id', 'position']);
            $table->index(['media_asset_id', 'product_variant_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('variant_media_gallery_items');
        Schema::dropIfExists('product_media_gallery_items');
    }
};
