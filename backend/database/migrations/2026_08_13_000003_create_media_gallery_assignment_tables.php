<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // MySQL limits identifiers to 64 characters. Explicit short names keep
        // the variant indexes portable, and the hasTable guards make this
        // migration safe to retry after a DDL failure part-way through setup.
        if (! Schema::hasTable('product_media_gallery_items')) {
            Schema::create('product_media_gallery_items', function (Blueprint $table): void {
                $table->ulid('id')->primary();
                $table->string('product_id');
                $table->ulid('media_asset_id');
                $table->unsignedTinyInteger('position');
                $table->char('created_by_fingerprint', 64);
                $table->timestamps();

                $table->foreign('product_id')->references('id')->on('products')->cascadeOnDelete();
                $table->foreign('media_asset_id')->references('id')->on('media_assets')->restrictOnDelete();
                $table->unique(['product_id', 'media_asset_id'], 'pmgi_product_media_unique');
                $table->unique(['product_id', 'position'], 'pmgi_product_position_unique');
                $table->index(['media_asset_id', 'product_id'], 'pmgi_media_product_index');
            });
        }

        if (! Schema::hasTable('variant_media_gallery_items')) {
            Schema::create('variant_media_gallery_items', function (Blueprint $table): void {
                $table->ulid('id')->primary();
                $table->string('product_variant_id');
                $table->ulid('media_asset_id');
                $table->unsignedTinyInteger('position');
                $table->char('created_by_fingerprint', 64);
                $table->timestamps();

                $table->foreign('product_variant_id')->references('id')->on('product_variants')->cascadeOnDelete();
                $table->foreign('media_asset_id')->references('id')->on('media_assets')->restrictOnDelete();
                $table->unique(['product_variant_id', 'media_asset_id'], 'vmgi_variant_media_unique');
                $table->unique(['product_variant_id', 'position'], 'vmgi_variant_position_unique');
                $table->index(['media_asset_id', 'product_variant_id'], 'vmgi_media_variant_index');
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('variant_media_gallery_items');
        Schema::dropIfExists('product_media_gallery_items');
    }
};
