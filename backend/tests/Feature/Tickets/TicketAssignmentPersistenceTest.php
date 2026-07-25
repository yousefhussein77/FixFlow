<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\TicketStatusHistory;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use LogicException;
use Tests\TestCase;

class TicketAssignmentPersistenceTest extends TestCase
{
    use RefreshDatabase;

    public function test_assigned_ticket_and_history_relationships_are_reproducible_and_history_is_immutable(): void
    {
        $technician = User::factory()->technician()->create();
        $ticket = Ticket::factory()->assigned($technician)->create();
        $history = TicketStatusHistory::factory()->create(['ticket_id' => $ticket->id, 'assigned_technician_id' => $technician->id]);
        $this->assertTrue($ticket->assignedTechnician->is($technician));
        $this->assertTrue($ticket->statusHistories->first()->is($history));
        $this->expectException(LogicException::class);
        $history->update(['to_status' => 'changed']);
    }
}
