<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProfileTest extends TestCase
{
    use RefreshDatabase;

    public function test_token_owner_receives_only_their_own_safe_profile(): void
    {
        $owner = User::factory()->technician()->create();
        $other = User::factory()->create();
        $token = $owner->createToken('test')->plainTextToken;

        $response = $this->withToken($token)->getJson('/api/profile');

        $response->assertOk()
            ->assertJsonPath('data.id', $owner->id)
            ->assertJsonPath('data.role', User::ROLE_TECHNICIAN)
            ->assertJsonMissing(['id' => $other->id])
            ->assertJsonMissingPath('data.password');
    }

    public function test_missing_invalid_revoked_and_inactive_tokens_are_rejected(): void
    {
        $active = User::factory()->create();
        $revoked = $active->createToken('revoked');
        $revokedToken = $revoked->plainTextToken;
        $revoked->accessToken->delete();
        $inactive = User::factory()->inactive()->create();
        $inactiveToken = $inactive->createToken('inactive')->plainTextToken;

        $responses = [
            $this->getJson('/api/profile'),
            $this->withToken('1|not-a-real-token')->getJson('/api/profile'),
            $this->withToken($revokedToken)->getJson('/api/profile'),
            $this->withToken($inactiveToken)->getJson('/api/profile'),
        ];

        foreach ($responses as $response) {
            $response->assertUnauthorized()
                ->assertJsonPath('success', false)
                ->assertJsonPath('code', 'UNAUTHENTICATED');
        }
    }
}
