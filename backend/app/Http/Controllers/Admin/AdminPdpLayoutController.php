<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\ContentRevisionConflictException;
use App\Http\Controllers\Controller;
use App\Models\ContentEntry;
use App\Services\Content\PdpLayoutContentDefinition;
use App\Services\ContentRevisionService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

final class AdminPdpLayoutController extends Controller
{
    public function __construct(private readonly ContentRevisionService $content) {}

    public function edit(Request $request): View
    {
        $entry = ContentEntry::query()->where('content_key', PdpLayoutContentDefinition::KEY)->first();
        if ($entry === null) {
            $entry = $this->content->saveDraft(
                contentKey: PdpLayoutContentDefinition::KEY,
                contentType: PdpLayoutContentDefinition::TYPE,
                payload: PdpLayoutContentDefinition::defaultPayload(),
                expectedRevision: 0,
                actorFingerprint: $this->actorFingerprint($request),
            );
        }

        abort_unless($entry->content_type === PdpLayoutContentDefinition::TYPE, 409, 'The reserved pdp.layout content key has an incompatible content type.');
        $entry->load(['revisions' => fn ($query) => $query->orderByDesc('revision')]);

        return view('admin.content.pdp-layout', [
            'entry' => $entry,
            'draft' => PdpLayoutContentDefinition::editablePayload($entry->draft_payload),
            'published' => $entry->published_payload === null ? null : PdpLayoutContentDefinition::editablePayload($entry->published_payload),
            'requiredVisible' => PdpLayoutContentDefinition::requiredVisibleSectionIds(),
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'order' => ['required', 'array'],
            'order.*' => ['required', 'integer', 'min:1', 'max:8'],
            'visible' => ['sometimes', 'array'],
        ]);

        try {
            $this->content->saveDraft(
                contentKey: PdpLayoutContentDefinition::KEY,
                contentType: PdpLayoutContentDefinition::TYPE,
                payload: $this->payloadFromRequest($request, $validated),
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()->route('admin.content.pdp.layout.edit')->withErrors([
                'revision' => 'PDP layout changed in another session. Review the latest draft before saving.',
            ]);
        }

        return redirect()->route('admin.content.pdp.layout.edit')->with('status', 'PDP layout draft saved. Live Product Detail pages remain unchanged until Publish is used.');
    }

    public function publish(Request $request): RedirectResponse
    {
        $validated = $request->validate(['revision' => ['required', 'integer', 'min:1']]);
        $entry = $this->entry();
        PdpLayoutContentDefinition::validateAndNormalize($entry->draft_payload);

        try {
            $this->content->publish(
                contentKey: PdpLayoutContentDefinition::KEY,
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()->route('admin.content.pdp.layout.edit')->withErrors([
                'revision' => 'Publish blocked because PDP layout changed in another session. Review the latest draft first.',
            ]);
        }

        return redirect()->route('admin.content.pdp.layout.edit')->with('status', 'PDP layout published for compatible clients.');
    }

    public function restore(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'revision' => ['required', 'integer', 'min:1'],
            'source_revision' => ['required', 'integer', 'min:1'],
        ]);

        try {
            $this->content->restoreDraftFromRevision(
                contentKey: PdpLayoutContentDefinition::KEY,
                revisionToRestore: (int) $validated['source_revision'],
                expectedRevision: (int) $validated['revision'],
                actorFingerprint: $this->actorFingerprint($request),
            );
        } catch (ContentRevisionConflictException) {
            return redirect()->route('admin.content.pdp.layout.edit')->withErrors([
                'revision' => 'Restore blocked because PDP layout changed in another session.',
            ]);
        }

        return redirect()->route('admin.content.pdp.layout.edit')->with('status', 'Historical PDP layout restored into a new private draft.');
    }

    /** @param array<string, mixed> $validated @return array<string, mixed> */
    private function payloadFromRequest(Request $request, array $validated): array
    {
        $orders = $validated['order'];
        $expectedIds = PdpLayoutContentDefinition::sectionIds();
        if (array_diff($expectedIds, array_keys($orders)) !== [] || array_diff(array_keys($orders), $expectedIds) !== []) {
            throw ValidationException::withMessages(['order' => ['Every supported PDP section must have exactly one order value.']]);
        }

        $positions = array_map('intval', array_values($orders));
        sort($positions);
        if ($positions !== range(1, count($expectedIds))) {
            throw ValidationException::withMessages(['order' => ['Section order values must uniquely cover positions 1 through 8.']]);
        }

        $requiredVisible = PdpLayoutContentDefinition::requiredVisibleSectionIds();
        $sections = [];
        foreach ($expectedIds as $id) {
            $sections[$id] = [
                'id' => $id,
                'visible' => in_array($id, $requiredVisible, true) ? true : $request->boolean("visible.$id"),
            ];
        }
        uasort($sections, fn (array $left, array $right): int => ((int) $orders[$left['id']]) <=> ((int) $orders[$right['id']]));

        return PdpLayoutContentDefinition::validateAndNormalize(['sections' => array_values($sections)]);
    }

    private function entry(): ContentEntry
    {
        $entry = ContentEntry::query()->where('content_key', PdpLayoutContentDefinition::KEY)->firstOrFail();
        if ($entry->content_type !== PdpLayoutContentDefinition::TYPE) {
            throw ValidationException::withMessages(['content_type' => ['The reserved pdp.layout key has an incompatible content type.']]);
        }
        return $entry;
    }

    private function actorFingerprint(Request $request): string
    {
        $fingerprint = (string) $request->session()->get('walka_admin_dashboard_actor', '');
        return $fingerprint !== '' ? $fingerprint : hash('sha256', 'dashboard|'.$request->session()->getId());
    }
}
