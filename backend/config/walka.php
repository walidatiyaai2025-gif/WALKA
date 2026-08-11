<?php

return [
    'release' => env('WALKA_RELEASE', '1.4.0'),
    'brand' => 'WALKA',
    'api_version' => 'v1',
    'purchase_mode' => 'amazon_redirect',
    'admin_token' => env('WALKA_ADMIN_TOKEN'),
    'dashboard_username' => env('WALKA_ADMIN_DASHBOARD_USERNAME', 'admin'),
    'dashboard_password' => env('WALKA_ADMIN_DASHBOARD_PASSWORD'),
];
