<?php

namespace App\Enums;

enum MediaAssetLifecycle: string
{
    case Draft = 'draft';
    case Admitted = 'admitted';
    case Archived = 'archived';
}
