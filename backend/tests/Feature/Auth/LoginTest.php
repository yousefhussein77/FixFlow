<?php

namespace Tests\Feature\Auth;

use App\Enums\AccountStatus;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LoginTest extends TestCase
{
    use RefreshDatabase;

    public function test_approved_active_user_signs_in_with_normalized_email(): void
    {
        $user = User::factory()->create([
            'email' => 'active@example.com',
            'password' => 'StrongPassword123',
        ]);

        $response = $this->postJson('/api/login', [
            'email' => ' ACTIVE@Example.COM ',
            'password' => 'StrongPassword123',
        ]);

        $response->assertOk()
            ->assertJsonPath('data.user.id', $user->id)
            ->assertJsonPath('data.user.account_status', AccountStatus::Approved->value)
            ->assertJsonStructure(['data' => ['token']]);
        $this->assertDatabaseCount('personal_access_tokens', 1);
    }

    public function test_pending_rejected_and_inactive_accounts_receive_safe_distinct_failures(): void
    {
        $accounts = [
            [User::factory()->pending()->create(['password' => 'StrongPassword123']), 'ACCOUNT_PENDING'],
            [User::factory()->rejected()->create(['password' => 'StrongPassword123']), 'ACCOUNT_REJECTED'],
            [User::factory()->inactive()->create(['password' => 'StrongPassword123']), 'ACCOUNT_INACTIVE'],
        ];

        foreach ($accounts as [$user, $code]) {
            $this->postJson('/api/login', [
                'email' => $user->email,
                'password' => 'StrongPassword123',
            ])->assertForbidden()->assertJsonPath('code', $code);
        }

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_unknown_email_and_wrong_password_remain_generic(): void
    {
        User::factory()->create(['email' => 'active@example.com', 'password' => 'StrongPassword123']);

        foreach ([
            ['missing@example.com', 'StrongPassword123'],
            ['active@example.com', 'WrongPassword123'],
        ] as [$email, $password]) {
            $this->postJson('/api/login', compact('email', 'password'))
                ->assertUnauthorized()
                ->assertJsonPath('code', 'INVALID_CREDENTIALS')
                ->assertJsonPath('message', 'بيانات تسجيل الدخول غير صحيحة.');
        }
    }

    public function test_pending_user_with_a_preexisting_token_cannot_bypass_protected_middleware(): void
    {
        $user = User::factory()->pending()->create();
        $token = $user->createToken('unexpected')->plainTextToken;

        $this->withToken($token)->getJson('/api/profile')
            ->assertUnauthorized()
            ->assertJsonPath('code', 'ACCOUNT_NOT_APPROVED');
    }

    public function test_login_rejects_unexpected_fields(): void
    {
        $this->postJson('/api/login', [
            'email' => 'someone@example.com',
            'password' => 'StrongPassword123',
            'account_status' => AccountStatus::Approved->value,
        ])->assertUnprocessable()->assertJsonValidationErrors('account_status');
    }
}
