<?php

namespace App\Services;

use App\Models\ContentEntry;
use App\Models\ContentRevision;
use App\Models\MediaAsset;
use App\Models\MediaReplacementEvent;
use App\Models\Product;
use App\Models\ProductMediaGalleryItem;
use App\Models\ProductVariant;
use App\Models\SurfaceMediaItem;
use App\Models\VariantMediaGalleryItem;
use Carbon\CarbonImmutable;
use Illuminate\Validation\ValidationException;
use JsonException;

final class CmsMetadataBackupService
{
    public const SCHEMA_VERSION = 1;

    /**
     * @return array<string, mixed>
     */
    public function export(?CarbonImmutable $generatedAt = null): array
    {
        $generatedAt = ($generatedAt ?? CarbonImmutable::now('UTC'))->utc();
        $sections = [
            'products' => $this->products(),
            'variants' => $this->variants(),
            'content_entries' => $this->contentEntries(),
            'content_revisions' => $this->contentRevisions(),
            'media_assets' => $this->mediaAssets(),
            'product_media_assignments' => $this->productMediaAssignments(),
            'variant_media_assignments' => $this->variantMediaAssignments(),
            'surface_media_assignments' => $this->surfaceMediaAssignments(),
            'media_replacement_events' => $this->mediaReplacementEvents(),
        ];

        $unsigned = [
            'schema_version' => self::SCHEMA_VERSION,
            'generated_at' => $generatedAt->toIso8601ZuluString(),
            'record_counts' => array_map('count', $sections),
            'sections' => $sections,
        ];

        return array_merge($unsigned, [
            'sha256' => $this->digest($unsigned),
        ]);
    }

    /**
     * Validate a candidate restore package without mutating any row.
     *
     * @param  array<string, mixed>  $package
     * @return array{valid:true,schema_version:int,sha256:string,record_counts:array<string,int>}
     */
    public function validatePackage(array $package): array
    {
        $allowed = ['schema_version', 'generated_at', 'record_counts', 'sections', 'sha256'];
        $unknown = array_diff(array_keys($package), $allowed);
        if ($unknown !== []) {
            $this->invalid('package', 'Unknown backup fields: '.implode(', ', $unknown));
        }

        if (($package['schema_version'] ?? null) !== self::SCHEMA_VERSION) {
            $this->invalid('schema_version', 'Unsupported WALKA metadata backup schema.');
        }

        $generatedAt = $package['generated_at'] ?? null;
        if (! is_string($generatedAt) || CarbonImmutable::hasFormat($generatedAt, 'Y-m-d\TH:i:s\Z') === false) {
            $this->invalid('generated_at', 'Backup generated_at must be UTC ISO-8601 Zulu time.');
        }

        $sections = $package['sections'] ?? null;
        if (! is_array($sections)) {
            $this->invalid('sections', 'Backup sections must be an object.');
        }

        $expectedSections = [
            'products',
            'variants',
            'content_entries',
            'content_revisions',
            'media_assets',
            'product_media_assignments',
            'variant_media_assignments',
            'surface_media_assignments',
            'media_replacement_events',
        ];
        $sectionKeys = array_keys($sections);
        sort($sectionKeys);
        $sortedExpected = $expectedSections;
        sort($sortedExpected);
        if ($sectionKeys !== $sortedExpected) {
            $this->invalid('sections', 'Backup section set is incomplete or contains unknown sections.');
        }

        foreach ($expectedSections as $section) {
            if (! is_array($sections[$section]) || ! array_is_list($sections[$section])) {
                $this->invalid("sections.{$section}", 'Backup section must be a list.');
            }
        }

        $recordCounts = $package['record_counts'] ?? null;
        if (! is_array($recordCounts)) {
            $this->invalid('record_counts', 'Backup record_counts must be an object.');
        }
        foreach ($expectedSections as $section) {
            if (($recordCounts[$section] ?? null) !== count($sections[$section])) {
                $this->invalid("record_counts.{$section}", 'Record count does not match the section payload.');
            }
        }

        $suppliedDigest = $package['sha256'] ?? null;
        if (! is_string($suppliedDigest) || preg_match('/^[a-f0-9]{64}$/', $suppliedDigest) !== 1) {
            $this->invalid('sha256', 'Backup SHA-256 is missing or malformed.');
        }
        $unsigned = $package;
        unset($unsigned['sha256']);
        $computedDigest = $this->digest($unsigned);
        if (! hash_equals($computedDigest, $suppliedDigest)) {
            $this->invalid('sha256', 'Backup integrity digest does not match the package.');
        }

        $this->validateCatalogIdentities($sections['products'], $sections['variants']);
        $this->validateContentRevisions($sections['content_entries'], $sections['content_revisions']);
        $this->validateMediaReferences($sections);

        return [
            'valid' => true,
            'schema_version' => self::SCHEMA_VERSION,
            'sha256' => $computedDigest,
            'record_counts' => $recordCounts,
        ];
    }

