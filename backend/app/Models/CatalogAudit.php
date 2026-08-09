<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

final class CatalogAudit extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'actor_fingerprint',
        'target_type',
        'target_id',
        'action',
        'from_revision',
        'to_revision',
        'changes',
        'created_at',
    ];

    protected function casts(): array
    {
        return [
            'from_revision' => 'integer',
            'to_revision' => 'integer',
            'changes' => 'array',
            'created_at' => 'immutable_datetime',
        ];
    }
}
