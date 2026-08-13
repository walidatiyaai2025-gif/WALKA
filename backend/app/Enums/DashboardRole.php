<?php

namespace App\Enums;

enum DashboardRole: string
{
    case Owner = 'owner';
    case ContentEditor = 'content_editor';
    case MediaEditor = 'media_editor';
    case Viewer = 'viewer';

    /** @return list<DashboardCapability> */
    public function capabilities(): array
    {
        return match ($this) {
            self::Owner => DashboardCapability::cases(),
            self::ContentEditor => [
                DashboardCapability::DashboardView,
                DashboardCapability::CatalogView,
                DashboardCapability::ContentView,
                DashboardCapability::ContentWrite,
                DashboardCapability::ContentPublish,
                DashboardCapability::ContentRestore,
                DashboardCapability::MediaView,
                DashboardCapability::AuditsView,
            ],
            self::MediaEditor => [
                DashboardCapability::DashboardView,
                DashboardCapability::CatalogView,
                DashboardCapability::MediaView,
                DashboardCapability::MediaUpload,
                DashboardCapability::MediaAssign,
                DashboardCapability::MediaReplace,
                DashboardCapability::AuditsView,
            ],
            self::Viewer => [
                DashboardCapability::DashboardView,
                DashboardCapability::CatalogView,
                DashboardCapability::ContentView,
                DashboardCapability::MediaView,
                DashboardCapability::AuditsView,
            ],
        };
    }

    public function allows(DashboardCapability $capability): bool
    {
        return in_array($capability, $this->capabilities(), true);
    }
}
