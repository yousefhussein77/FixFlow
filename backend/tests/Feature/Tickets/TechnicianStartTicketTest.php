<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\TicketStatusHistory;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TechnicianStartTicketTest extends TestCase
{
    use RefreshDatabase;

    public function test_start_work_is_atomic_and_duplicate_attempt_conflicts(): void
    {
        $technician = User::factory()->technician()->create();
        $ticket = Ticket::factory()->assigned($technician)->create();
        $url = "/api/technician/tickets/{$ticket->reference}/status";
        $this->actingAs($technician)->patchJson($url, ['status' => 'in_progress'])->assertOk();
        $this->actingAs($technician)->patchJson($url, ['status' => 'in_progress'])->assertConflict();
        $this->assertDatabaseHas('tickets', ['id' => $ticket->id, 'status' => 'in_progress']);
        $this->assertDatabaseCount('ticket_status_histories', 1);
    }

    public function test_history_failure_rolls_back_ticket_status(): void
    {
        $technician = User::factory()->technician()->create();
        $ticket = Ticket::factory()->assigned($technician)->create();
        TicketStatusHistory::creating(fn () => throw new \RuntimeException('Injected failure'));

        $this->actingAs($technician)->patchJson("/api/technician/tickets/{$ticket->reference}/status", ['status' => 'in_progress'])->assertInternalServerError()->assertJsonMissing(['message' => 'Injected failure']);
        $this->assertSame(Ticket::STATUS_ASSIGNED, $ticket->fresh()->status);
        $this->assertDatabaseCount('ticket_status_histories', 0);
    }
}
