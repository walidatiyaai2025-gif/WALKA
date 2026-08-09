<?php

return [
    'release' => env('WALKA_RELEASE', '0.8.0'),
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
                'Expandable 13–22.4 in',
                'Non-slip base',
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
                '304 stainless steel tray',
                'Best for dry & semi-wet foods',
            ],
            'variants' => [
                [
                    'id' => 'lunch-box:blue',
                    'color' => 'Blue',
                    'asin' => 'B0FQN4L8MW',
                ],
                [
                    'id' => 'lunch-box:pink',
                    'color' => 'Pink',
                    'asin' => 'B0FQN3W4SF',
                ],
                [
                    'id' => 'lunch-box:green',
                    'color' => 'Green',
                    'asin' => 'B0GPZNKF9F',
                ],
            ],
        ],
    ],
];
