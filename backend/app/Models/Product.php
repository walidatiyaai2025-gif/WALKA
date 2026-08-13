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
        'facts',
        'sort_order',
        'revision',
    ];

    protected function casts(): array
    {
        return [
            'features' => 'array',
            'facts' => 'array',
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
