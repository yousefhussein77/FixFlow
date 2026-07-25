<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TechnicianListTicketsTest extends TestCase
{
    use RefreshDatabase;

    public function test_list_counts_only_current_technicians_assignments_and_validates_pages(): void
    {
        $technician = User::factory()->technician()->create();
        Ticket::factory()->count(2)->assigned($technician)->create();
        Ticket::factory()->assigned(User::factory()->technician()->create())->create();
        $this->actingAs($technician)->getJson('/api/technician/tickets?per_page=1')->assertOk()->assertJsonPath('meta.total', 2)->assertJsonCount(1, 'data');
        $this->actingAs($technician)->getJson('/api/technician/tickets?page=0')->assertUnprocessable();
    }
}
