<?php

namespace Tests\Feature;

use App\Models\ContentEntry;
use App\Services\Content\InformationContentDefinition;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class AdminInformationControllerTest extends TestCase
{
    use RefreshDatabase;

    /** @var array<string, mixed> */
    private array $session;

    protected function setUp(): void
    {
        parent::setUp();

        config()->set('walka_dashboard.role', 'owner');
        config()->set('walka.dashboard_username', 'admin');
        config()->set('walka.dashboard_password', 'Walka-Admin-Test-Password-2026');

        $this->session = [
            'walka_admin_dashboard_authenticated' => true,
            'walka_admin_dashboard_username' => 'admin',
            'walka_admin_dashboard_actor' => hash('sha256', 'cms-040-043-information-test'),
        ];
    }

    public function test_all_four_typed_editors_share_one_revision_and_publish_one_public_snapshot(): void
    {
        $this->withSession($this->session)
            ->get(route('admin.content.information.edit', ['section' => 'about']))
            ->assertOk()
            ->assertSee('About / Story');

        $entry = $this->entry();
        $this->assertSame(1, $entry->revision);
        $this->assertNull($entry->published_revision);
        $this->getJson('/api/v1/content/information')->assertNotFound();

        $defaults = InformationContentDefinition::defaultPayload();

        $this->withSession($this->session)
            ->patch(
                route('admin.content.information.update', ['section' => 'about']),
                $this->aboutForm($defaults['about'], 1, 'CMS-controlled WALKA story'),
            )
            ->assertRedirect(route('admin.content.information.edit', ['section' => 'about']));
        $this->assertSame(2, $this->entry()->revision);

        $this->withSession($this->session)
            ->patch(
                route('admin.content.information.update', ['section' => 'faq']),
                $this->faqForm($defaults['faq'], 2, 'Can CMS update this FAQ?'),
            )
            ->assertRedirect(route('admin.content.information.edit', ['section' => 'faq']));
        $this->assertSame(3, $this->entry()->revision);

        $support = $defaults['support'];
        $support['support_email'] = 'care@walkastore.com';
        $this->withSession($this->session)
            ->patch(
                route('admin.content.information.update', ['section' => 'support']),
                array_merge(['revision' => 3, 'website_url' => 'https://evil.example'], $support),
            )
            ->assertRedirect(route('admin.content.information.edit', ['section' => 'support']));
        $this->assertSame(4, $this->entry()->revision);

        $this->withSession($this->session)
            ->patch(
                route('admin.content.information.update', ['section' => 'legal']),
                $this->legalForm($defaults['legal'], 4, 'CMS-controlled Terms'),
            )
            ->assertRedirect(route('admin.content.information.edit', ['section' => 'legal']));
        $this->assertSame(5, $this->entry()->revision);

        $this->withSession($this->session)
            ->post(
                route('admin.content.information.publish', ['section' => 'legal']),
                ['revision' => 5],
            )
            ->assertRedirect(route('admin.content.information.edit', ['section' => 'legal']));

        $entry = $this->entry();
        $this->assertSame(6, $entry->revision);
        $this->assertSame(6, $entry->published_revision);

        $response = $this->getJson('/api/v1/content/information')
            ->assertOk()
            ->assertJsonPath('data.key', 'information')
            ->assertJsonPath('data.type', 'information')
            ->assertJsonPath('data.schema_version', 1)
            ->assertJsonPath('data.revision', 6)
            ->assertJsonPath('data.payload.about.hero_title', 'CMS-controlled WALKA story')
            ->assertJsonPath('data.payload.faq.items.0.question', 'Can CMS update this FAQ?')
            ->assertJsonPath('data.payload.support.support_email', 'care@walkastore.com')
            ->assertJsonPath('data.payload.legal.terms.title', 'CMS-controlled Terms');

        $this->assertArrayNotHasKey('website_url', $response->json('data.payload.support'));
        $this->assertSame(
            [
                'eyebrow',
                'title',
                'intro',
                'amazon_order_title',
                'amazon_order_body',
                'support_email',
                'email_title',
                'email_body',
                'website_title',
                'website_body',
                'instagram_title',
                'instagram_body',
            ],
            array_keys($response->json('data.payload.support')),
        );
    }

    public function test_support_email_is_domain_restricted_and_legal_review_notice_is_mandatory(): void
    {
        $this->withSession($this->session)
            ->get(route('admin.content.information.edit', ['section' => 'support']))
            ->assertOk();

        $defaults = InformationContentDefinition::defaultPayload();
        $support = $defaults['support'];
        $support['support_email'] = 'attacker@example.com';

        $this->withSession($this->session)
            ->from(route('admin.content.information.edit', ['section' => 'support']))
            ->patch(
                route('admin.content.information.update', ['section' => 'support']),
                array_merge(['revision' => 1], $support),
            )
            ->assertRedirect()
            ->assertSessionHasErrors('support.support_email');

        $legal = $this->legalForm($defaults['legal'], 1);
        unset($legal['review_notice_title']);
        $this->withSession($this->session)
            ->from(route('admin.content.information.edit', ['section' => 'legal']))
            ->patch(
                route('admin.content.information.update', ['section' => 'legal']),
                $legal,
            )
            ->assertRedirect()
            ->assertSessionHasErrors('review_notice_title');

        $entry = $this->entry();
        $this->assertSame(1, $entry->revision);
        $this->assertNull($entry->published_revision);
    }

    public function test_duplicate_faq_ids_fail_closed_and_restore_never_auto_publishes(): void
    {
        $this->withSession($this->session)
            ->get(route('admin.content.information.edit', ['section' => 'faq']))
            ->assertOk();

        $defaults = InformationContentDefinition::defaultPayload();
        $form = $this->faqForm($defaults['faq'], 1);
        $form['items'][1]['id'] = $form['items'][0]['id'];

        $this->withSession($this->session)
            ->from(route('admin.content.information.edit', ['section' => 'faq']))
            ->patch(
                route('admin.content.information.update', ['section' => 'faq']),
                $form,
            )
            ->assertRedirect()
            ->assertSessionHasErrors();
        $this->assertSame(1, $this->entry()->revision);

        $this->withSession($this->session)
            ->post(
                route('admin.content.information.publish', ['section' => 'faq']),
                ['revision' => 1],
            )
            ->assertRedirect();
        $this->assertSame(2, $this->entry()->published_revision);

        $this->withSession($this->session)
            ->patch(
                route('admin.content.information.update', ['section' => 'faq']),
                $this->faqForm($defaults['faq'], 2, 'Draft-only FAQ change'),
            )
            ->assertRedirect();
        $this->assertSame(3, $this->entry()->revision);

        $this->withSession($this->session)
            ->post(
                route('admin.content.information.restore', ['section' => 'faq']),
                ['revision' => 3, 'source_revision' => 1],
            )
            ->assertRedirect();

        $entry = $this->entry();
        $this->assertSame(4, $entry->revision);
        $this->assertSame(2, $entry->published_revision);
        $this->assertSame(
            InformationContentDefinition::defaultPayload(),
            $entry->draft_payload,
        );
        $this->getJson('/api/v1/content/information')
            ->assertOk()
            ->assertJsonPath('data.revision', 2)
            ->assertJsonPath(
                'data.payload.faq.items.0.question',
                $defaults['faq']['items'][0]['question'],
            );
    }

    /** @param array<string, mixed> $about */
    private function aboutForm(array $about, int $revision, ?string $heroTitle = null): array
    {
        $values = [];
        foreach ($about['values'] as $item) {
            $values[$item['id']] = ['title' => $item['title'], 'body' => $item['body']];
        }
        $principles = [];
        foreach ($about['principles'] as $item) {
            $principles[$item['id']] = ['title' => $item['title'], 'body' => $item['body']];
        }

        return [
            'revision' => $revision,
            'hero_eyebrow' => $about['hero_eyebrow'],
            'hero_title' => $heroTitle ?? $about['hero_title'],
            'hero_body' => $about['hero_body'],
            'story_eyebrow' => $about['story_eyebrow'],
            'story_title' => $about['story_title'],
            'story_body' => $about['story_body'],
            'values_eyebrow' => $about['values_eyebrow'],
            'values' => $values,
            'principles_eyebrow' => $about['principles_eyebrow'],
            'principles_title' => $about['principles_title'],
            'principles' => $principles,
            'closing_eyebrow' => $about['closing_eyebrow'],
            'closing_title' => $about['closing_title'],
            'closing_body' => $about['closing_body'],
        ];
    }

    /** @param array<string, mixed> $faq */
    private function faqForm(array $faq, int $revision, ?string $firstQuestion = null): array
    {
        $items = $faq['items'];
        if ($firstQuestion !== null) {
            $items[0]['question'] = $firstQuestion;
        }

        return [
            'revision' => $revision,
            'eyebrow' => $faq['eyebrow'],
            'title' => $faq['title'],
            'intro' => $faq['intro'],
            'items' => $items,
        ];
    }

    /** @param array<string, mixed> $legal */
    private function legalForm(array $legal, int $revision, ?string $termsTitle = null): array
    {
        return [
            'revision' => $revision,
            'eyebrow' => $legal['eyebrow'],
            'privacy_title' => $legal['privacy']['title'],
            'privacy_intro' => $legal['privacy']['intro'],
            'privacy_sections' => $legal['privacy']['sections'],
            'terms_title' => $termsTitle ?? $legal['terms']['title'],
            'terms_intro' => $legal['terms']['intro'],
            'terms_sections' => $legal['terms']['sections'],
            'review_notice_title' => $legal['review_notice_title'],
            'review_notice_body' => $legal['review_notice_body'],
        ];
    }

    private function entry(): ContentEntry
    {
        return ContentEntry::query()
            ->where('content_key', InformationContentDefinition::KEY)
            ->firstOrFail()
            ->refresh();
    }
}
