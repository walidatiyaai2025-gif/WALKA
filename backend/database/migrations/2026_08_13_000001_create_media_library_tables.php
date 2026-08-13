<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('media_assets', function (Blueprint $table): void {
            $table->ulid('id')->primary();
            $table->string('purpose', 32);
            $table->string('lifecycle', 24)->default('draft');
            $table->string('source_reference', 255)->nullable();
            $table->string('original_filename', 255);
            $table->string('original_mime', 100);
            $table->unsignedBigInteger('original_bytes');
            $table->unsignedInteger('original_width');
            $table->unsignedInteger('original_height');
            $table->char('original_sha256', 64)->unique();
            $table->string('semantic_label', 160)->nullable();
            $table->char('created_by_fingerprint', 64);
            $table->char('updated_by_fingerprint', 64);
            $table->timestamp('admitted_at')->nullable();
            $table->timestamp('archived_at')->nullable();
            $table->timestamps();

            $table->index(['purpose', 'lifecycle']);
        });

        Schema::create('media_derivatives', function (Blueprint $table): void {
            $table->ulid('id')->primary();
            $table->foreignUlid('media_asset_id')
                ->constrained('media_assets')
                ->cascadeOnDelete();
            $table->string('kind', 32);
            $table->string('storage_disk', 64);
            $table->string('storage_path', 512);
            $table->string('mime', 100);
            $table->unsignedBigInteger('bytes');
            $table->unsignedInteger('width');
            $table->unsignedInteger('height');
            $table->char('sha256', 64)->unique();
            $table->char('created_by_fingerprint', 64);
            $table->timestamps();

            $table->unique(['media_asset_id', 'kind']);
            $table->unique(['storage_disk', 'storage_path']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('media_derivatives');
        Schema::dropIfExists('media_assets');
    }
};
