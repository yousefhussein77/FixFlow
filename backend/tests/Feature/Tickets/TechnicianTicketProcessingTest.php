<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\TicketStatusHistory;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TechnicianTicketProcessingTest extends TestCase
{
    use RefreshDatabase;

    public function test_technician_lists_and_opens_only_owned_assigned_tickets(): void
    {
        $technician = User::factory()->technician()->create();
        $other = User::factory()->technician()->create();
        $owned = Ticket::factory()->assigned($technician)->create();
        Ticket::factory()->assigned($other)->create();

        $this->actingAs($technician)->getJson('/api/technician/tickets')->assertOk()->assertJsonCount(1, 'data')->assertJsonPath('data.0.reference', $owned->reference);
        $this->actingAs($technician)->getJson('/api/technician/tickets/'.$owned->reference)->assertOk()->assertJsonPath('data.reference', $owned->reference);
        $this->actingAs($technician)->getJson('/api/technician/tickets/'.Ticket::firstWhere('assigned_technician_id', $other->id)->reference)->assertNotFound()->assertJsonPath('code', 'TICKET_NOT_FOUND');
        $this->actingAs($technician)->getJson('/api/technician/tickets/unknown')->assertNotFound()->assertJsonPath('code', 'TICKET_NOT_FOUND');
    }

    public function test_only_active_technicians_can_access_routes(): void
    {
        $this->getJson('/api/technician/tickets')->assertUnauthorized();
        $this->actingAs(User::factory()->create())->getJson('/api/technician/tickets')->assertForbidden();
        $this->actingAs(User::factory()->administrator()->create())->getJson('/api/technician/tickets')->assertForbidden();
        $this->actingAs(User::factory()->technician()->inactive()->create())->getJson('/api/technician/tickets')->assertUnauthorized();
    }

    public function test_exact_transition_matrix_and_rejection_reason_are_persisted(): void
    {
        $technician = User::factory()->technician()->create();
        $ticket = Ticket::factory()->assigned($technician)->create();

        $this->actingAs($technician)->patchJson("/api/technician/tickets/{$ticket->reference}/status", ['status' => 'in_progress'])->assertOk()->assertJsonPath('data.status', 'in_progress');
        $this->actingAs($technician)->patchJson("/api/technician/tickets/{$ticket->reference}/status", ['status' => 'completed'])->assertOk()->assertJsonPath('data.status', 'completed');
        $this->assertSame(2, TicketStatusHistory::where('ticket_id', $ticket->id)->count());
        $this->actingAs($technician)->patchJson("/api/technician/tickets/{$ticket->reference}/status", ['status' => 'rejected', 'reason' => 'No'])->assertConflict()->assertJsonPath('code', 'STATUS_TRANSITION_CONFLICT');

        $rejected = Ticket::factory()->assigned($technician)->create();
        $this->actingAs($technician)->patchJson("/api/technician/tickets/{$rejected->reference}/status", ['status' => 'rejected', 'reason' => '  Unsafe site  '])->assertOk();
        $this->assertDatabaseHas('ticket_status_histories', ['ticket_id' => $rejected->id, 'from_status' => 'assigned', 'to_status' => 'rejected', 'reason' => 'Unsafe site']);
    }

    public function test_invalid_and_non_owned_transitions_leave_state_unchanged(): void
    {
        $technician = User::factory()->technician()->create();
        $ticket = Ticket::factory()->assigned($technician)->create();
        $other = Ticket::factory()->assigned(User::factory()->technician()->create())->create();

        $this->actingAs($technician)->patchJson("/api/technician/tickets/{$ticket->reference}/status", ['status' => 'rejected', 'reason' => '   '])->assertUnprocessable();
        $this->actingAs($technician)->patchJson("/api/technician/tickets/{$ticket->reference}/status", ['status' => 'completed'])->assertConflict();
        $this->actingAs($technician)->patchJson("/api/technician/tickets/{$other->reference}/status", ['status' => 'in_progress'])->assertNotFound();
        $this->assertSame('assigned', $ticket->fresh()->status);
        $this->assertDatabaseCount('ticket_status_histories', 0);
    }

    public function test_history_is_immutable(): void
    {
        $history = TicketStatusHistory::factory()->create();
        $this->expectException(\LogicException::class);
        $history->update(['reason' => 'changed']);
    }
}
