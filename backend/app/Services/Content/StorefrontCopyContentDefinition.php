<?php

namespace App\Services\Content;

use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;
use JsonException;

final class StorefrontCopyContentDefinition
{
    public const KEY = 'storefront.copy';

    public const TYPE = 'storefront.copy';

    public const SCHEMA_VERSION = 1;

    /**
     * @return array<string, string>
     */
    public static function defaultPayload(): array
    {
        return [
            'categories_heading' => 'Categories',
            'categories_body' => 'Explore the current WALKA catalog by collection.',
            'favorites_heading' => 'Favorites',
            'favorites_body' => 'Saved picks from your current WALKA catalog.',
            'favorites_empty_title' => 'No saved products yet.',
            'favorites_empty_body' => 'Save a color from any product page and it will appear here.',
            'favorites_explore_label' => 'Explore products',
            'favorites_remove_label' => 'Remove',
            'pdp_unavailable' => 'This product is no longer available.',
            'pdp_colors_label' => 'Colors',
            'pdp_features_label' => 'Features',
            'pdp_details_label' => 'Details',
            'pdp_buy_label' => 'Buy on Amazon',
            'pdp_asin_label' => 'ASIN',
            'pdp_favorite_add_label' => 'Save favorite',
            'pdp_favorite_remove_label' => 'Remove favorite',
            'information_json' => self::defaultInformationJson(),
        ];
    }

