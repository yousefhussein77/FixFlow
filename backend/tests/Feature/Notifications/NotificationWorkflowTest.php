<?php

namespace Tests\Feature\Notifications;

use App\Actions\Accounts\ApproveAccountRequest;
use App\Actions\Accounts\RejectAccountRequest;
use App\Actions\Tickets\AssignTicket;
use App\Actions\Tickets\CreateTicket;
use App\Actions\Tickets\CreateTicketComment;
use App\Actions\Tickets\TransitionTicketStatus;
use App\Enums\AccountStatus;
use App\Models\Category;
use App\Models\Department;
use App\Models\Notification;
use App\Models\Ticket;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\TestCase;

class NotificationWorkflowTest extends TestCase
{
    use RefreshDatabase;

    public function test_registration_and_account_decision_create_role_specific_notifications(): void
    {
        $administrator = User::factory()->administrator()->create();

        $this->postJson('/api/register', [
            'name' => 'Pending Reporter',
            'email' => 'pending@example.com',
            'password' => 'StrongPassword123',
            'password_confirmation' => 'StrongPassword123',
        ])->assertCreated();

        $account = User::query()->where('email', 'pending@example.com')->firstOrFail();
        $this->assertDatabaseHas('notifications', [
            'recipient_user_id' => $administrator->id,
            'type' => 'account_request.created',
            'related_entity_id' => $account->id,
        ]);

        app(ApproveAccountRequest::class)->execute($administrator, $account);
        $this->assertDatabaseHas('notifications', [
            'recipient_user_id' => $account->id,
            'type' => 'account_request.approved',
            'navigation_target' => 'account.status',
        ]);
    }

    public function test_ticket_creation_assignment_status_and_comment_emit_expected_notifications(): void
    {
        $administrator = User::factory()->administrator()->create();
        $reporter = User::factory()->create();
        $technician = User::factory()->technician()->create();
        $department = Department::factory()->create();
        $category = Category::factory()->create(['department_id' => $department->id]);

        $ticket = app(CreateTicket::class)->execute($reporter, [
            'department_id' => $department->id,
            'category_id' => $category->id,
            'submission_token' => (string) Str::uuid(),
            'title' => 'Water leak',
            'description' => 'Water is leaking from the ceiling.',
            'priority' => 'high',
            'location' => 'Building A',
            'photos' => [],
        ]);
        $this->assertDatabaseHas('notifications', [
            'recipient_user_id' => $administrator->id,
            'type' => 'ticket.created',
        ]);

        $ticket = app(AssignTicket::class)->execute($administrator, $ticket->reference, $technician->id);
        $this->assertDatabaseHas('notifications', [
            'recipient_user_id' => $technician->id,
            'type' => 'ticket.assigned',
        ]);
        $this->assertDatabaseHas('notifications', [
            'recipient_user_id' => $reporter->id,
            'type' => 'ticket.assigned.reporter',
        ]);

        app(TransitionTicketStatus::class)->execute(
            $technician,
            $ticket->reference,
            Ticket::STATUS_IN_PROGRESS,
            null,
        );
        app(TransitionTicketStatus::class)->execute(
            $technician,
            $ticket->reference,
            Ticket::STATUS_COMPLETED,
            null,
        );
        $this->assertDatabaseHas('notifications', [
            'recipient_user_id' => $reporter->id,
            'type' => 'ticket.completed',
            'navigation_target' => 'reporter.ticket_rating',
        ]);

        $token = (string) Str::uuid();
        $action = app(CreateTicketComment::class);
        $action->execute($reporter, User::ROLE_REPORTER, $ticket->reference, 'Please confirm completion.', $token);
        $action->execute($reporter, User::ROLE_REPORTER, $ticket->reference, 'Please confirm completion.', $token);
        $this->assertDatabaseCount('ticket_comments', 1);
        $this->assertSame(1, Notification::query()
            ->where('recipient_user_id', $technician->id)
            ->where('type', 'ticket.comment_created')
            ->count());
    }

    public function test_failed_transaction_creates_no_notification_and_rolls_back_assignment(): void
    {
        User::factory()->administrator()->create();
        $reporter = User::factory()->create();
        $technician = User::factory()->technician()->create();
        $ticket = Ticket::factory()->create(['reporter_id' => $reporter->id]);

        DB::statement(<<<'SQL'
            CREATE TRIGGER prevent_notification_insert
            BEFORE INSERT ON notifications
            BEGIN
                SELECT RAISE(ABORT, 'simulated notification failure');
            END
            SQL);

        try {
            app(AssignTicket::class)->execute(User::factory()->administrator()->create(), $ticket->reference, $technician->id);
            $this->fail('The simulated notification failure did not abort the transaction.');
        } catch (QueryException) {
            // Expected after the ticket and history writes but before commit.
        } finally {
            DB::statement('DROP TRIGGER IF EXISTS prevent_notification_insert');
        }

        $ticket->refresh();
        $this->assertSame(Ticket::STATUS_NEW, $ticket->status);
        $this->assertNull($ticket->assigned_technician_id);
        $this->assertDatabaseCount('ticket_status_histories', 0);
        $this->assertDatabaseCount('notifications', 0);
    }

    public function test_rejected_account_receives_rejection_notification_without_becoming_active(): void
    {
        $administrator = User::factory()->administrator()->create();
        $account = User::factory()->pending()->create();

        app(RejectAccountRequest::class)
            ->execute($administrator, $account, 'بيانات غير مكتملة');

        $account->refresh();
        $this->assertSame(AccountStatus::Rejected, $account->account_status);
        $this->assertFalse($account->is_active);
        $this->assertDatabaseHas('notifications', [
            'recipient_user_id' => $account->id,
            'type' => 'account_request.rejected',
        ]);
    }
}
