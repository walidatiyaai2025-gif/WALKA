<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('surface_media_items', function (Blueprint $table): void {
            $table->ulid('id')->primary();
            $table->string('slot_key', 96);
            $table->ulid('media_asset_id');
            $table->unsignedTinyInteger('position');
            $table->char('created_by_fingerprint', 64);
            $table->timestamps();

            $table->foreign('media_asset_id')->references('id')->on('media_assets')->restrictOnDelete();
            $table->unique(['slot_key', 'media_asset_id']);
            $table->unique(['slot_key', 'position']);
            $table->index(['media_asset_id', 'slot_key']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('surface_media_items');
    }
};
