<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table): void {
            $table->string('short_description', 500)->nullable()->after('features');
            $table->json('highlights')->nullable()->after('short_description');
            $table->boolean('is_visible')->default(true)->index()->after('facts');
            $table->boolean('is_featured')->default(false)->index()->after('is_visible');
            $table->unsignedSmallInteger('presentation_order')->default(0)->index()->after('is_featured');
        });

        DB::table('products')->update([
            'presentation_order' => DB::raw('sort_order'),
        ]);
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table): void {
            $table->dropColumn([
                'short_description',
                'highlights',
                'is_visible',
                'is_featured',
                'presentation_order',
            ]);
        });
    }
};
