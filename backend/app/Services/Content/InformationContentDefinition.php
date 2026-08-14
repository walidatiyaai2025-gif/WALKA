<?php

namespace App\Services\Content;

use Illuminate\Validation\ValidationException;

final class InformationContentDefinition
{
    public const KEY = 'information';

    public const TYPE = 'information';

    public const SCHEMA_VERSION = 1;

    public const ABOUT = 'about';

    public const FAQ = 'faq';

    public const SUPPORT = 'support';

    public const LEGAL = 'legal';

    /** @return list<string> */
    public static function sectionIds(): array
    {
        return [self::ABOUT, self::FAQ, self::SUPPORT, self::LEGAL];
    }

    /** @return array<string, mixed> */
    public static function defaultPayload(): array
    {
        return [
            'about' => [
                'hero_eyebrow' => 'OUR STORY',
                'hero_title' => "Organized living.\nElevated everyday.",
                'hero_body' => 'Thoughtful organization essentials that make everyday spaces easier to use and calmer to look at.',
                'story_eyebrow' => 'OUR POINT OF VIEW',
                'story_title' => 'A calmer home begins with thoughtful details.',
                'story_body' => 'WALKA creates organization essentials that balance practical function with a refined visual language. We believe useful objects should make everyday spaces easier to live with and quieter to look at.',
                'values_eyebrow' => 'WHAT GUIDES US',
                'values' => [
                    [
                        'id' => 'purposeful',
                        'title' => 'Purposeful',
                        'body' => 'Useful details first, unnecessary complexity removed.',
                    ],
                    [
                        'id' => 'refined',
                        'title' => 'Refined',
                        'body' => 'Clean proportions and restrained visual language.',
                    ],
                    [
                        'id' => 'everyday',
                        'title' => 'Everyday',
                        'body' => 'Designed to support routines again and again.',
                    ],
                ],
                'principles_eyebrow' => 'HOW WE DESIGN',
                'principles_title' => 'Simple choices, made deliberately.',
                'principles' => [
                    [
                        'id' => 'useful-first',
                        'title' => 'Useful first',
                        'body' => 'Every WALKA product starts with the routine it needs to improve, then removes unnecessary complexity.',
                    ],
                    [
                        'id' => 'calm-by-design',
                        'title' => 'Calm by design',
                        'body' => 'Clean proportions, restrained color and considered details help products sit naturally in the home.',
                    ],
                    [
                        'id' => 'made-for-repetition',
                        'title' => 'Made for repetition',
                        'body' => 'The best organization products quietly support everyday habits and remain easy to use again and again.',
                    ],
                ],
                'closing_eyebrow' => 'WALKA',
                'closing_title' => 'Thoughtful pieces for a better organized everyday.',
                'closing_body' => 'Explore the current collection in the app. When you are ready to purchase, WALKA sends you to the official Amazon listing.',
            ],
            'faq' => [
                'eyebrow' => 'VERIFIED PRODUCT HELP',
                'title' => 'Frequently Asked Questions',
                'intro' => 'These answers follow the WALKA Product Master used by the release UI and regression tests.',
                'items' => [
                    [
                        'id' => 'lunch-leakproof',
                        'question' => 'Is the lunch box leakproof?',
                        'answer' => 'WALKA does not make a full leakproof claim. Secure Lock helps prevent spills. Use the lunch box for dry & semi-wet foods, not liquids, and carry it upright.',
                    ],
                    [
                        'id' => 'lunch-materials',
                        'question' => 'What is the lunch box made from?',
                        'answer' => 'Food sits in a SUS304 stainless-steel tray. The outer body is food-grade PP. The lid uses four clips with a silicone gasket.',
                    ],
                    [
                        'id' => 'lunch-dishwasher',
                        'question' => 'What can go in the dishwasher?',
                        'answer' => 'The SUS304 stainless-steel tray is dishwasher safe. The lid and silicone gasket are dishwasher safe on the top rack.',
                    ],
                    [
                        'id' => 'lunch-microwave',
                        'question' => 'What can go in the microwave?',
                        'answer' => 'The stainless-steel tray, lid and silicone gasket are not microwave safe. Microwave only the PP outer body after removing all three.',
                    ],
                    [
                        'id' => 'lunch-included',
                        'question' => 'What comes with the lunch box?',
                        'answer' => 'The set includes the lunch box, insulated carry bag, stainless sauce cup with lid, spoon and fork.',
                    ],
                    [
                        'id' => 'drawer-width',
                        'question' => 'How wide does the drawer organizer expand?',
                        'answer' => 'The organizer is 13 × 15 × 2 inches when closed and expands up to 22.4 inches wide. It has eight compartments and a non-slip base.',
                    ],
                    [
                        'id' => 'purchase-location',
                        'question' => 'Where do I purchase WALKA products?',
                        'answer' => 'Product purchase buttons open the selected official WALKA listing on Amazon. The app does not run an in-app cart, checkout or payment flow.',
                    ],
                ],
            ],
            'support' => [
                'eyebrow' => 'SUPPORT',
                'title' => 'Contact Us',
                'intro' => 'Choose the route that matches your question. Marketplace order, delivery, return and payment support remains with Amazon.',
                'amazon_order_title' => 'Amazon order support',
                'amazon_order_body' => 'Use your Amazon account for an existing marketplace order so the request stays connected to the correct transaction.',
                'support_email' => 'support@walkastore.com',
                'email_title' => 'Email WALKA',
                'email_body' => 'Brand and product support from WALKA.',
                'website_title' => 'WALKA website',
                'website_body' => 'Brand and product information at walkastore.com.',
                'instagram_title' => 'Instagram',
                'instagram_body' => 'Follow @walkabrands for WALKA product and brand updates.',
            ],
            'legal' => [
                'eyebrow' => 'LEGAL PRESENTATION',
                'privacy' => [
                    'title' => 'Privacy',
                    'intro' => 'Current app behavior before backend integration.',
                    'sections' => [
                        [
                            'id' => 'favorites',
                            'title' => 'Favorites',
                            'body' => 'Drawer Organizer favorites are stored locally on this device in the current release.',
                        ],
                        [
                            'id' => 'search',
                            'title' => 'Search',
                            'body' => 'Current product search runs locally in Flutter and is not connected to a remote WALKA search service.',
                        ],
                        [
                            'id' => 'external-purchase',
                            'title' => 'External purchase',
                            'body' => 'Buy on Amazon opens Amazon externally. Amazon handles marketplace account, order and payment data under its own policies.',
                        ],
                    ],
                ],
                'terms' => [
                    'title' => 'Terms',
                    'intro' => 'Current product-discovery and marketplace boundaries.',
                    'sections' => [
                        [
                            'id' => 'product-discovery',
                            'title' => 'Product discovery',
                            'body' => 'WALKA presents product information and discovery. Marketplace price, availability, delivery and final transaction terms are determined on Amazon.',
                        ],
                        [
                            'id' => 'product-guidance',
                            'title' => 'Product guidance',
                            'body' => 'Use products according to the verified care and usage guidance shown in the app and applicable marketplace listing.',
                        ],
                        [
                            'id' => 'external-destinations',
                            'title' => 'External destinations',
                            'body' => 'Amazon, WALKA web and social links open services outside this app and subject to their respective terms.',
                        ],
                    ],
                ],
                'review_notice_title' => 'Legal review required before store publication',
                'review_notice_body' => 'This is the visual presentation layer. Final jurisdiction-specific legal wording should be reviewed before public production release.',
            ],
        ];
    }

