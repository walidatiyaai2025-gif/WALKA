<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUlids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

final class MediaGallery extends Model
{
    use HasUlids;

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'product_id',
        'product_variant_id',
        'revision',
        'created_by_fingerprint',
        'updated_by_fingerprint',
    ];

    protected function casts(): array
    {
        return [
            'revision' => 'integer',
        ];
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    public function variant(): BelongsTo
    {
        return $this->belongsTo(ProductVariant::class, 'product_variant_id');
    }

    public function items(): HasMany
    {
        return $this->hasMany(MediaGalleryItem::class)->orderBy('position');
    }
}
