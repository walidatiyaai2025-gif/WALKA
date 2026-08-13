<?php

namespace App\Enums;

enum MediaAssetPurpose: string
{
    case Product = 'product';
    case Category = 'category';
    case Home = 'home';
    case Editorial = 'editorial';
    case Information = 'information';
}
