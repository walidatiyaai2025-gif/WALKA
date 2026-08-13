<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUlids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

final class VariantMediaGalleryItem extends Model
{
    use HasUlids;

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'product_variant_id',
        'media_asset_id',
        'position',
        'created_by_fingerprint',
    ];

    protected function casts(): array
    {
        return ['position' => 'integer'];
    }

    public function variant(): BelongsTo
    {
        return $this->belongsTo(ProductVariant::class, 'product_variant_id');
    }

    public function mediaAsset(): BelongsTo
    {
        return $this->belongsTo(MediaAsset::class);
    }
}
