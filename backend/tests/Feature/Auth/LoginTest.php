<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LoginTest extends TestCase
{
    use RefreshDatabase;

    public function test_active_user_signs_in_with_normalized_email(): void
    {
        $user = User::factory()->create([
            'email' => 'active@example.com',
            'password' => 'Password1234',
        ]);

        $response = $this->postJson('/api/login', [
            'email' => ' ACTIVE@EXAMPLE.COM ',
            'password' => 'Password1234',
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.id', $user->id)
            ->assertJsonStructure(['data' => ['token']])
            ->assertJsonMissingPath('data.user.password');
        $this->assertDatabaseCount('personal_access_tokens', 1);
    }

    public function test_unknown_email_wrong_password_and_inactive_account_are_generic_and_atomic(): void
    {
        User::factory()->create(['email' => 'active@example.com', 'password' => 'Password1234']);
        User::factory()->inactive()->create(['email' => 'inactive@example.com', 'password' => 'Password1234']);

        $responses = [
            $this->postJson('/api/login', ['email' => 'missing@example.com', 'password' => 'Password1234']),
            $this->postJson('/api/login', ['email' => 'active@example.com', 'password' => 'WrongPassword123']),
            $this->postJson('/api/login', ['email' => 'inactive@example.com', 'password' => 'Password1234']),
        ];

        foreach ($responses as $response) {
            $response->assertUnauthorized()
                ->assertExactJson([
                    'success' => false,
                    'message' => 'The provided credentials are invalid.',
                    'data' => null,
                    'errors' => null,
                    'code' => 'INVALID_CREDENTIALS',
                ]);
        }
        $this->assertDatabaseCount('personal_access_tokens', 0);
    }
}
