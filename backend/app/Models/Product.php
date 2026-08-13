<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

final class Product extends Model
{
    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'name',
        'category',
        'features',
        'short_description',
        'highlights',
        'facts',
        'is_visible',
        'is_featured',
        'presentation_order',
        'sort_order',
        'revision',
    ];

    protected function casts(): array
    {
        return [
            'features' => 'array',
            'highlights' => 'array',
            'facts' => 'array',
            'is_visible' => 'boolean',
            'is_featured' => 'boolean',
            'presentation_order' => 'integer',
            'sort_order' => 'integer',
            'revision' => 'integer',
        ];
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
