<?php

namespace App\Services;

use InvalidArgumentException;

final class ContentDeliveryMetadataService
{
    public const CACHE_CONTROL = 'public, max-age=60, stale-while-revalidate=300';

    /** @var array<string, string> */
    private const ETAG_FAMILIES = [
        'home.hero' => 'home-hero',
        'home.layout' => 'home-layout',
        'home.featured' => 'home-featured',
        'home.banner' => 'home-banner',
        'categories.presentation' => 'categories',
        'search.presentation' => 'search',
        'information' => 'information',
        'app.maintenance_notice' => 'maintenance-notice',
        'app.config' => 'app-config',
        'pdp.layout' => 'pdp-layout',
        'pdp.related_products' => 'related-products',
    ];

    /**
     * @return array{etag:string,cache_control:string}
     */
    public function forPublishedRevision(string $contentKey, int $revision): array
    {
        if ($revision < 1) {
            throw new InvalidArgumentException('Published content revision must be positive.');
        }

        $family = self::ETAG_FAMILIES[$contentKey] ?? null;
        if ($family === null) {
            throw new InvalidArgumentException("Unknown public content key: {$contentKey}");
        }

        return [
            'etag' => sprintf('"walka-%s-r%d"', $family, $revision),
            'cache_control' => self::CACHE_CONTROL,
        ];
    }

    /** @return list<string> */
    public function publicContentKeys(): array
    {
        return array_keys(self::ETAG_FAMILIES);
    }
}
