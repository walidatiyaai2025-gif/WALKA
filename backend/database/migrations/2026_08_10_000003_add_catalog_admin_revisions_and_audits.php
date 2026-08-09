<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table): void {
            $table->unsignedInteger('revision')->default(1);
        });

        Schema::table('product_variants', function (Blueprint $table): void {
            $table->unsignedInteger('revision')->default(1);
        });

        Schema::create('catalog_audits', function (Blueprint $table): void {
            $table->id();
            $table->char('actor_fingerprint', 64);
            $table->string('target_type', 32);
            $table->string('target_id', 120);
            $table->string('action', 32);
            $table->unsignedInteger('from_revision');
            $table->unsignedInteger('to_revision');
            $table->json('changes');
            $table->timestamp('created_at')->useCurrent();

            $table->index(['target_type', 'target_id']);
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('catalog_audits');

        Schema::table('product_variants', function (Blueprint $table): void {
            $table->dropColumn('revision');
        });

        Schema::table('products', function (Blueprint $table): void {
            $table->dropColumn('revision');
        });
    }
};
