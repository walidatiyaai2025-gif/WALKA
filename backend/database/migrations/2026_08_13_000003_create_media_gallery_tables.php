<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('media_galleries', function (Blueprint $table): void {
            $table->ulid('id')->primary();
            $table->string('product_id')->nullable()->unique();
            $table->string('product_variant_id')->nullable()->unique();
            $table->unsignedInteger('revision')->default(0);
            $table->char('created_by_fingerprint', 64);
            $table->char('updated_by_fingerprint', 64);
            $table->timestamps();

            $table->foreign('product_id')
                ->references('id')
                ->on('products')
                ->cascadeOnDelete();
            $table->foreign('product_variant_id')
                ->references('id')
                ->on('product_variants')
                ->cascadeOnDelete();
        });

        Schema::create('media_gallery_items', function (Blueprint $table): void {
            $table->ulid('id')->primary();
            $table->foreignUlid('media_gallery_id')
                ->constrained('media_galleries')
                ->cascadeOnDelete();
            $table->foreignUlid('media_asset_id')
                ->constrained('media_assets')
                ->restrictOnDelete();
            $table->unsignedSmallInteger('position');
            $table->char('created_by_fingerprint', 64);
            $table->timestamps();

            $table->unique(['media_gallery_id', 'position']);
            $table->unique(['media_gallery_id', 'media_asset_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('media_gallery_items');
        Schema::dropIfExists('media_galleries');
    }
};
