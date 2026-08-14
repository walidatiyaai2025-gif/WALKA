<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

final class ContentRevision extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'content_entry_id',
        'revision',
        'action',
        'payload',
        'source_revision',
        'reason',
        'actor_fingerprint',
        'created_at',
    ];

    protected function casts(): array
    {
        return [
            'revision' => 'integer',
            'payload' => 'array',
            'source_revision' => 'integer',
            'created_at' => 'immutable_datetime',
        ];
    }

    public function entry(): BelongsTo
    {
        return $this->belongsTo(ContentEntry::class, 'content_entry_id');
    }
}