    /** @return list<array<string, mixed>> */
    private function products(): array
    {
        return Product::query()->orderBy('id')->get()->map(function (Product $product): array {
            return [
                'id' => $product->id,
                'revision' => (int) $product->revision,
                'name' => $product->name,
                'short_description' => $product->short_description,
                'features' => $product->features ?? [],
                'highlights' => $product->highlights ?? [],
                'is_visible' => (bool) $product->is_visible,
                'is_featured' => (bool) $product->is_featured,
                'presentation_order' => (int) $product->presentation_order,
                'protected_identity_sha256' => $this->hashValue([
                    'id' => $product->id,
                    'category' => $product->category,
                    'facts' => $product->facts ?? [],
                    'sort_order' => (int) $product->sort_order,
                ]),
            ];
        })->all();
    }

    /** @return list<array<string, mixed>> */
    private function variants(): array
    {
        return ProductVariant::query()->orderBy('id')->get()->map(function (ProductVariant $variant): array {
            return [
                'id' => $variant->id,
                'product_id' => $variant->product_id,
                'revision' => (int) $variant->revision,
                'color' => $variant->color,
                'protected_identity_sha256' => $this->hashValue([
                    'id' => $variant->id,
                    'product_id' => $variant->product_id,
                    'pantone' => $variant->pantone,
                    'asin' => $variant->asin,
                    'sort_order' => (int) $variant->sort_order,
                ]),
            ];
        })->all();
    }

    /** @return list<array<string, mixed>> */
    private function contentEntries(): array
    {
        return ContentEntry::query()->orderBy('content_key')->get()->map(fn (ContentEntry $entry): array => [
            'content_key' => $entry->content_key,
            'content_type' => $entry->content_type,
            'revision' => (int) $entry->revision,
            'published_revision' => $entry->published_revision,
            'draft_payload' => $entry->draft_payload,
            'published_payload' => $entry->published_payload,
            'published_at' => $entry->published_at?->utc()->toIso8601ZuluString(),
            'scheduled_publish_at' => $entry->scheduled_publish_at?->utc()->toIso8601ZuluString(),
            'scheduled_unpublish_at' => $entry->scheduled_unpublish_at?->utc()->toIso8601ZuluString(),
            'schedule_revision' => $entry->schedule_revision,
        ])->all();
    }

    /** @return list<array<string, mixed>> */
    private function contentRevisions(): array
    {
        return ContentRevision::query()
            ->with('entry:id,content_key')
            ->orderBy('content_entry_id')
            ->orderBy('revision')
            ->get()
            ->map(fn (ContentRevision $revision): array => [
                'content_key' => $revision->entry->content_key,
                'revision' => (int) $revision->revision,
                'action' => $revision->action,
                'payload' => $revision->payload,
                'source_revision' => $revision->source_revision,
                'reason' => $revision->reason,
                'actor_fingerprint' => $revision->actor_fingerprint,
                'created_at' => $revision->created_at?->utc()->toIso8601ZuluString(),
            ])->all();
    }

    /** @return list<array<string, mixed>> */
    private function mediaAssets(): array
    {
        return MediaAsset::query()->orderBy('id')->get()->map(fn (MediaAsset $asset): array => [
            'id' => $asset->id,
            'purpose' => $asset->purpose->value,
            'lifecycle' => $asset->lifecycle->value,
            'original_mime' => $asset->original_mime,
            'original_bytes' => (int) $asset->original_bytes,
            'original_width' => (int) $asset->original_width,
            'original_height' => (int) $asset->original_height,
            'original_sha256' => $asset->original_sha256,
            'semantic_label' => $asset->semantic_label,
            'admitted_at' => $asset->admitted_at?->utc()->toIso8601ZuluString(),
            'archived_at' => $asset->archived_at?->utc()->toIso8601ZuluString(),
        ])->all();
    }

    /** @return list<array<string, mixed>> */
    private function productMediaAssignments(): array
    {
        return ProductMediaGalleryItem::query()->orderBy('product_id')->orderBy('position')->get()->map(fn (ProductMediaGalleryItem $item): array => [
            'id' => $item->id,
            'product_id' => $item->product_id,
            'media_asset_id' => $item->media_asset_id,
            'position' => (int) $item->position,
        ])->all();
    }

