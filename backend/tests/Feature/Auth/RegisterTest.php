<?php

namespace Tests\Feature\Auth;

use App\Enums\AccountStatus;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RegisterTest extends TestCase
{
    use RefreshDatabase;

    public function test_registration_creates_one_normalized_pending_account_without_a_token(): void
    {
        $response = $this->postJson('/api/register', [
            'name' => '  أحمد   السالم  ',
            'email' => '  REPORTER@Example.COM ',
            'role' => User::ROLE_REPORTER,
            'password' => 'StrongPassword123',
            'password_confirmation' => 'StrongPassword123',
        ]);

        $response->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('message', 'تم إرسال طلب إنشاء الحساب بنجاح إلى الإدارة للمراجعة.')
            ->assertJsonPath('data.user.email', 'reporter@example.com')
            ->assertJsonPath('data.user.name', 'أحمد السالم')
            ->assertJsonPath('data.user.role', User::ROLE_REPORTER)
            ->assertJsonPath('data.user.account_status', AccountStatus::Pending->value)
            ->assertJsonPath('data.user.is_active', false)
            ->assertJsonMissingPath('data.token')
            ->assertJsonMissingPath('data.user.password');

        $this->assertDatabaseCount('users', 1);
        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_reporter_and_technician_are_the_only_publicly_requestable_roles(): void
    {
        foreach ([User::ROLE_REPORTER, User::ROLE_TECHNICIAN] as $index => $role) {
            $this->postJson('/api/register', [
                'name' => $index === 0 ? 'Valid Reporter' : 'Valid Technician',
                'email' => "valid{$index}@example.com",
                'role' => $role,
                'password' => 'StrongPassword123',
                'password_confirmation' => 'StrongPassword123',
            ])->assertCreated()->assertJsonPath('data.user.role', $role);
        }

        $this->postJson('/api/register', [
            'name' => 'Admin Request',
            'email' => 'admin-request@example.com',
            'role' => User::ROLE_ADMINISTRATOR,
            'password' => 'StrongPassword123',
            'password_confirmation' => 'StrongPassword123',
        ])->assertUnprocessable()->assertJsonValidationErrors('role');

        $this->assertDatabaseMissing('users', ['email' => 'admin-request@example.com']);
    }

    public function test_arabic_and_english_names_are_normalized_and_invalid_names_are_rejected(): void
    {
        foreach (["Mary O'Neil", 'سارة عبد-الله'] as $index => $name) {
            $this->postJson('/api/register', [
                'name' => $name,
                'email' => "name{$index}@example.com",
                'password' => 'StrongPassword123',
                'password_confirmation' => 'StrongPassword123',
            ])->assertCreated();
        }

        foreach (['   ', '12345', 'John @ Smith', 'A'] as $index => $name) {
            $this->postJson('/api/register', [
                'name' => $name,
                'email' => "invalid-name{$index}@example.com",
                'password' => 'StrongPassword123',
                'password_confirmation' => 'StrongPassword123',
            ])->assertUnprocessable()->assertJsonValidationErrors('name');
        }
    }

    public function test_email_is_case_insensitively_unique_after_normalization(): void
    {
        User::factory()->create(['email' => 'used@example.com']);

        $this->postJson('/api/register', [
            'name' => 'Valid Name',
            'email' => ' USED@EXAMPLE.COM ',
            'password' => 'StrongPassword123',
            'password_confirmation' => 'StrongPassword123',
        ])->assertUnprocessable()->assertJsonValidationErrors('email');

        $this->assertDatabaseCount('users', 1);
    }

    public function test_repeated_normalized_email_request_cannot_create_a_second_pending_account(): void
    {
        $payload = [
            'name' => 'First Request',
            'email' => 'duplicate@example.com',
            'password' => 'StrongPassword123',
            'password_confirmation' => 'StrongPassword123',
        ];

        $this->postJson('/api/register', $payload)->assertCreated();
        $this->postJson('/api/register', [
            ...$payload,
            'email' => ' DUPLICATE@EXAMPLE.COM ',
        ])->assertUnprocessable()->assertJsonValidationErrors('email');

        $this->assertDatabaseCount('users', 1);
        $this->assertDatabaseHas('users', [
            'email' => 'duplicate@example.com',
            'account_status' => AccountStatus::Pending->value,
        ]);
    }

    public function test_password_strength_and_confirmation_are_required(): void
    {
        foreach ([
            ['alllowercase123', 'alllowercase123'],
            ['ALLUPPERCASE123', 'ALLUPPERCASE123'],
            ['WithoutNumbersHere', 'WithoutNumbersHere'],
            ['Short123', 'Short123'],
            ['StrongPassword123', 'DifferentPassword123'],
        ] as $index => [$password, $confirmation]) {
            $this->postJson('/api/register', [
                'name' => 'Password User',
                'email' => "password{$index}@example.com",
                'password' => $password,
                'password_confirmation' => $confirmation,
            ])->assertUnprocessable()->assertJsonValidationErrors('password');
        }

        $this->assertDatabaseCount('users', 0);
    }

    public function test_unexpected_or_manipulated_fields_are_rejected_without_partial_state(): void
    {
        $response = $this->postJson('/api/register', [
            'name' => 'Safe User',
            'email' => 'safe@example.com',
            'password' => 'StrongPassword123',
            'password_confirmation' => 'StrongPassword123',
            'is_active' => true,
            'account_status' => AccountStatus::Approved->value,
            'approved_by' => 1,
        ]);

        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['is_active', 'account_status', 'approved_by']);
        $this->assertDatabaseCount('users', 0);
        $this->assertDatabaseCount('personal_access_tokens', 0);
    }
}
