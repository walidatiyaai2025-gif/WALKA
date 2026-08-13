<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUlids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
use LogicException;

final class MediaReplacementEvent extends Model
{
    use HasUlids;

    public const UPDATED_AT = null;

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'operation',
        'source_media_asset_id',
        'replacement_media_asset_id',
        'rollback_of_event_id',
        'before_assignments',
        'after_assignments',
        'before_fingerprint',
        'after_fingerprint',
        'reason',
        'actor_fingerprint',
    ];

    protected static function booted(): void
    {
        self::updating(function (): never {
            throw new LogicException('Media replacement audit events are immutable.');
        });
        self::deleting(function (): never {
            throw new LogicException('Media replacement audit events cannot be deleted.');
        });
    }

    protected function casts(): array
    {
        return [
            'before_assignments' => 'array',
            'after_assignments' => 'array',
            'created_at' => 'immutable_datetime',
        ];
    }

    public function sourceAsset(): BelongsTo
    {
        return $this->belongsTo(MediaAsset::class, 'source_media_asset_id');
    }

    public function replacementAsset(): BelongsTo
    {
        return $this->belongsTo(MediaAsset::class, 'replacement_media_asset_id');
    }

    public function rollbackOf(): BelongsTo
    {
        return $this->belongsTo(self::class, 'rollback_of_event_id');
    }

    public function rollbackEvent(): HasOne
    {
        return $this->hasOne(self::class, 'rollback_of_event_id');
    }

    public function isReplacement(): bool
    {
        return $this->operation === 'replace';
    }

    public function isRollback(): bool
    {
        return $this->operation === 'rollback';
    }
}
