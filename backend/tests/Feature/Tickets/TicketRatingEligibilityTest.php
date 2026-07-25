<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TicketRatingEligibilityTest extends TestCase
{
    use RefreshDatabase;

    public function test_every_non_completed_status_is_rejected_without_workflow_change(): void
    {
        $reporter = User::factory()->create();
        foreach ([Ticket::STATUS_NEW, Ticket::STATUS_ASSIGNED, Ticket::STATUS_IN_PROGRESS, Ticket::STATUS_REJECTED] as $status) {
            $ticket = Ticket::factory()->for($reporter, 'reporter')->create(['status' => $status]);
            $original = $ticket->only(['status', 'updated_at', 'assigned_technician_id']);
            $this->actingAs($reporter)->postJson("/api/reporter/tickets/{$ticket->reference}/rating", ['rating' => 4, 'submission_token' => fake()->uuid()])
                ->assertConflict()->assertJsonPath('code', 'TICKET_NOT_COMPLETED');
            $this->assertEquals($original, $ticket->fresh()->only(array_keys($original)));
        }
        $this->assertDatabaseCount('ticket_ratings', 0);
    }
}
