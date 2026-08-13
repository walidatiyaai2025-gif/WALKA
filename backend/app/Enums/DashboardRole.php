<?php

namespace App\Enums;

enum DashboardRole: string
{
    case Owner = 'owner';
    case ContentEditor = 'content_editor';
    case MediaEditor = 'media_editor';
    case Viewer = 'viewer';
}
