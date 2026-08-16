<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('catalog_categories', function (Blueprint $table): void {
            $table->string('id')->primary();
            $table->string('name', 120);
            $table->boolean('is_visible')->default(true)->index();
            $table->unsignedSmallInteger('sort_order')->default(0)->index();
            $table->unsignedInteger('revision')->default(1);
            $table->timestamps();
        });

        Schema::table('products', function (Blueprint $table): void {
            $table->string('category_id')->nullable()->after('category')->index();
            $table->boolean('is_visible')->default(true)->after('sort_order')->index();
        });

        Schema::table('product_variants', function (Blueprint $table): void {
            $table->string('swatch_hex', 7)->nullable()->after('color');
            $table->boolean('is_visible')->default(true)->after('sort_order')->index();
        });

        $categories = DB::table('products')
            ->select('category')
            ->whereNotNull('category')
            ->where('category', '!=', '')
            ->distinct()
            ->orderBy('category')
            ->pluck('category');

        foreach ($categories as $index => $category) {
            DB::table('catalog_categories')->insert([
                'id' => $category,
                'name' => str($category)->replace('-', ' ')->title()->toString(),
                'is_visible' => true,
                'sort_order' => $index,
                'revision' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        DB::table('products')->update([
            'category_id' => DB::raw('category'),
        ]);

        $swatches = [
            'drawer-organizer:white' => '#F6F3EC',
            'drawer-organizer:gray' => '#E1E4E7',
            'lunch-box:blue' => '#436B73',
            'lunch-box:pink' => '#E7C2C7',
            'lunch-box:green' => '#B9B995',
        ];

        foreach ($swatches as $variantId => $hex) {
            DB::table('product_variants')->where('id', $variantId)->update(['swatch_hex' => $hex]);
        }
    }

    public function down(): void
    {
        Schema::table('product_variants', function (Blueprint $table): void {
            $table->dropColumn(['swatch_hex', 'is_visible']);
        });

        Schema::table('products', function (Blueprint $table): void {
            $table->dropColumn(['category_id', 'is_visible']);
        });

        Schema::dropIfExists('catalog_categories');
    }
};
