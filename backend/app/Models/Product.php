<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

final class Product extends Model
{
    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'name',
        'short_description',
        'category',
        'category_id',
        'features',
        'facts',
        'sort_order',
        'is_visible',
        'revision',
    ];

    protected function casts(): array
    {
        return [
            'features' => 'array',
            'facts' => 'array',
            'sort_order' => 'integer',
            'is_visible' => 'boolean',
            'revision' => 'integer',
        ];
    }

    public function categoryEntity(): BelongsTo
    {
        return $this->belongsTo(CatalogCategory::class, 'category_id');
    }

    public function variants(): HasMany
    {
        return $this->hasMany(ProductVariant::class)->orderBy('sort_order');
    }

    public function mediaGalleryItems(): HasMany
    {
        return $this->hasMany(ProductMediaGalleryItem::class)->orderBy('position');
    }
}
