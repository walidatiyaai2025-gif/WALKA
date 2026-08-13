<?php

namespace App\Enums;

enum MediaDerivativeKind: string
{
    case Canonical = 'canonical';
    case Thumbnail = 'thumbnail';
    case Preview = 'preview';
}