    /**
     * Validate and normalize the exact public Information contract.
     * Unknown fields are intentionally discarded at this boundary.
     *
     * @param  array<string, mixed>  $payload
     * @return array<string, mixed>
     */
    public static function validateAndNormalize(array $payload): array
    {
        $about = self::object($payload, 'about');
        $faq = self::object($payload, 'faq');
        $support = self::object($payload, 'support');
        $legal = self::object($payload, 'legal');

        return [
            'about' => self::normalizeAbout($about),
            'faq' => self::normalizeFaq($faq),
            'support' => self::normalizeSupport($support),
            'legal' => self::normalizeLegal($legal),
        ];
    }

    /** @param array<string, mixed>|null $payload */
    public static function editablePayload(?array $payload): array
    {
        if ($payload === null) {
            return self::defaultPayload();
        }

        try {
            return self::validateAndNormalize($payload);
        } catch (ValidationException) {
            return self::defaultPayload();
        }
    }

    /**
     * Replace one typed subsection while preserving all other validated draft
     * sections. This is used by the owner-friendly Admin panels.
     *
     * @param  array<string, mixed>  $current
     * @param  array<string, mixed>  $sectionPayload
     * @return array<string, mixed>
     */
    public static function withSection(array $current, string $section, array $sectionPayload): array
    {
        if (! in_array($section, self::sectionIds(), true)) {
            self::fail('section', 'Unknown information section.');
        }

        $normalized = self::editablePayload($current);
        $normalized[$section] = $sectionPayload;

        return self::validateAndNormalize($normalized);
    }

