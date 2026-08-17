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
            $table->ulid('source_media_asset_id');
            $table->ulid('replacement_media_asset_id');
            $table->ulid('rollback_of_event_id')->nullable();
            $table->json('before_assignments');
            $table->json('after_assignments');
            $table->char('before_fingerprint', 64);
            $table->char('after_fingerprint', 64);
            $table->string('reason', 500);
            $table->char('actor_fingerprint', 64);
            $table->timestamp('created_at');

            // Keep every identifier explicitly below MySQL's 64-character limit.
            $table->foreign('source_media_asset_id', 'mre_source_media_fk')
                ->references('id')
                ->on('media_assets')
                ->restrictOnDelete();
            $table->foreign('replacement_media_asset_id', 'mre_replacement_media_fk')
                ->references('id')
                ->on('media_assets')
                ->restrictOnDelete();
            $table->unique('rollback_of_event_id', 'mre_rollback_event_unique');
            $table->foreign('rollback_of_event_id', 'mre_rollback_event_fk')
                ->references('id')
                ->on('media_replacement_events')
                ->restrictOnDelete();
            $table->index(['source_media_asset_id', 'created_at'], 'mre_source_created_index');
            $table->index(['replacement_media_asset_id', 'created_at'], 'mre_replacement_created_index');
            $table->index(['operation', 'created_at'], 'mre_operation_created_index');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('media_replacement_events');
    }
};
