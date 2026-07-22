<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RegisterTest extends TestCase
{
    use RefreshDatabase;

    public function test_visitor_registers_exactly_one_active_reporter_and_receives_a_token(): void
    {
        $response = $this->postJson('/api/register', [
            'name' => '  Report User  ',
            'email' => '  REPORTER@Example.COM ',
            'password' => 'Password1234',
            'password_confirmation' => 'Password1234',
        ]);

        $response->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.email', 'reporter@example.com')
            ->assertJsonPath('data.user.role', User::ROLE_REPORTER)
            ->assertJsonPath('data.user.is_active', true)
            ->assertJsonStructure(['data' => ['user' => ['id', 'name', 'email', 'role', 'is_active', 'created_at'], 'token']])
            ->assertJsonMissingPath('data.user.password');

        $this->assertDatabaseCount('users', 1);
        $this->assertDatabaseCount('personal_access_tokens', 1);
        $this->assertDatabaseHas('users', [
            'name' => 'Report User',
            'email' => 'reporter@example.com',
            'role' => User::ROLE_REPORTER,
            'is_active' => true,
        ]);
        $this->assertStringNotContainsString('Password1234', $response->getContent());
    }

    public function test_validation_and_duplicate_email_create_no_partial_state(): void
    {
        User::factory()->create(['email' => 'used@example.com']);

        $response = $this->postJson('/api/register', [
            'name' => '',
            'email' => ' USED@EXAMPLE.COM ',
            'password' => 'short',
            'password_confirmation' => 'different',
        ]);

        $response->assertUnprocessable()
            ->assertJsonPath('success', false)
            ->assertJsonPath('code', 'VALIDATION_ERROR')
            ->assertJsonStructure(['errors' => ['name', 'email', 'password']]);
        $this->assertDatabaseCount('users', 1);
        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_public_role_and_active_state_input_cannot_escalate_account(): void
    {
        $response = $this->postJson('/api/register', [
            'name' => 'Safe Reporter',
            'email' => 'safe@example.com',
            'password' => 'Password1234',
            'password_confirmation' => 'Password1234',
            'role' => User::ROLE_ADMINISTRATOR,
            'is_active' => false,
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.user.role', User::ROLE_REPORTER)
            ->assertJsonPath('data.user.is_active', true);
        $this->assertDatabaseHas('users', [
            'email' => 'safe@example.com',
            'role' => User::ROLE_REPORTER,
            'is_active' => true,
        ]);
    }
}
