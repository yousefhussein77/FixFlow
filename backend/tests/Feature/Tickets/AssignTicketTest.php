<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\TicketStatusHistory;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use RuntimeException;
use Tests\TestCase;

class AssignTicketTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_assigns_new_ticket_and_records_exact_history(): void
    {
        $admin = User::factory()->administrator()->create();
        $technician = User::factory()->technician()->create();
        $ticket = Ticket::factory()->create();
        $this->withToken($admin->createToken('t')->plainTextToken)->patchJson("/api/admin/tickets/{$ticket->reference}/assignment", ['technician_id' => $technician->id])
            ->assertOk()->assertJsonPath('data.status', 'assigned')->assertJsonPath('data.assigned_technician.id', $technician->id);
        $this->assertDatabaseHas('tickets', ['id' => $ticket->id, 'status' => 'assigned', 'assigned_technician_id' => $technician->id]);
        $this->assertDatabaseHas('ticket_status_histories', ['ticket_id' => $ticket->id, 'from_status' => 'new', 'to_status' => 'assigned', 'actor_id' => $admin->id, 'assigned_technician_id' => $technician->id]);
        $this->assertDatabaseCount('ticket_status_histories', 1);
    }

    public function test_ineligible_technicians_are_rejected_without_change(): void
    {
        $admin = User::factory()->administrator()->create();
        $ticket = Ticket::factory()->create();
        foreach ([999999, User::factory()->technician()->inactive()->create()->id, User::factory()->create()->id] as $id) {
            $this->withToken($admin->createToken("t$id")->plainTextToken)->patchJson("/api/admin/tickets/{$ticket->reference}/assignment", ['technician_id' => $id])->assertUnprocessable()->assertJsonValidationErrors('technician_id');
            $this->assertDatabaseHas('tickets', ['id' => $ticket->id, 'status' => 'new', 'assigned_technician_id' => null]);
            $this->assertDatabaseCount('ticket_status_histories', 0);
        }
    }

    public function test_unsupported_assignment_fields_are_rejected_without_change(): void
    {
        $admin = User::factory()->administrator()->create();
        $technician = User::factory()->technician()->create();
        $ticket = Ticket::factory()->create();

        $this->withToken($admin->createToken('extra')->plainTextToken)
            ->patchJson("/api/admin/tickets/{$ticket->reference}/assignment", ['technician_id' => $technician->id, 'status' => 'assigned'])
            ->assertUnprocessable()->assertJsonValidationErrors('status');

        $this->assertDatabaseHas('tickets', ['id' => $ticket->id, 'status' => 'new', 'assigned_technician_id' => null]);
        $this->assertDatabaseCount('ticket_status_histories', 0);
    }

    public function test_second_assignment_is_a_conflict_and_history_stays_single(): void
    {
        $admin = User::factory()->administrator()->create();
        $one = User::factory()->technician()->create();
        $two = User::factory()->technician()->create();
        $ticket = Ticket::factory()->create();
        $token = $admin->createToken('t')->plainTextToken;
        $this->withToken($token)->patchJson("/api/admin/tickets/{$ticket->reference}/assignment", ['technician_id' => $one->id])->assertOk();
        $this->withToken($token)->patchJson("/api/admin/tickets/{$ticket->reference}/assignment", ['technician_id' => $two->id])->assertConflict()->assertJsonPath('code', 'ASSIGNMENT_CONFLICT');
        $this->assertDatabaseHas('tickets', ['id' => $ticket->id, 'assigned_technician_id' => $one->id]);
        $this->assertDatabaseCount('ticket_status_histories', 1);
    }

    public function test_history_failure_rolls_back_ticket_assignment(): void
    {
        $admin = User::factory()->administrator()->create();
        $technician = User::factory()->technician()->create();
        $ticket = Ticket::factory()->create();
        TicketStatusHistory::creating(fn () => throw new RuntimeException('simulated history failure'));

        $this->withToken($admin->createToken('t')->plainTextToken)
            ->patchJson("/api/admin/tickets/{$ticket->reference}/assignment", ['technician_id' => $technician->id])
            ->assertServerError()
            ->assertJsonPath('code', 'SERVER_ERROR');

        $this->assertDatabaseHas('tickets', ['id' => $ticket->id, 'status' => 'new', 'assigned_technician_id' => null]);
        $this->assertDatabaseCount('ticket_status_histories', 0);
    }

    public function test_wrong_actors_reveal_no_ticket_data(): void
    {
        $this->patchJson('/api/admin/tickets/TKT-AAAAAAAAAAAA/assignment', ['technician_id' => 1])->assertUnauthorized();
        $technician = User::factory()->technician()->create();
        $payload = ['technician_id' => $technician->id];
        foreach ([User::factory()->create(), $technician] as $user) {
            $this->withToken($user->createToken('x')->plainTextToken)->patchJson('/api/admin/tickets/TKT-AAAAAAAAAAAA/assignment', $payload)->assertForbidden()->assertJsonPath('data', null);
        }
    }

    public function test_unknown_ticket_is_concealed_from_administrator(): void
    {
        $technician = User::factory()->technician()->create();
        $payload = ['technician_id' => $technician->id];
        $admin = User::factory()->administrator()->create();
        $this->withToken($admin->createToken('a')->plainTextToken)->patchJson('/api/admin/tickets/TKT-AAAAAAAAAAAA/assignment', $payload)->assertNotFound()->assertJsonPath('code', 'TICKET_NOT_FOUND')->assertJsonPath('data', null);
    }
}
