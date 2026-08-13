<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('media_assets', function (Blueprint $table): void {
            $table->string('source_storage_disk', 64)->nullable();
            $table->string('source_storage_path', 512)->nullable();
            $table->unique(['source_storage_disk', 'source_storage_path']);
        });
    }

    public function down(): void
    {
        Schema::table('media_assets', function (Blueprint $table): void {
            $table->dropUnique(['source_storage_disk', 'source_storage_path']);
            $table->dropColumn(['source_storage_disk', 'source_storage_path']);
        });
    }
};
