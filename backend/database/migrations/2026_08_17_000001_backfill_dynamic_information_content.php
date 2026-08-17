<?php

use App\Services\Content\StorefrontCopyContentDefinition;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $row = DB::table('content_entries')
            ->where('content_key', StorefrontCopyContentDefinition::KEY)
            ->first();

        if ($row === null) {
            return;
        }

        $default = StorefrontCopyContentDefinition::defaultPayload()['information_json'];
        $draft = $this->decode((string) $row->draft_payload);
        $published = $row->published_payload === null
            ? null
            : $this->decode((string) $row->published_payload);

        $changed = false;
        $draftHasInformation = isset($draft['information_json']) && is_string($draft['information_json']);

        if (! $draftHasInformation) {
            $draft['information_json'] = $default;
            $changed = true;
        }

        if ($published !== null) {
            $publishedHasInformation = isset($published['information_json']) && is_string($published['information_json']);

            if (! $publishedHasInformation) {
                $published['information_json'] = $default;
                $changed = true;
            }
        }

        if (! $changed) {
            return;
        }

        DB::table('content_entries')
            ->where('id', $row->id)
            ->update([
                'draft_payload' => json_encode($draft, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR),
                'published_payload' => $published === null
                    ? null
                    : json_encode($published, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR),
                'updated_at' => now(),
            ]);
    }

    public function down(): void
    {
        // Preserve owner-authored information on rollback.
    }

    /**
     * @return array<string, mixed>
     */
    private function decode(string $json): array
    {
        $value = json_decode($json, true, 64, JSON_THROW_ON_ERROR);

        return is_array($value) ? $value : [];
    }
};
