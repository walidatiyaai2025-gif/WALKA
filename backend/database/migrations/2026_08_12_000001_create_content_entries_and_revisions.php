<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('content_entries', function (Blueprint $table): void {
            $table->id();
            $table->string('content_key', 160)->unique();
            $table->string('content_type', 64);
            $table->unsignedInteger('revision')->default(0);
            $table->unsignedInteger('published_revision')->nullable();
            $table->json('draft_payload');
            $table->json('published_payload')->nullable();
            $table->timestamp('published_at')->nullable();
            $table->timestamps();

            $table->index(['content_type', 'content_key']);
        });

        Schema::create('content_revisions', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('content_entry_id')->constrained('content_entries')->cascadeOnDelete();
            $table->unsignedInteger('revision');
            $table->string('action', 32);
            $table->json('payload');
            $table->unsignedInteger('source_revision')->nullable();
            $table->char('actor_fingerprint', 64);
            $table->timestamp('created_at')->useCurrent();

            $table->unique(['content_entry_id', 'revision']);
            $table->index(['content_entry_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('content_revisions');
        Schema::dropIfExists('content_entries');
    }
};