    /** @return list<array<string, mixed>> */
    private function variantMediaAssignments(): array
    {
        return VariantMediaGalleryItem::query()->orderBy('product_variant_id')->orderBy('position')->get()->map(fn (VariantMediaGalleryItem $item): array => [
            'id' => $item->id,
            'product_variant_id' => $item->product_variant_id,
            'media_asset_id' => $item->media_asset_id,
            'position' => (int) $item->position,
        ])->all();
    }

    /** @return list<array<string, mixed>> */
    private function surfaceMediaAssignments(): array
    {
        return SurfaceMediaItem::query()->orderBy('slot_key')->orderBy('position')->get()->map(fn (SurfaceMediaItem $item): array => [
            'id' => $item->id,
            'slot_key' => $item->slot_key,
            'media_asset_id' => $item->media_asset_id,
            'position' => (int) $item->position,
        ])->all();
    }

    /** @return list<array<string, mixed>> */
    private function mediaReplacementEvents(): array
    {
        return MediaReplacementEvent::query()->orderBy('created_at')->orderBy('id')->get()->map(fn (MediaReplacementEvent $event): array => [
            'id' => $event->id,
            'operation' => $event->operation,
            'source_media_asset_id' => $event->source_media_asset_id,
            'replacement_media_asset_id' => $event->replacement_media_asset_id,
            'rollback_of_event_id' => $event->rollback_of_event_id,
            'before_assignments' => $event->before_assignments,
            'after_assignments' => $event->after_assignments,
            'before_fingerprint' => $event->before_fingerprint,
            'after_fingerprint' => $event->after_fingerprint,
            'reason' => $event->reason,
            'actor_fingerprint' => $event->actor_fingerprint,
            'created_at' => $event->created_at?->utc()->toIso8601ZuluString(),
        ])->all();
    }

    /** @param list<array<string, mixed>> $products @param list<array<string, mixed>> $variants */
    private function validateCatalogIdentities(array $products, array $variants): void
    {
        $currentProducts = Product::query()->get()->keyBy('id');
        foreach ($products as $row) {
            $id = $row['id'] ?? null;
            if (! is_string($id) || ! $currentProducts->has($id)) {
                $this->invalid('sections.products', 'Backup references an unknown stable Product ID.');
            }
            $product = $currentProducts->get($id);
            $expected = $this->hashValue([
                'id' => $product->id,
                'category' => $product->category,
                'facts' => $product->facts ?? [],
                'sort_order' => (int) $product->sort_order,
            ]);
            if (! hash_equals($expected, (string) ($row['protected_identity_sha256'] ?? ''))) {
                $this->invalid('sections.products', "Protected Product identity mismatch for {$id}.");
            }
            if (! is_int($row['revision'] ?? null) || $row['revision'] < 1) {
                $this->invalid('sections.products', "Invalid Product revision for {$id}.");
            }
        }

        $currentVariants = ProductVariant::query()->get()->keyBy('id');
        foreach ($variants as $row) {
            $id = $row['id'] ?? null;
            if (! is_string($id) || ! $currentVariants->has($id)) {
                $this->invalid('sections.variants', 'Backup references an unknown stable Variant ID.');
            }
            $variant = $currentVariants->get($id);
            if (($row['product_id'] ?? null) !== $variant->product_id) {
                $this->invalid('sections.variants', "Variant Product mapping mismatch for {$id}.");
            }
            $expected = $this->hashValue([
                'id' => $variant->id,
                'product_id' => $variant->product_id,
                'pantone' => $variant->pantone,
                'asin' => $variant->asin,
                'sort_order' => (int) $variant->sort_order,
            ]);
            if (! hash_equals($expected, (string) ($row['protected_identity_sha256'] ?? ''))) {
                $this->invalid('sections.variants', "Protected Variant identity mismatch for {$id}.");
            }
        }
    }

