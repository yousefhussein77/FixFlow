<?php

namespace Tests\Feature\Accounts;

use App\Enums\AccountStatus;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class AccountRequestAdministrationTest extends TestCase
{
    use RefreshDatabase;

    public function test_only_administrators_can_list_account_requests(): void
    {
        $pending = User::factory()->pending()->create();
        $administrator = User::factory()->administrator()->create();
        $reporter = User::factory()->create();

        $this->getJson('/api/admin/account-requests')->assertUnauthorized();

        $this->actingAs($administrator)->getJson('/api/admin/account-requests')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $pending->id)
            ->assertJsonPath('data.0.status', AccountStatus::Pending->value)
            ->assertJsonMissingPath('data.0.password');

        $this->actingAs($reporter)->getJson('/api/admin/account-requests')->assertForbidden();
    }

    public function test_administrator_can_filter_pending_approved_and_rejected_requests(): void
    {
        $administrator = User::factory()->administrator()->create();
        User::factory()->pending()->create();
        User::factory()->rejected()->create();

        $this->actingAs($administrator)->getJson('/api/admin/account-requests?status=rejected')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.status', AccountStatus::Rejected->value);

        $this->actingAs($administrator)->getJson('/api/admin/account-requests?status=unsupported')
            ->assertUnprocessable();
    }

    public function test_administrator_approves_pending_request_with_auditable_fields(): void
    {
        $administrator = User::factory()->administrator()->create();
        $pending = User::factory()->pending()->technician()->create();

        $this->actingAs($administrator)
            ->patchJson("/api/admin/account-requests/{$pending->id}/approve")
            ->assertOk()
            ->assertJsonPath('data.status', AccountStatus::Approved->value)
            ->assertJsonPath('data.approved_by.id', $administrator->id);

        $pending->refresh();
        $this->assertTrue($pending->is_active);
        $this->assertSame(AccountStatus::Approved, $pending->account_status);
        $this->assertSame($administrator->id, $pending->approved_by);
        $this->assertNotNull($pending->approved_at);
        $this->assertNull($pending->rejected_at);
    }

    public function test_administrator_rejects_pending_request_with_optional_normalized_reason(): void
    {
        $administrator = User::factory()->administrator()->create();
        $pending = User::factory()->pending()->create();

        $this->actingAs($administrator)
            ->patchJson("/api/admin/account-requests/{$pending->id}/reject", [
                'rejection_reason' => '  البيانات   غير مكتملة  ',
            ])
            ->assertOk()
            ->assertJsonPath('data.status', AccountStatus::Rejected->value)
            ->assertJsonPath('data.rejection_reason', 'البيانات غير مكتملة')
            ->assertJsonPath('data.rejected_by.id', $administrator->id);

        $this->assertDatabaseHas('users', [
            'id' => $pending->id,
            'is_active' => false,
            'account_status' => AccountStatus::Rejected->value,
            'rejected_by' => $administrator->id,
            'rejection_reason' => 'البيانات غير مكتملة',
        ]);
    }

    public function test_non_administrator_cannot_approve_or_reject_and_data_is_unchanged(): void
    {
        $reporter = User::factory()->create();
        $pending = User::factory()->pending()->create();

        $this->actingAs($reporter)
            ->patchJson("/api/admin/account-requests/{$pending->id}/approve")
            ->assertForbidden();
        $this->actingAs($reporter)
            ->patchJson("/api/admin/account-requests/{$pending->id}/reject")
            ->assertForbidden();

        $pending->refresh();
        $this->assertSame(AccountStatus::Pending, $pending->account_status);
        $this->assertNull($pending->approved_by);
        $this->assertNull($pending->rejected_by);
    }

    public function test_repeated_or_competing_decisions_conflict_without_overwriting_original_audit(): void
    {
        $administrator = User::factory()->administrator()->create();
        $otherAdministrator = User::factory()->administrator()->create();
        $pending = User::factory()->pending()->create();

        $this->actingAs($administrator)
            ->patchJson("/api/admin/account-requests/{$pending->id}/approve")
            ->assertOk();
        $approvedAt = $pending->fresh()->approved_at;

        $this->actingAs($otherAdministrator)
            ->patchJson("/api/admin/account-requests/{$pending->id}/approve")
            ->assertConflict()
            ->assertJsonPath('code', 'ACCOUNT_REQUEST_NOT_PENDING');
        $this->actingAs($otherAdministrator)
            ->patchJson("/api/admin/account-requests/{$pending->id}/reject", [
                'rejection_reason' => 'Should not persist',
            ])
            ->assertConflict();

        $pending->refresh();
        $this->assertSame($administrator->id, $pending->approved_by);
        $this->assertEquals($approvedAt, $pending->approved_at);
        $this->assertNull($pending->rejected_by);
        $this->assertNull($pending->rejection_reason);
    }

    public function test_invalid_decision_payloads_do_not_change_pending_account(): void
    {
        $administrator = User::factory()->administrator()->create();
        $pending = User::factory()->pending()->create();

        $this->actingAs($administrator)
            ->patchJson("/api/admin/account-requests/{$pending->id}/approve", ['role' => 'administrator'])
            ->assertUnprocessable();
        $this->actingAs($administrator)
            ->patchJson("/api/admin/account-requests/{$pending->id}/reject", [
                'rejection_reason' => str_repeat('x', 1001),
            ])
            ->assertUnprocessable();

        $pending->refresh();
        $this->assertSame(AccountStatus::Pending, $pending->account_status);
        $this->assertFalse($pending->is_active);
    }

    public function test_administrator_role_records_are_not_public_account_requests_or_approvable(): void
    {
        $administrator = User::factory()->administrator()->create();
        $invalidRequest = User::factory()->pending()->administrator()->create();

        $this->actingAs($administrator)
            ->getJson('/api/admin/account-requests?status=pending')
            ->assertOk()
            ->assertJsonCount(0, 'data');

        $this->actingAs($administrator)
            ->patchJson("/api/admin/account-requests/{$invalidRequest->id}/approve")
            ->assertNotFound()
            ->assertJsonPath('code', 'ACCOUNT_REQUEST_NOT_FOUND');

        $this->actingAs($administrator)
            ->patchJson('/api/admin/account-requests/999999/reject')
            ->assertNotFound()
            ->assertJsonPath('code', 'ACCOUNT_REQUEST_NOT_FOUND');

        $invalidRequest->refresh();
        $this->assertSame(AccountStatus::Pending, $invalidRequest->account_status);
        $this->assertFalse($invalidRequest->is_active);
        $this->assertNull($invalidRequest->approved_by);
    }

    public function test_rejection_rolls_back_when_token_revocation_fails(): void
    {
        $administrator = User::factory()->administrator()->create();
        $pending = User::factory()->pending()->create();
        $pending->createToken('legacy-token');

        DB::statement(<<<'SQL'
            CREATE TRIGGER prevent_account_token_delete
            BEFORE DELETE ON personal_access_tokens
            BEGIN
                SELECT RAISE(ABORT, 'simulated token revocation failure');
            END
            SQL);

        try {
            $this->withoutExceptionHandling()
                ->actingAs($administrator)
                ->patchJson("/api/admin/account-requests/{$pending->id}/reject")
                ->assertStatus(500);
        } catch (QueryException) {
            // The exception proves the failure occurred after the user update.
        } finally {
            DB::statement('DROP TRIGGER IF EXISTS prevent_account_token_delete');
        }

        $pending->refresh();
        $this->assertSame(AccountStatus::Pending, $pending->account_status);
        $this->assertFalse($pending->is_active);
        $this->assertNull($pending->rejected_by);
        $this->assertNull($pending->rejected_at);
        $this->assertDatabaseCount('personal_access_tokens', 1);
    }
}
