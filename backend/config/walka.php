<?php

return [
    'release' => env('WALKA_RELEASE', '1.1.0'),
    'brand' => 'WALKA',
    'api_version' => 'v1',
    'purchase_mode' => 'amazon_redirect',
    'products' => [
        [
            'id' => 'drawer-organizer',
            'name' => 'WALKA Drawer Organizer',
            'category' => 'drawer-organization',
            'features' => [
                '8 compartments',
                'Expandable to 22.4 in',
                'Non-slip base',
            ],
            'facts' => [
                'material' => 'Plastic',
                'compartments' => 8,
                'closed_size_in' => [13.0, 15.0, 2.0],
                'expandable_width_in' => 22.4,
                'non_slip_base' => true,
                'product_weight_lb' => 1.72,
                'packaging_in' => [13.46, 15.16, 2.36],
            ],
            'variants' => [
                [
                    'id' => 'drawer-organizer:white',
                    'color' => 'White',
                    'asin' => 'B0FQN4DCTG',
                ],
                [
                    'id' => 'drawer-organizer:gray',
                    'color' => 'Gray',
                    'asin' => 'B0FQN4L2ZD',
                ],
            ],
        ],
        [
            'id' => 'stainless-steel-bento-lunch-box',
            'name' => 'WALKA Large Stainless Steel Bento Lunch Box for Adults',
            'category' => 'lunch',
            'features' => [
                '1200 ml',
                '4 compartments',
                'SUS304 stainless steel food tray',
                'BPA-free PP outer body',
                'Best for dry & semi-wet foods',
            ],
            'facts' => [
                'capacity_ml' => 1200,
                'food_tray' => 'SUS304 stainless steel',
                'compartments' => 4,
                'outer_body' => 'BPA-free PP',
                'lid' => '4 clips with silicone gasket',
                'included' => [
                    'Insulated carry bag',
                    'Stainless sauce cup with lid',
                    'Spoon',
                    'Fork',
                ],
                'lunch_box_size_in' => [11.42, 8.66, 3.15],
                'with_bag_size_in' => [11.81, 8.86, 3.54],
                'bag_size_in' => [10.63, 7.48, 2.76],
                'weight_with_bag_lb' => 1.84,
                'care' => [
                    'sus304_tray' => 'Dishwasher safe on the top rack; not microwave safe.',
                    'lid_and_gasket' => 'Hand wash.',
                    'pp_outer_body' => 'Microwave safe without the stainless steel tray.',
                ],
                'usage_language' => [
                    'Secure Lock | Helps Prevent Spills',
                    'Best for dry & semi-wet foods',
                    'Not intended for liquids',
                    'Carry upright',
                ],
            ],
            'variants' => [
                [
                    'id' => 'lunch-box:blue',
                    'color' => 'Blue',
                    'pantone' => 'PANTONE 4155 U',
                    'asin' => 'B0FQN4L8MW',
                ],
                [
                    'id' => 'lunch-box:pink',
                    'color' => 'Pink',
                    'pantone' => 'PANTONE 9242 U',
                    'asin' => 'B0FQN3W4SF',
                ],
                [
                    'id' => 'lunch-box:green',
                    'color' => 'Green',
                    'pantone' => 'PANTONE 6198 U',
                    'asin' => 'B0GPZNKF9F',
                ],
            ],
        ],
    ],
];
