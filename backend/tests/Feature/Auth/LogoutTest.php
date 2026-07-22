<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LogoutTest extends TestCase
{
    use RefreshDatabase;

    public function test_logout_revokes_only_the_current_token(): void
    {
        $user = User::factory()->create();
        $current = $user->createToken('current')->plainTextToken;
        $other = $user->createToken('other')->plainTextToken;

        $this->withToken($current)->postJson('/api/logout')
            ->assertOk()
            ->assertExactJson([
                'success' => true,
                'message' => 'Signed out successfully.',
                'data' => null,
                'errors' => null,
                'code' => null,
            ]);

        $this->assertDatabaseCount('personal_access_tokens', 1);
        $this->app['auth']->forgetGuards();
        $this->withToken($current)->getJson('/api/profile')->assertUnauthorized();
        $this->app['auth']->forgetGuards();
        $this->withToken($other)->getJson('/api/profile')->assertOk();
    }

    public function test_logout_rejects_missing_invalid_and_inactive_tokens(): void
    {
        $inactive = User::factory()->inactive()->create();
        $token = $inactive->createToken('inactive')->plainTextToken;

        $this->postJson('/api/logout')->assertUnauthorized();
        $this->withToken('1|invalid')->postJson('/api/logout')->assertUnauthorized();
        $this->withToken($token)->postJson('/api/logout')->assertUnauthorized();
        $this->assertDatabaseCount('personal_access_tokens', 1);
    }
}
