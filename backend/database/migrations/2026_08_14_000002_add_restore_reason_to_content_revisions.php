<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('content_revisions', function (Blueprint $table): void {
            $table->string('reason', 280)->nullable()->after('source_revision');
        });
    }

    public function down(): void
    {
        Schema::table('content_revisions', function (Blueprint $table): void {
            $table->dropColumn('reason');
        });
    }
};
