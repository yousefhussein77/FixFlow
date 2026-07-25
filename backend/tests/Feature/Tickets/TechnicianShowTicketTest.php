<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TechnicianShowTicketTest extends TestCase
{
    use RefreshDatabase;

    public function test_non_owned_and_unknown_details_are_identically_concealed(): void
    {
        $technician = User::factory()->technician()->create();
        $other = Ticket::factory()->assigned(User::factory()->technician()->create())->create();
        $unknown = $this->actingAs($technician)->getJson('/api/technician/tickets/UNKNOWN');
        $hidden = $this->actingAs($technician)->getJson('/api/technician/tickets/'.$other->reference);
        $this->assertSame($unknown->getContent(), $hidden->getContent());
    }

    public function test_owned_detail_uses_the_approved_status_history_key(): void
    {
        $technician = User::factory()->technician()->create();
        $ticket = Ticket::factory()->assigned($technician)->create();

        $this->actingAs($technician)->getJson('/api/technician/tickets/'.$ticket->reference)
            ->assertOk()
            ->assertJsonPath('data.status_history', [])
            ->assertJsonMissingPath('data.history');
    }
}
