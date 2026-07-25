<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Route;
use Tests\TestCase;

class TicketRatingAuthorizationTest extends TestCase
{
    use RefreshDatabase;

    public function test_non_owner_is_concealed_and_roles_are_rejected_first(): void
    {
        $owner = User::factory()->create();
        $other = User::factory()->create();
        $ticket = Ticket::factory()->completed()->for($owner, 'reporter')->create();
        $payload = ['rating' => 5, 'submission_token' => fake()->uuid()];
        $unknown = $this->actingAs($other)->postJson('/api/reporter/tickets/TKT-UNKNOWN/rating', $payload)->assertNotFound();
        $hidden = $this->actingAs($other)->postJson("/api/reporter/tickets/{$ticket->reference}/rating", $payload)->assertNotFound();
        $this->assertSame($unknown->json(), $hidden->json());
        $this->actingAs(User::factory()->technician()->create())->postJson("/api/reporter/tickets/{$ticket->reference}/rating", $payload)->assertForbidden();
        $this->actingAs(User::factory()->administrator()->create())->postJson("/api/reporter/tickets/{$ticket->reference}/rating", $payload)->assertForbidden();
        $ratingRoutes = collect(Route::getRoutes()->getRoutes())->filter(fn ($route) => str_ends_with($route->uri(), '/rating'));
        $this->assertCount(1, $ratingRoutes);
        $this->assertContains('POST', $ratingRoutes->first()->methods());
        $this->assertDatabaseCount('ticket_ratings', 0);
    }
}