    /** @param array<string, mixed> $about */
    private static function normalizeAbout(array $about): array
    {
        $valueIds = ['purposeful', 'refined', 'everyday'];
        $principleIds = ['useful-first', 'calm-by-design', 'made-for-repetition'];

        return [
            'hero_eyebrow' => self::text($about, 'hero_eyebrow', 80, 'about'),
            'hero_title' => self::text($about, 'hero_title', 180, 'about'),
            'hero_body' => self::text($about, 'hero_body', 500, 'about'),
            'story_eyebrow' => self::text($about, 'story_eyebrow', 80, 'about'),
            'story_title' => self::text($about, 'story_title', 180, 'about'),
            'story_body' => self::text($about, 'story_body', 900, 'about'),
            'values_eyebrow' => self::text($about, 'values_eyebrow', 80, 'about'),
            'values' => self::fixedCopyItems($about, 'values', $valueIds, 100, 300, 'about'),
            'principles_eyebrow' => self::text($about, 'principles_eyebrow', 80, 'about'),
            'principles_title' => self::text($about, 'principles_title', 180, 'about'),
            'principles' => self::fixedCopyItems($about, 'principles', $principleIds, 100, 500, 'about'),
            'closing_eyebrow' => self::text($about, 'closing_eyebrow', 80, 'about'),
            'closing_title' => self::text($about, 'closing_title', 180, 'about'),
            'closing_body' => self::text($about, 'closing_body', 500, 'about'),
        ];
    }

    /** @param array<string, mixed> $faq */
    private static function normalizeFaq(array $faq): array
    {
        $items = $faq['items'] ?? null;
        if (! is_array($items) || ! array_is_list($items) || count($items) < 1 || count($items) > 12) {
            self::fail('faq.items', 'FAQ must contain between 1 and 12 ordered items.');
        }

        $seen = [];
        $normalizedItems = [];
        foreach ($items as $index => $item) {
            if (! is_array($item)) {
                self::fail("faq.items.$index", 'Each FAQ item must be an object.');
            }
            $id = self::stableId($item, 'id', "faq.items.$index");
            if (isset($seen[$id])) {
                self::fail("faq.items.$index.id", 'FAQ item IDs must be unique.');
            }
            $seen[$id] = true;
            $normalizedItems[] = [
                'id' => $id,
                'question' => self::text($item, 'question', 220, "faq.items.$index"),
                'answer' => self::text($item, 'answer', 1000, "faq.items.$index"),
            ];
        }

        return [
            'eyebrow' => self::text($faq, 'eyebrow', 80, 'faq'),
            'title' => self::text($faq, 'title', 180, 'faq'),
            'intro' => self::text($faq, 'intro', 600, 'faq'),
            'items' => $normalizedItems,
        ];
    }

    /** @param array<string, mixed> $support */
    private static function normalizeSupport(array $support): array
    {
        $email = self::text($support, 'support_email', 160, 'support');
        if (filter_var($email, FILTER_VALIDATE_EMAIL) === false || ! str_ends_with(strtolower($email), '@walkastore.com')) {
            self::fail('support.support_email', 'Support email must be a valid @walkastore.com address.');
        }

        return [
            'eyebrow' => self::text($support, 'eyebrow', 80, 'support'),
            'title' => self::text($support, 'title', 180, 'support'),
            'intro' => self::text($support, 'intro', 700, 'support'),
            'amazon_order_title' => self::text($support, 'amazon_order_title', 180, 'support'),
            'amazon_order_body' => self::text($support, 'amazon_order_body', 700, 'support'),
            'support_email' => strtolower($email),
            'email_title' => self::text($support, 'email_title', 180, 'support'),
            'email_body' => self::text($support, 'email_body', 500, 'support'),
            'website_title' => self::text($support, 'website_title', 180, 'support'),
            'website_body' => self::text($support, 'website_body', 500, 'support'),
            'instagram_title' => self::text($support, 'instagram_title', 180, 'support'),
            'instagram_body' => self::text($support, 'instagram_body', 500, 'support'),
        ];
    }

