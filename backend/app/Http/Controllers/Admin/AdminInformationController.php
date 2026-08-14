<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\ContentRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use App\Services\Content\InformationContentDefinition;
use App\Services\ContentRevisionService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

final class AdminInformationController extends Controller
{
    public function __construct(private readonly ContentRevisionService $content) {}

    public function edit(Request $request, string $section): View
    {
        $this->assertSection($section);
        $entry = ContentEntry::query()
            ->where('content_key', InformationContentDefinition::KEY)
            ->first();

        if ($entry === null) {
            $entry = $this->content->saveDraft(
                contentKey: InformationContentDefinition::KEY,
                contentType: InformationContentDefinition::TYPE,
                payload: InformationContentDefinition::defaultPayload(),
                expectedRevision: 0,
                actorFingerprint: $this->actorFingerprint($request),
            );
        }

        abort_unless(
            $entry->content_type === InformationContentDefinition::TYPE,
            409,
            'The reserved information content key has an incompatible content type.',
        );

        $entry->load(['revisions' => fn ($query) => $query->orderByDesc('revision')]);
        $draft = InformationContentDefinition::editablePayload($entry->draft_payload);
        $published = $entry->published_payload === null
            ? null
            : InformationContentDefinition::editablePayload($entry->published_payload);

        return view('admin.content.information', [
            'entry' => $entry,
            'section' => $section,
            'draft' => $draft,
            'sectionDraft' => $draft[$section],
            'published' => $published,
        ]);
    }

