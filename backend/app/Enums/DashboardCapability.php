<?php

namespace App\Enums;

enum DashboardCapability: string
{
    case DashboardView = 'dashboard.view';
    case CatalogView = 'catalog.view';
    case CatalogWrite = 'catalog.write';
    case ContentView = 'content.view';
    case ContentWrite = 'content.write';
    case ContentPublish = 'content.publish';
    case ContentRestore = 'content.restore';
    case MediaView = 'media.view';
    case MediaUpload = 'media.upload';
    case MediaAssign = 'media.assign';
    case MediaReplace = 'media.replace';
    case AuditsView = 'audits.view';
    case AppConfigView = 'app_config.view';
    case AppConfigManage = 'app_config.manage';
}
