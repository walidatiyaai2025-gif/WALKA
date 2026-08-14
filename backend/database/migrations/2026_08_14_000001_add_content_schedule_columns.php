<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('content_entries', function (Blueprint $table): void {
            $table->timestamp('scheduled_publish_at')->nullable()->after('published_at');
            $table->timestamp('scheduled_unpublish_at')->nullable()->after('scheduled_publish_at');
            $table->unsignedInteger('schedule_revision')->nullable()->after('scheduled_unpublish_at');
            $table->index(['scheduled_publish_at', 'scheduled_unpublish_at']);
        });
    }

    public function down(): void
    {
        Schema::table('content_entries', function (Blueprint $table): void {
            $table->dropIndex(['scheduled_publish_at', 'scheduled_unpublish_at']);
            $table->dropColumn([
                'scheduled_publish_at',
                'scheduled_unpublish_at',
                'schedule_revision',
            ]);
        });
    }
};