    /** @param array<string, mixed> $legal */
    private static function normalizeLegal(array $legal): array
    {
        return [
            'eyebrow' => self::text($legal, 'eyebrow', 80, 'legal'),
            'privacy' => self::legalDocument(self::object($legal, 'privacy'), 'legal.privacy'),
            'terms' => self::legalDocument(self::object($legal, 'terms'), 'legal.terms'),
            'review_notice_title' => self::text($legal, 'review_notice_title', 220, 'legal'),
            'review_notice_body' => self::text($legal, 'review_notice_body', 900, 'legal'),
        ];
    }

    /** @param array<string, mixed> $document */
    private static function legalDocument(array $document, string $prefix): array
    {
        $sections = $document['sections'] ?? null;
        if (! is_array($sections) || ! array_is_list($sections) || count($sections) < 1 || count($sections) > 8) {
            self::fail("$prefix.sections", 'Legal document must contain between 1 and 8 ordered sections.');
        }

        $seen = [];
        $normalizedSections = [];
        foreach ($sections as $index => $section) {
            if (! is_array($section)) {
                self::fail("$prefix.sections.$index", 'Each legal section must be an object.');
            }
            $id = self::stableId($section, 'id', "$prefix.sections.$index");
            if (isset($seen[$id])) {
                self::fail("$prefix.sections.$index.id", 'Legal section IDs must be unique per document.');
            }
            $seen[$id] = true;
            $normalizedSections[] = [
                'id' => $id,
                'title' => self::text($section, 'title', 180, "$prefix.sections.$index"),
                'body' => self::text($section, 'body', 1400, "$prefix.sections.$index"),
            ];
        }

        return [
            'title' => self::text($document, 'title', 180, $prefix),
            'intro' => self::text($document, 'intro', 700, $prefix),
            'sections' => $normalizedSections,
        ];
    }

    /**
     * @param  array<string, mixed>  $parent
     * @param  list<string>  $expectedIds
     * @return list<array{id:string,title:string,body:string}>
     */
    private static function fixedCopyItems(
        array $parent,
        string $key,
        array $expectedIds,
        int $titleMax,
        int $bodyMax,
        string $prefix,
    ): array {
        $items = $parent[$key] ?? null;
        if (! is_array($items) || ! array_is_list($items) || count($items) !== count($expectedIds)) {
            self::fail("$prefix.$key", sprintf('%s must contain the released stable item set.', $key));
        }

        $seen = [];
        $normalized = [];
        foreach ($items as $index => $item) {
            if (! is_array($item)) {
                self::fail("$prefix.$key.$index", 'Copy item must be an object.');
            }
            $id = self::stableId($item, 'id', "$prefix.$key.$index");
            if (! in_array($id, $expectedIds, true) || isset($seen[$id])) {
                self::fail("$prefix.$key.$index.id", 'Copy item IDs must match the released stable item set exactly once.');
            }
            $seen[$id] = true;
            $normalized[] = [
                'id' => $id,
                'title' => self::text($item, 'title', $titleMax, "$prefix.$key.$index"),
                'body' => self::text($item, 'body', $bodyMax, "$prefix.$key.$index"),
            ];
        }

        foreach ($expectedIds as $id) {
            if (! isset($seen[$id])) {
                self::fail("$prefix.$key", "Missing released copy item: $id.");
            }
        }

        return $normalized;
    }

    /** @param array<string, mixed> $parent */
    private static function object(array $parent, string $key): array
    {
        $value = $parent[$key] ?? null;
        if (! is_array($value) || array_is_list($value)) {
            self::fail($key, "$key must be an object.");
        }

        return $value;
    }

    /** @param array<string, mixed> $parent */
    private static function text(array $parent, string $key, int $max, string $prefix): string
    {
        $value = $parent[$key] ?? null;
        if (! is_string($value)) {
            self::fail("$prefix.$key", "$key must be text.");
        }

        $value = trim($value);
        if ($value === '' || mb_strlen($value) > $max) {
            self::fail("$prefix.$key", "$key must be non-empty and no longer than $max characters.");
        }

        return $value;
    }

    /** @param array<string, mixed> $parent */
    private static function stableId(array $parent, string $key, string $prefix): string
    {
        $value = $parent[$key] ?? null;
        if (! is_string($value) || ! preg_match('/^[a-z0-9][a-z0-9-]{0,63}$/', $value)) {
            self::fail("$prefix.$key", "$key must be a stable lowercase ID.");
        }

        return $value;
    }

    private static function fail(string $field, string $message): never
    {
        throw ValidationException::withMessages([$field => [$message]]);
    }
}
