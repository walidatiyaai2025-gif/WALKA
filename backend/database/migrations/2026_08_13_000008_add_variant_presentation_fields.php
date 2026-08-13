<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('product_variants', function (Blueprint $table): void {
            $table->boolean('is_visible')->default(true)->index()->after('asin');
            $table->unsignedSmallInteger('presentation_order')->default(0)->index()->after('is_visible');
        });

        DB::table('product_variants')->update([
            'presentation_order' => DB::raw('sort_order'),
        ]);
    }

    public function down(): void
    {
        Schema::table('product_variants', function (Blueprint $table): void {
            $table->dropColumn(['is_visible', 'presentation_order']);
        });
    }
};
