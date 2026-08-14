<?php

namespace Tests\Unit;

use App\Services\Content\InformationContentDefinition;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class InformationContentDefinitionTest extends TestCase
{
    public function test_public_contract_drops_destination_and_executable_fields(): void
    {
        $payload = InformationContentDefinition::defaultPayload();
        $payload['support']['website_url'] = 'https://attacker.example';
        $payload['support']['instagram_url'] = 'https://attacker.example/social';
        $payload['legal']['html'] = '<script>alert(1)</script>';
        $payload['about']['javascript'] = 'alert(1)';

        $normalized = InformationContentDefinition::validateAndNormalize($payload);

        $this->assertArrayNotHasKey('website_url', $normalized['support']);
        $this->assertArrayNotHasKey('instagram_url', $normalized['support']);
        $this->assertArrayNotHasKey('html', $normalized['legal']);
        $this->assertArrayNotHasKey('javascript', $normalized['about']);
    }

    public function test_support_email_must_remain_on_walka_domain(): void
    {
        $payload = InformationContentDefinition::defaultPayload();
        $payload['support']['support_email'] = 'attacker@example.com';

        $this->expectException(ValidationException::class);
        InformationContentDefinition::validateAndNormalize($payload);
    }
}