    public function update(Request $request, string $section): RedirectResponse
    {
        $this->assertSection($section);
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
        ]);

        $entry = $this->entry();
        $current = InformationContentDefinition::editablePayload($entry->draft_payload);
        $sectionPayload = $this->sectionPayload($request, $section);
        $payload = InformationContentDefinition::withSection($current, $section, $sectionPayload);

        try {
            $this->content->saveDraft(
                contentKey: InformationContentDefinition::KEY,
                contentType: InformationContentDefinition::TYPE,
                payload: $payload,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.information.edit', ['section' => $section])
                ->withErrors([
                    'revision' => 'Information content changed in another session. Current values were reloaded; review before saving again.',
                ]);
        }

        return redirect()
            ->route('admin.content.information.edit', ['section' => $section])
            ->with('status', sprintf('%s draft saved. Nothing becomes public until Publish is used.', ucfirst($section)));
    }

    public function publish(Request $request, string $section): RedirectResponse
    {
        $this->assertSection($section);
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
        ]);

        $entry = $this->entry();
        InformationContentDefinition::validateAndNormalize($entry->draft_payload);

        try {
            $this->content->publish(
                contentKey: InformationContentDefinition::KEY,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.information.edit', ['section' => $section])
                ->withErrors([
                    'revision' => 'Publish blocked because information content changed in another session. Review the latest draft first.',
                ]);
        }

        return redirect()
            ->route('admin.content.information.edit', ['section' => $section])
            ->with('status', 'Information content published as one validated snapshot. Compatible clients can refresh it without a new app build.');
    }

    public function restore(Request $request, string $section): RedirectResponse
    {
        $this->assertSection($section);
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'source_revision' => ['required', 'integer', 'min:1'],
        ]);

        try {
            $this->content->restoreDraftFromRevision(
                contentKey: InformationContentDefinition::KEY,
                revisionToRestore: (int) $validated['source_revision'],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()
                ->route('admin.content.information.edit', ['section' => $section])
                ->withErrors([
                    'revision' => 'Restore blocked because information content changed in another session. Reload and review the latest revision.',
                ]);
        }

        return redirect()
            ->route('admin.content.information.edit', ['section' => $section])
            ->with('status', 'Historical Information snapshot restored into a new private draft. Review all four sections before publishing.');
    }

    /** @return array<string, mixed> */
    private function sectionPayload(Request $request, string $section): array
    {
        return match ($section) {
            InformationContentDefinition::ABOUT => $this->aboutPayload($request),
            InformationContentDefinition::FAQ => $this->faqPayload($request),
            InformationContentDefinition::SUPPORT => $this->supportPayload($request),
            InformationContentDefinition::LEGAL => $this->legalPayload($request),
            default => throw ValidationException::withMessages(['section' => ['Unknown information section.']]),
        };
    }

    /** @return array<string, mixed> */
    private function aboutPayload(Request $request): array
    {
        $validated = $request->validate([
            'hero_eyebrow' => ['required', 'string', 'max:80'],
            'hero_title' => ['required', 'string', 'max:180'],
            'hero_body' => ['required', 'string', 'max:500'],
            'story_eyebrow' => ['required', 'string', 'max:80'],
            'story_title' => ['required', 'string', 'max:180'],
            'story_body' => ['required', 'string', 'max:900'],
            'values_eyebrow' => ['required', 'string', 'max:80'],
            'values' => ['required', 'array'],
            'values.*.title' => ['required', 'string', 'max:100'],
            'values.*.body' => ['required', 'string', 'max:300'],
            'principles_eyebrow' => ['required', 'string', 'max:80'],
            'principles_title' => ['required', 'string', 'max:180'],
            'principles' => ['required', 'array'],
            'principles.*.title' => ['required', 'string', 'max:100'],
            'principles.*.body' => ['required', 'string', 'max:500'],
            'closing_eyebrow' => ['required', 'string', 'max:80'],
            'closing_title' => ['required', 'string', 'max:180'],
            'closing_body' => ['required', 'string', 'max:500'],
        ]);

        $values = [];
        foreach (['purposeful', 'refined', 'everyday'] as $id) {
            $row = $validated['values'][$id] ?? null;
            if (! is_array($row)) {
                throw ValidationException::withMessages(["values.$id" => ['Every released About value must be present.']]);
            }
            $values[] = ['id' => $id, 'title' => $row['title'], 'body' => $row['body']];
        }

        $principles = [];
        foreach (['useful-first', 'calm-by-design', 'made-for-repetition'] as $id) {
            $row = $validated['principles'][$id] ?? null;
            if (! is_array($row)) {
                throw ValidationException::withMessages(["principles.$id" => ['Every released About principle must be present.']]);
            }
            $principles[] = ['id' => $id, 'title' => $row['title'], 'body' => $row['body']];
        }

        return [
            'hero_eyebrow' => $validated['hero_eyebrow'],
            'hero_title' => $validated['hero_title'],
            'hero_body' => $validated['hero_body'],
            'story_eyebrow' => $validated['story_eyebrow'],
            'story_title' => $validated['story_title'],
            'story_body' => $validated['story_body'],
            'values_eyebrow' => $validated['values_eyebrow'],
            'values' => $values,
            'principles_eyebrow' => $validated['principles_eyebrow'],
            'principles_title' => $validated['principles_title'],
            'principles' => $principles,
            'closing_eyebrow' => $validated['closing_eyebrow'],
            'closing_title' => $validated['closing_title'],
            'closing_body' => $validated['closing_body'],
        ];
    }

    /** @return array<string, mixed> */
    private function faqPayload(Request $request): array
    {
        $validated = $request->validate([
            'eyebrow' => ['required', 'string', 'max:80'],
            'title' => ['required', 'string', 'max:180'],
            'intro' => ['required', 'string', 'max:600'],
            'items' => ['required', 'array', 'max:12'],
            'items.*.id' => ['nullable', 'string', 'max:64', 'regex:/^[a-z0-9][a-z0-9-]*$/'],
            'items.*.question' => ['nullable', 'string', 'max:220'],
            'items.*.answer' => ['nullable', 'string', 'max:1000'],
        ]);

        $items = $this->filledRows($validated['items'], 'FAQ');

        return [
            'eyebrow' => $validated['eyebrow'],
            'title' => $validated['title'],
            'intro' => $validated['intro'],
            'items' => array_map(
                static fn (array $row): array => [
                    'id' => $row['id'],
                    'question' => $row['question'],
                    'answer' => $row['answer'],
                ],
                $items,
            ),
        ];
    }

    /** @return array<string, mixed> */
    private function supportPayload(Request $request): array
    {
        return $request->validate([
            'eyebrow' => ['required', 'string', 'max:80'],
            'title' => ['required', 'string', 'max:180'],
            'intro' => ['required', 'string', 'max:700'],
            'amazon_order_title' => ['required', 'string', 'max:180'],
            'amazon_order_body' => ['required', 'string', 'max:700'],
            'support_email' => ['required', 'email:rfc', 'max:160'],
            'email_title' => ['required', 'string', 'max:180'],
            'email_body' => ['required', 'string', 'max:500'],
            'website_title' => ['required', 'string', 'max:180'],
            'website_body' => ['required', 'string', 'max:500'],
            'instagram_title' => ['required', 'string', 'max:180'],
            'instagram_body' => ['required', 'string', 'max:500'],
        ]);
    }

    /** @return array<string, mixed> */
    private function legalPayload(Request $request): array
    {
        $validated = $request->validate([
            'eyebrow' => ['required', 'string', 'max:80'],
            'privacy_title' => ['required', 'string', 'max:180'],
            'privacy_intro' => ['required', 'string', 'max:700'],
            'privacy_sections' => ['required', 'array', 'max:8'],
            'privacy_sections.*.id' => ['nullable', 'string', 'max:64', 'regex:/^[a-z0-9][a-z0-9-]*$/'],
            'privacy_sections.*.title' => ['nullable', 'string', 'max:180'],
            'privacy_sections.*.body' => ['nullable', 'string', 'max:1400'],
            'terms_title' => ['required', 'string', 'max:180'],
            'terms_intro' => ['required', 'string', 'max:700'],
            'terms_sections' => ['required', 'array', 'max:8'],
            'terms_sections.*.id' => ['nullable', 'string', 'max:64', 'regex:/^[a-z0-9][a-z0-9-]*$/'],
            'terms_sections.*.title' => ['nullable', 'string', 'max:180'],
            'terms_sections.*.body' => ['nullable', 'string', 'max:1400'],
            'review_notice_title' => ['required', 'string', 'max:220'],
            'review_notice_body' => ['required', 'string', 'max:900'],
        ]);

        return [
            'eyebrow' => $validated['eyebrow'],
            'privacy' => [
                'title' => $validated['privacy_title'],
                'intro' => $validated['privacy_intro'],
                'sections' => array_map(
                    static fn (array $row): array => ['id' => $row['id'], 'title' => $row['title'], 'body' => $row['body']],
                    $this->filledRows($validated['privacy_sections'], 'Privacy'),
                ),
            ],
            'terms' => [
                'title' => $validated['terms_title'],
                'intro' => $validated['terms_intro'],
                'sections' => array_map(
                    static fn (array $row): array => ['id' => $row['id'], 'title' => $row['title'], 'body' => $row['body']],
                    $this->filledRows($validated['terms_sections'], 'Terms'),
                ),
            ],
            'review_notice_title' => $validated['review_notice_title'],
            'review_notice_body' => $validated['review_notice_body'],
        ];
    }

    /**
     * @param  array<int|string, mixed>  $rows
     * @return list<array<string, string>>
     */
    private function filledRows(array $rows, string $label): array
    {
        $result = [];
        foreach ($rows as $index => $row) {
            if (! is_array($row)) {
                continue;
            }
            $values = array_map(static fn (mixed $value): string => trim((string) $value), $row);
            $hasAny = implode('', $values) !== '';
            if (! $hasAny) {
                continue;
            }
            foreach ($values as $key => $value) {
                if ($value === '') {
                    throw ValidationException::withMessages(["items.$index.$key" => ["$label rows must include every field when used."]]);
                }
            }
            $result[] = $values;
        }

        if ($result === []) {
            throw ValidationException::withMessages(['items' => ["$label must contain at least one row."]]);
        }

        return $result;
    }

    private function entry(): ContentEntry
    {
        $entry = ContentEntry::query()
            ->where('content_key', InformationContentDefinition::KEY)
            ->firstOrFail();

        if ($entry->content_type !== InformationContentDefinition::TYPE) {
            throw ValidationException::withMessages([
                'content_type' => ['The reserved information key has an incompatible content type.'],
            ]);
        }

        return $entry;
    }

    private function assertSection(string $section): void
    {
        abort_unless(in_array($section, InformationContentDefinition::sectionIds(), true), 404);
    }

    private function actorFingerprint(Request $request): string
    {
        $fingerprint = (string) $request->session()->get('walka_admin_dashboard_actor', '');

        return $fingerprint !== ''
            ? $fingerprint
            : hash('sha256', 'dashboard|'.$request->session()->getId());
    }
}
