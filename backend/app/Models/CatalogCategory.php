<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

final class CatalogCategory extends Model
{
    protected $table = 'catalog_categories';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'name',
        'is_visible',
        'sort_order',
        'revision',
    ];

    protected function casts(): array
    {
        return [
            'is_visible' => 'boolean',
            'sort_order' => 'integer',
            'revision' => 'integer',
        ];
    }

    public function products(): HasMany
    {
        return $this->hasMany(Product::class, 'category_id')->orderBy('sort_order');
    }
}
