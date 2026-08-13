<?php

namespace App\Models;

use App\Enums\MediaDerivativeKind;
use Illuminate\Database\Eloquent\Concerns\HasUlids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

final class MediaDerivative extends Model
{
    use HasUlids;

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'media_asset_id',
        'kind',
        'storage_disk',
        'storage_path',
        'mime',
        'bytes',
        'width',
        'height',
        'sha256',
        'created_by_fingerprint',
    ];

    protected function casts(): array
    {
        return [
            'kind' => MediaDerivativeKind::class,
            'bytes' => 'integer',
            'width' => 'integer',
            'height' => 'integer',
        ];
    }

    public function asset(): BelongsTo
    {
        return $this->belongsTo(MediaAsset::class, 'media_asset_id');
    }
}
