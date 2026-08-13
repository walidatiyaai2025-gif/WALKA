<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('media_replacement_events', function (Blueprint $table): void {
            $table->ulid('id')->primary();
            $table->string('operation', 16);
            $table->foreignUlid('source_media_asset_id')
                ->constrained('media_assets')
                ->restrictOnDelete();
            $table->foreignUlid('replacement_media_asset_id')
                ->constrained('media_assets')
                ->restrictOnDelete();
            $table->ulid('rollback_of_event_id')->nullable()->unique();
            $table->json('before_assignments');
            $table->json('after_assignments');
            $table->char('before_fingerprint', 64);
            $table->char('after_fingerprint', 64);
            $table->char('actor_fingerprint', 64);
            $table->timestamp('created_at');

            $table->foreign('rollback_of_event_id')
                ->references('id')
                ->on('media_replacement_events')
                ->restrictOnDelete();
            $table->index(['source_media_asset_id', 'created_at']);
            $table->index(['replacement_media_asset_id', 'created_at']);
            $table->index(['operation', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('media_replacement_events');
    }
};
