<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TicketCommentAssignmentRaceTest extends TestCase
{
    use RefreshDatabase;

    public function test_former_assignee_is_concealed_and_cannot_replay(): void
    {
        $technician = User::factory()->technician()->create();
        $ticket = Ticket::factory()->assigned($technician)->create();
        $url = "/api/technician/tickets/{$ticket->reference}/comments";
        $token = fake()->uuid();
        $this->actingAs($technician)->postJson($url, ['content' => 'Before', 'submission_token' => $token])->assertCreated();
        $ticket->forceFill(['assigned_technician_id' => User::factory()->technician()->create()->id])->save();
        $this->actingAs($technician)->postJson($url, ['content' => 'Before', 'submission_token' => $token])->assertNotFound();
        $this->assertDatabaseCount('ticket_comments', 1);
    }
}
