<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

final class ContentEntry extends Model
{
    protected $fillable = [
        'content_key',
        'content_type',
        'revision',
        'published_revision',
        'draft_payload',
        'published_payload',
        'published_at',
        'scheduled_publish_at',
        'scheduled_unpublish_at',
        'schedule_revision',
    ];

    protected function casts(): array
    {
        return [
            'revision' => 'integer',
            'published_revision' => 'integer',
            'draft_payload' => 'array',
            'published_payload' => 'array',
            'published_at' => 'immutable_datetime',
            'scheduled_publish_at' => 'immutable_datetime',
            'scheduled_unpublish_at' => 'immutable_datetime',
            'schedule_revision' => 'integer',
        ];
    }

    public function revisions(): HasMany
    {
        return $this->hasMany(ContentRevision::class)->orderBy('revision');
    }
}
