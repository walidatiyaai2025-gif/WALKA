<?php

namespace App\Models;

use App\Enums\MediaAssetLifecycle;
use App\Enums\MediaAssetPurpose;
use App\Enums\MediaDerivativeKind;
use Illuminate\Database\Eloquent\Concerns\HasUlids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

final class MediaAsset extends Model
{
    use HasUlids;

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'purpose',
        'lifecycle',
        'source_reference',
        'source_storage_disk',
        'source_storage_path',
        'original_filename',
        'original_mime',
        'original_bytes',
        'original_width',
        'original_height',
        'original_sha256',
        'semantic_label',
        'created_by_fingerprint',
        'updated_by_fingerprint',
        'admitted_at',
        'archived_at',
    ];

    protected function casts(): array
    {
        return [
            'purpose' => MediaAssetPurpose::class,
            'lifecycle' => MediaAssetLifecycle::class,
            'original_bytes' => 'integer',
            'original_width' => 'integer',
            'original_height' => 'integer',
            'admitted_at' => 'immutable_datetime',
            'archived_at' => 'immutable_datetime',
        ];
    }

    public function derivatives(): HasMany
    {
        return $this->hasMany(MediaDerivative::class)->orderBy('kind');
    }

    public function canonicalDerivative(): HasOne
    {
        return $this->hasOne(MediaDerivative::class)
            ->where('kind', MediaDerivativeKind::Canonical->value);
    }

    public function isAdmitted(): bool
    {
        return $this->lifecycle === MediaAssetLifecycle::Admitted;
    }
}
