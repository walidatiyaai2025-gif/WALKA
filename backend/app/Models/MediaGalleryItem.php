<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUlids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

final class MediaGalleryItem extends Model
{
    use HasUlids;

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'media_gallery_id',
        'media_asset_id',
        'position',
        'created_by_fingerprint',
    ];

    protected function casts(): array
    {
        return [
            'position' => 'integer',
        ];
    }

    public function gallery(): BelongsTo
    {
        return $this->belongsTo(MediaGallery::class, 'media_gallery_id');
    }

    public function asset(): BelongsTo
    {
        return $this->belongsTo(MediaAsset::class, 'media_asset_id');
    }
}
