<?php

namespace Tests\Feature;

use App\Enums\MediaAssetLifecycle;
use App\Enums\MediaAssetPurpose;
use App\Models\MediaAsset;
use App\Services\MediaUploadService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

final class AdminMediaUploadControllerTest extends TestCase
{
    use RefreshDatabase;

    private array $session;

    protected function setUp(): void
    {
        parent::setUp();
        config()->set('walka.dashboard_username', 'admin');
        config()->set('walka.dashboard_password', 'Walka-Admin-Test-Password-2026');
        $this->session = [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_actor' => hash('sha256', 'cms-031-media-upload-test'),
        ];
    }

    public function test_media_workspace_and_upload_are_protected(): void
    {
        $this->get('/admin/media')->assertRedirect(route('admin.login'));
        $this->post('/admin/media/uploads')->assertRedirect(route('admin.login'));
    }

    public function test_valid_png_is_server_verified_quarantined_and_remains_draft(): void
    {
        Storage::fake(MediaUploadService::QUARANTINE_DISK);
        $bytes = $this->png(128, 96);

        $this->withSession($this->session)
            ->post(route('admin.media.store'), $this->payload(
                UploadedFile::fake()->createWithContent('drawer-white.png', $bytes),
            ))
            ->assertRedirect(route('admin.media.index'))
            ->assertSessionHas('status');

        $asset = MediaAsset::query()->firstOrFail();
        $this->assertSame(MediaAssetPurpose::Product, $asset->purpose);
        $this->assertSame(MediaAssetLifecycle::Draft, $asset->lifecycle);
        $this->assertSame('supplier-approved-white-v1', $asset->source_reference);
        $this->assertSame('Drawer Organizer White production source', $asset->semantic_label);
        $this->assertSame('drawer-white.png', $asset->original_filename);
        $this->assertSame('image/png', $asset->original_mime);
        $this->assertSame(strlen($bytes), $asset->original_bytes);
        $this->assertSame(128, $asset->original_width);
        $this->assertSame(96, $asset->original_height);
        $this->assertSame(hash('sha256', $bytes), $asset->original_sha256);
        $this->assertSame(MediaUploadService::QUARANTINE_DISK, $asset->source_storage_disk);
        $this->assertNotNull($asset->source_storage_path);
        $this->assertNull($asset->admitted_at);
        $this->assertFalse($asset->isAdmitted());
        $this->assertSame(0, $asset->derivatives()->count());
        Storage::disk(MediaUploadService::QUARANTINE_DISK)
            ->assertExists($asset->source_storage_path);
    }

    public function test_mime_spoofing_and_unsupported_formats_fail_closed(): void
    {
        Storage::fake(MediaUploadService::QUARANTINE_DISK);
        $png = $this->png(128, 96);

        $this->withSession($this->session)
            ->from(route('admin.media.index'))
            ->post(route('admin.media.store'), $this->payload(
                UploadedFile::fake()->createWithContent('spoofed.jpg', $png),
            ))
            ->assertRedirect(route('admin.media.index'))
            ->assertSessionHasErrors('file');

        $this->withSession($this->session)
            ->from(route('admin.media.index'))
            ->post(route('admin.media.store'), $this->payload(
                UploadedFile::fake()->createWithContent(
                    'unsafe.svg',
                    '<svg xmlns="http://www.w3.org/2000/svg"><script>alert(1)</script></svg>',
                ),
            ))
            ->assertRedirect(route('admin.media.index'))
            ->assertSessionHasErrors('file');

        $this->assertSame(0, MediaAsset::query()->count());
        $this->assertSame([], Storage::disk(MediaUploadService::QUARANTINE_DISK)->allFiles());
    }

    public function test_dimensions_animation_and_size_limits_are_enforced(): void
    {
        Storage::fake(MediaUploadService::QUARANTINE_DISK);

        $invalidFiles = [
            UploadedFile::fake()->createWithContent('too-small.png', $this->png(32, 32)),
            UploadedFile::fake()->createWithContent('too-wide.png', $this->png(9000, 64)),
            UploadedFile::fake()->createWithContent('animated.png', $this->png(128, 96, true)),
            UploadedFile::fake()->createWithContent(
                'too-large.png',
                $this->png(64, 64).str_repeat('x', MediaUploadService::MAX_BYTES),
            ),
        ];

        foreach ($invalidFiles as $file) {
            $this->withSession($this->session)
                ->from(route('admin.media.index'))
                ->post(route('admin.media.store'), $this->payload($file))
                ->assertRedirect(route('admin.media.index'))
                ->assertSessionHasErrors('file');
        }

        $this->assertSame(0, MediaAsset::query()->count());
        $this->assertSame([], Storage::disk(MediaUploadService::QUARANTINE_DISK)->allFiles());
    }

    public function test_duplicate_source_hash_is_rejected_without_duplicate_file(): void
    {
        Storage::fake(MediaUploadService::QUARANTINE_DISK);
        $bytes = $this->png(128, 96);

        $this->withSession($this->session)
            ->post(route('admin.media.store'), $this->payload(
                UploadedFile::fake()->createWithContent('first.png', $bytes),
            ))
            ->assertRedirect(route('admin.media.index'));

        $this->withSession($this->session)
            ->from(route('admin.media.index'))
            ->post(route('admin.media.store'), $this->payload(
                UploadedFile::fake()->createWithContent('same-bytes.png', $bytes),
            ))
            ->assertRedirect(route('admin.media.index'))
            ->assertSessionHasErrors('file');

        $this->assertSame(1, MediaAsset::query()->count());
        $this->assertCount(
            1,
            Storage::disk(MediaUploadService::QUARANTINE_DISK)->allFiles(),
        );
    }

    public function test_quarantine_storage_failure_rolls_back_database_registration(): void
    {
        config()->set('filesystems.disks.media_quarantine', [
            'driver' => 'unsupported-cms-031-test-driver',
        ]);
        Storage::forgetDisk(MediaUploadService::QUARANTINE_DISK);

        $this->withSession($this->session)
            ->from(route('admin.media.index'))
            ->post(route('admin.media.store'), $this->payload(
                UploadedFile::fake()->createWithContent('rollback.png', $this->png(128, 96)),
            ))
            ->assertRedirect(route('admin.media.index'))
            ->assertSessionHasErrors('file');

        $this->assertSame(0, MediaAsset::query()->count());
    }

    /**
     * @return array<string, mixed>
     */
    private function payload(UploadedFile $file): array
    {
        return [
            'purpose' => MediaAssetPurpose::Product->value,
            'source_reference' => 'supplier-approved-white-v1',
            'semantic_label' => 'Drawer Organizer White production source',
            'file' => $file,
        ];
    }

    private function png(int $width, int $height, bool $animated = false): string
    {
        $signature = "\x89PNG\r\n\x1a\n";
        $ihdr = pack('NNCCCCC', $width, $height, 8, 6, 0, 0, 0);
        $row = "\x00".str_repeat("\x80\x80\x80\xFF", $width);
        $raw = str_repeat($row, $height);

        $chunks = $this->pngChunk('IHDR', $ihdr);
        if ($animated) {
            $chunks .= $this->pngChunk('acTL', pack('NN', 2, 0));
        }
        $chunks .= $this->pngChunk('IDAT', gzcompress($raw, 9));
        $chunks .= $this->pngChunk('IEND', '');

        return $signature.$chunks;
    }

    private function pngChunk(string $type, string $data): string
    {
        return pack('N', strlen($data))
            .$type
            .$data
            .pack('N', crc32($type.$data));
    }
}
