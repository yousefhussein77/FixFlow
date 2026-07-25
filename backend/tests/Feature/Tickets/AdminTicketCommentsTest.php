<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminTicketCommentsTest extends TestCase
{
    use RefreshDatabase;

    public function test_administrator_has_oversight_without_ticket_mutation(): void
    {
        $admin = User::factory()->administrator()->create();
        $ticket = Ticket::factory()->create();
        $status = $ticket->status;
        $url = "/api/admin/tickets/{$ticket->reference}/comments";
        $this->actingAs($admin)->postJson($url, ['content' => 'Oversight', 'submission_token' => fake()->uuid()])
            ->assertCreated()->assertJsonPath('data.author.role', User::ROLE_ADMINISTRATOR);
        $this->actingAs($admin)->getJson($url)->assertOk()->assertJsonCount(1, 'data');
        $this->assertSame($status, $ticket->fresh()->status);
    }
}
