<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TechnicianTicketCommentsTest extends TestCase
{
    use RefreshDatabase;

    public function test_only_current_assignee_can_list_and_add(): void
    {
        $technician = User::factory()->technician()->create();
        $assigned = Ticket::factory()->assigned($technician)->create();
        $other = Ticket::factory()->assigned(User::factory()->technician()->create())->create();
        $url = "/api/technician/tickets/{$assigned->reference}/comments";
        $this->actingAs($technician)->postJson($url, ['content' => 'Work note', 'submission_token' => fake()->uuid()])
            ->assertCreated()->assertJsonPath('data.author.role', User::ROLE_TECHNICIAN);
        $this->actingAs($technician)->getJson($url)->assertOk()->assertJsonCount(1, 'data');
        $this->actingAs($technician)->getJson("/api/technician/tickets/{$other->reference}/comments")->assertNotFound();
    }
}