    /**
     * @return array<string, array<int, string>>
     */
    public static function rules(): array
    {
        return [
            'categories_heading' => ['required', 'string', 'max:80'],
            'categories_body' => ['required', 'string', 'max:240'],
            'favorites_heading' => ['required', 'string', 'max:80'],
            'favorites_body' => ['required', 'string', 'max:240'],
            'favorites_empty_title' => ['required', 'string', 'max:100'],
            'favorites_empty_body' => ['required', 'string', 'max:240'],
            'favorites_explore_label' => ['required', 'string', 'max:80'],
            'favorites_remove_label' => ['required', 'string', 'max:60'],
            'pdp_unavailable' => ['required', 'string', 'max:160'],
            'pdp_colors_label' => ['required', 'string', 'max:60'],
            'pdp_features_label' => ['required', 'string', 'max:60'],
            'pdp_details_label' => ['required', 'string', 'max:60'],
            'pdp_buy_label' => ['required', 'string', 'max:80'],
            'pdp_asin_label' => ['required', 'string', 'max:40'],
            'pdp_favorite_add_label' => ['required', 'string', 'max:80'],
            'pdp_favorite_remove_label' => ['required', 'string', 'max:80'],
            'information_json' => ['required', 'string', 'max:30000'],
        ];
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array<string, string>
     */
    public static function validateAndNormalize(array $payload): array
    {
        $normalized = [];

        foreach (array_keys(self::defaultPayload()) as $key) {
            $value = $payload[$key] ?? null;
            $normalized[$key] = is_string($value) ? trim($value) : $value;
        }

        /** @var array<string, string> $validated */
        $validated = Validator::make($normalized, self::rules())->validate();
        $validated['information_json'] = self::validateInformationJson($validated['information_json']);

        return $validated;
    }

    /**
     * @param  array<string, mixed>|null  $payload
     * @return array<string, string>
     */
    public static function editableFields(?array $payload): array
    {
        $fields = self::defaultPayload();

        foreach (array_keys($fields) as $key) {
            $value = $payload[$key] ?? null;
            if (is_string($value)) {
                $fields[$key] = $value;
            }
        }

        return $fields;
    }

    private static function validateInformationJson(string $json): string
    {
        try {
            $value = json_decode($json, true, 64, JSON_THROW_ON_ERROR);
        } catch (JsonException $exception) {
            throw ValidationException::withMessages([
                'information_json' => ['Information JSON is invalid: '.$exception->getMessage()],
            ]);
        }

        if (! is_array($value)) {
            throw ValidationException::withMessages([
                'information_json' => ['Information JSON must be an object.'],
            ]);
        }

        Validator::make($value, [
            'account.eyebrow' => ['required', 'string', 'max:100'],
            'account.title' => ['required', 'string', 'max:100'],
            'account.body' => ['required', 'string', 'max:400'],
            'story.eyebrow' => ['required', 'string', 'max:100'],
            'story.title' => ['required', 'string', 'max:100'],
            'story.body' => ['required', 'string', 'max:3000'],
            'faq.eyebrow' => ['required', 'string', 'max:100'],
            'faq.title' => ['required', 'string', 'max:100'],
            'faq.intro' => ['required', 'string', 'max:500'],
            'faq.items' => ['required', 'array', 'min:1', 'max:30'],
            'faq.items.*.question' => ['required', 'string', 'max:240'],
            'faq.items.*.answer' => ['required', 'string', 'max:1200'],
            'contact.eyebrow' => ['required', 'string', 'max:100'],
            'contact.title' => ['required', 'string', 'max:100'],
            'contact.intro' => ['required', 'string', 'max:500'],
            'contact.links' => ['required', 'array', 'min:1', 'max:10'],
            'contact.links.*.title' => ['required', 'string', 'max:100'],
            'contact.links.*.body' => ['required', 'string', 'max:400'],
            'contact.links.*.label' => ['required', 'string', 'max:80'],
            'contact.links.*.url' => ['required', 'url:https', 'max:500'],
            'amazon_store.eyebrow' => ['required', 'string', 'max:100'],
            'amazon_store.title' => ['required', 'string', 'max:100'],
            'amazon_store.body' => ['required', 'string', 'max:500'],
            'amazon_store.label' => ['required', 'string', 'max:80'],
            'amazon_store.url' => ['required', 'url:https', 'max:500'],
            'social.eyebrow' => ['required', 'string', 'max:100'],
            'social.title' => ['required', 'string', 'max:100'],
            'social.intro' => ['required', 'string', 'max:500'],
            'social.links' => ['required', 'array', 'min:1', 'max:10'],
            'social.links.*.title' => ['required', 'string', 'max:100'],
            'social.links.*.body' => ['required', 'string', 'max:400'],
            'social.links.*.label' => ['required', 'string', 'max:80'],
            'social.links.*.url' => ['required', 'url:https', 'max:500'],
            'privacy.eyebrow' => ['required', 'string', 'max:100'],
            'privacy.title' => ['required', 'string', 'max:100'],
            'privacy.intro' => ['required', 'string', 'max:500'],
            'privacy.sections' => ['required', 'array', 'min:1', 'max:20'],
            'privacy.sections.*.title' => ['required', 'string', 'max:140'],
            'privacy.sections.*.body' => ['required', 'string', 'max:1600'],
            'terms.eyebrow' => ['required', 'string', 'max:100'],
            'terms.title' => ['required', 'string', 'max:100'],
            'terms.intro' => ['required', 'string', 'max:500'],
            'terms.sections' => ['required', 'array', 'min:1', 'max:20'],
            'terms.sections.*.title' => ['required', 'string', 'max:140'],
            'terms.sections.*.body' => ['required', 'string', 'max:1600'],
        ])->validate();

        return json_encode(
            $value,
            JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR,
        );
    }

    private static function defaultInformationJson(): string
    {
        return <<<'JSON'
{"account":{"eyebrow":"WALKA","title":"Account & information","body":"Brand story, verified product help, legal information and official WALKA destinations."},"story":{"title":"Our Story","eyebrow":"WALKA","body":"WALKA creates practical everyday organization products designed around clear materials, useful details and straightforward guidance."},"faq":{"title":"Frequently Asked Questions","eyebrow":"VERIFIED PRODUCT HELP","intro":"Current product guidance published by WALKA.","items":[{"question":"Is the lunch box leakproof?","answer":"WALKA does not make a full leakproof claim. Secure Lock helps prevent spills. Use it for dry and semi-wet foods, not liquids, and carry it upright."},{"question":"What is the lunch box made from?","answer":"Food sits in a SUS304 stainless-steel tray. The outer body is food-grade PP. The lid uses four clips with a silicone gasket."},{"question":"What can go in the dishwasher?","answer":"The SUS304 stainless-steel tray is dishwasher safe. The lid and silicone gasket are dishwasher safe on the top rack."},{"question":"What can go in the microwave?","answer":"The stainless-steel tray, lid and silicone gasket are not microwave safe. Microwave only the PP outer body after removing all three."},{"question":"What comes with the lunch box?","answer":"The set includes the lunch box, insulated carry bag, stainless sauce cup with lid, spoon and fork."},{"question":"How wide does the drawer organizer expand?","answer":"The organizer is 13 × 15 × 2 inches when closed and expands up to 22.4 inches wide. It has eight compartments and a non-slip base."},{"question":"Where do I purchase WALKA products?","answer":"Product purchase buttons open the selected official WALKA listing on Amazon. The app does not run an in-app cart, checkout or payment flow."}]},"contact":{"title":"Contact Us","eyebrow":"SUPPORT","intro":"Choose the route that matches your question. Marketplace order, delivery, return and payment support remains with Amazon.","links":[{"title":"WALKA website","body":"Brand and product information at walkastore.com.","label":"OPEN WEBSITE","url":"https://walkastore.com"},{"title":"Instagram","body":"Follow @walkabrands for WALKA product and brand updates.","label":"OPEN INSTAGRAM","url":"https://www.instagram.com/walkabrands/"}]},"amazon_store":{"title":"Amazon Store","eyebrow":"SHOP WALKA","body":"Discover products in WALKA, then continue to Amazon for marketplace availability and purchase.","label":"OPEN AMAZON STORE","url":"https://www.amazon.com/stores/walkabrand/page/97D69007-E4C8-4FC1-8EBB-45C24A1FEB7C"},"social":{"title":"Follow WALKA","eyebrow":"OFFICIAL DESTINATIONS","intro":"Continue the WALKA brand experience outside the app.","links":[{"title":"@walkabrands","body":"Product stories and WALKA updates.","label":"OPEN INSTAGRAM","url":"https://www.instagram.com/walkabrands/"},{"title":"walkastore.com","body":"Official WALKA web destination.","label":"OPEN WEBSITE","url":"https://walkastore.com"},{"title":"WALKA on Amazon","body":"Official Amazon brand storefront.","label":"OPEN AMAZON","url":"https://www.amazon.com/stores/walkabrand/page/97D69007-E4C8-4FC1-8EBB-45C24A1FEB7C"}]},"privacy":{"title":"Privacy","eyebrow":"LEGAL","intro":"Current WALKA app privacy information.","sections":[{"title":"Favorites","body":"Favorites are stored locally on this device unless a future published service explicitly states otherwise."},{"title":"Search","body":"Product search runs against the catalog available to the app and does not require an account."},{"title":"External purchase","body":"Buy on Amazon opens Amazon externally. Amazon handles marketplace account, order and payment data under its own policies."}]},"terms":{"title":"Terms","eyebrow":"LEGAL","intro":"Current product-discovery and marketplace boundaries.","sections":[{"title":"Product discovery","body":"WALKA presents product information and discovery. Marketplace price, availability, delivery and final transaction terms are determined on Amazon."},{"title":"Product guidance","body":"Use products according to the care and usage guidance shown in the app and applicable marketplace listing."},{"title":"External destinations","body":"Amazon, WALKA web and social links open services outside this app and are subject to their respective terms."}]}}
JSON;
    }
}
