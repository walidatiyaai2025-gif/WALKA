<?php

namespace App\Data;

final class WalkaCatalogSeed
{
    /**
     * @return list<array<string, mixed>>
     */
    public static function products(): array
    {
        return [
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
                    'Food-grade PP outer body',
                    'Best suited for dry meals & snacks.',
                ],
                'facts' => [
                    'capacity_ml' => 1200,
                    'food_tray' => 'SUS304 stainless steel',
                    'compartments' => 4,
                    'outer_body' => 'Food-grade PP',
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
                        'sus304_tray' => 'Dishwasher safe; not microwave safe.',
                        'lid_and_gasket' => 'Dishwasher safe on the top rack; not microwave safe.',
                        'pp_outer_body' => 'Microwave safe only after removing the stainless tray, lid, and silicone gasket.',
                    ],
                    'usage_language' => [
                        'Secure Lock | Helps Prevent Spills',
                        'SPILL-RESISTANT DESIGN',
                        'Best suited for dry meals & snacks.',
                        'Not intended for liquids. Best for dry & semi-wet foods.',
                        'Carry upright.',
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
        ];
    }
}