    /** @param list<array<string, mixed>> $entries @param list<array<string, mixed>> $revisions */
    private function validateContentRevisions(array $entries, array $revisions): void
    {
        $byKey = [];
        foreach ($entries as $entry) {
            $key = $entry['content_key'] ?? null;
            if (! is_string($key) || $key === '') {
                $this->invalid('sections.content_entries', 'Content entry key is missing.');
            }
            if (isset($byKey[$key])) {
                $this->invalid('sections.content_entries', "Duplicate content entry {$key}.");
            }
            if (! is_int($entry['revision'] ?? null) || $entry['revision'] < 1) {
                $this->invalid('sections.content_entries', "Invalid current revision for {$key}.");
            }
            $byKey[$key] = $entry;
        }

        $last = [];
        foreach ($revisions as $revision) {
            $key = $revision['content_key'] ?? null;
            $number = $revision['revision'] ?? null;
            if (! is_string($key) || ! isset($byKey[$key]) || ! is_int($number) || $number < 1) {
                $this->invalid('sections.content_revisions', 'Content revision references an invalid key or revision.');
            }
            $expected = ($last[$key] ?? 0) + 1;
            if ($number !== $expected) {
                $this->invalid('sections.content_revisions', "Revision sequence is not monotonic for {$key}.");
            }
            $source = $revision['source_revision'] ?? null;
            if ($source !== null && (! is_int($source) || $source < 1 || $source >= $number)) {
                $this->invalid('sections.content_revisions', "Invalid source revision for {$key} revision {$number}.");
            }
            $last[$key] = $number;
        }

        foreach ($byKey as $key => $entry) {
            if (($last[$key] ?? 0) !== $entry['revision']) {
                $this->invalid('sections.content_entries', "Current revision does not match immutable history for {$key}.");
            }
            $published = $entry['published_revision'] ?? null;
            if ($published !== null && (! is_int($published) || $published < 1 || $published > $entry['revision'])) {
                $this->invalid('sections.content_entries', "Invalid published revision for {$key}.");
            }
        }
    }

    /** @param array<string, mixed> $sections */
    private function validateMediaReferences(array $sections): void
    {
        $assets = [];
        foreach ($sections['media_assets'] as $asset) {
            $id = $asset['id'] ?? null;
            if (! is_string($id) || $id === '') {
                $this->invalid('sections.media_assets', 'Media asset stable ID is missing.');
            }
            $assets[$id] = true;
        }
        $products = array_fill_keys(array_column($sections['products'], 'id'), true);
        $variants = array_fill_keys(array_column($sections['variants'], 'id'), true);

        foreach ($sections['product_media_assignments'] as $row) {
            if (! isset($products[$row['product_id'] ?? '']) || ! isset($assets[$row['media_asset_id'] ?? ''])) {
                $this->invalid('sections.product_media_assignments', 'Product media assignment contains a dangling reference.');
            }
        }
        foreach ($sections['variant_media_assignments'] as $row) {
            if (! isset($variants[$row['product_variant_id'] ?? '']) || ! isset($assets[$row['media_asset_id'] ?? ''])) {
                $this->invalid('sections.variant_media_assignments', 'Variant media assignment contains a dangling reference.');
            }
        }
        foreach ($sections['surface_media_assignments'] as $row) {
            if (! isset($assets[$row['media_asset_id'] ?? ''])) {
                $this->invalid('sections.surface_media_assignments', 'Surface media assignment contains a dangling reference.');
            }
        }
        $events = array_fill_keys(array_column($sections['media_replacement_events'], 'id'), true);
        foreach ($sections['media_replacement_events'] as $row) {
            foreach (['source_media_asset_id', 'replacement_media_asset_id'] as $field) {
                $assetId = $row[$field] ?? null;
                if ($assetId !== null && ! isset($assets[$assetId])) {
                    $this->invalid('sections.media_replacement_events', 'Media replacement event contains a dangling asset reference.');
                }
            }
            $rollback = $row['rollback_of_event_id'] ?? null;
            if ($rollback !== null && ! isset($events[$rollback])) {
                $this->invalid('sections.media_replacement_events', 'Media rollback references an unknown audit event.');
            }
        }
    }

    /** @param array<string, mixed> $value */
    private function digest(array $value): string
    {
        try {
            return hash('sha256', json_encode($this->canonicalize($value), JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
        } catch (JsonException) {
            $this->invalid('package', 'Backup package cannot be encoded as canonical JSON.');
        }
    }

    private function hashValue(array $value): string
    {
        return $this->digest($value);
    }

    private function canonicalize(mixed $value): mixed
    {
        if (! is_array($value)) {
            return $value;
        }
        if (array_is_list($value)) {
            return array_map(fn (mixed $item): mixed => $this->canonicalize($item), $value);
        }
        ksort($value);
        foreach ($value as $key => $item) {
            $value[$key] = $this->canonicalize($item);
        }

        return $value;
    }

    private function invalid(string $field, string $message): never
    {
        throw ValidationException::withMessages([$field => [$message]]);
    }
}
