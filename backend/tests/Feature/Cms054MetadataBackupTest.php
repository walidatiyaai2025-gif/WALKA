<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use App\Models\ContentRevision;
use App\Models\ProductVariant;
use App\Services\CmsMetadataBackupService;
use App\Services\ContentRevisionService;
use Carbon\CarbonImmutable;
use Database\Seeders\WalkaCatalogSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class Cms054MetadataBackupTest extends TestCase
{
    use RefreshDatabase;

    public function test_export_is_canonical_and_validates_without_mutating_metadata(): void
    {
        $this->seed(WalkaCatalogSeeder::class);
        $actor = hash('sha256', 'cms-054-test');
        $content = app(ContentRevisionService::class);
        $content->saveDraft('home.hero', 'home.hero', ['title' => 'Backup me'], 0, $actor);
        $content->publish('home.hero', 1, $actor);

        $service = app(CmsMetadataBackupService::class);
        $time = CarbonImmutable::parse('2026-08-14T09:30:00Z');
        $first = $service->export($time);
        $second = $service->export($time);

        $this->assertSame($first, $second);
        $this->assertSame(1, $first['schema_version']);
        $this->assertMatchesRegularExpression('/^[a-f0-9]{64}$/', $first['sha256']);
        $this->assertArrayNotHasKey('source_storage_path', $first['sections']['media_assets'][0] ?? []);
        $this->assertArrayNotHasKey('asin', $first['sections']['variants'][0]);
        $this->assertArrayNotHasKey('pantone', $first['sections']['variants'][0]);

        $beforeEntries = ContentEntry::query()->get()->toArray();
        $beforeRevisions = ContentRevision::query()->get()->toArray();
        $validated = $service->validatePackage($first);

        $this->assertTrue($validated['valid']);
        $this->assertSame($first['sha256'], $validated['sha256']);
        $this->assertSame($beforeEntries, ContentEntry::query()->get()->toArray());
        $this->assertSame($beforeRevisions, ContentRevision::query()->get()->toArray());
    }

    public function test_tampering_and_protected_product_master_drift_fail_closed(): void
    {
        $this->seed(WalkaCatalogSeeder::class);
        $service = app(CmsMetadataBackupService::class);
        $package = $service->export(CarbonImmutable::parse('2026-08-14T09:30:00Z'));

        $tampered = $package;
        $tampered['sections']['products'][0]['name'] = 'Tampered without re-signing';
        try {
            $service->validatePackage($tampered);
            $this->fail('Expected integrity validation to reject a tampered backup.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey('sha256', $exception->errors());
        }

        $variant = ProductVariant::query()->firstOrFail();
        ProductVariant::query()->whereKey($variant->id)->update(['asin' => 'B0PROTECTEDDRIFT']);

        try {
            $service->validatePackage($package);
            $this->fail('Expected protected Product Master drift to reject restore validation.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey('sections.variants', $exception->errors());
        }
    }
}
