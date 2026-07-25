<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class TicketRatingIdempotencyTest extends TestCase
{
    use RefreshDatabase;

    public function test_same_token_replays_and_distinct_token_conflicts_unchanged(): void
    {
        $reporter = User::factory()->create();
        $ticket = Ticket::factory()->completed()->for($reporter, 'reporter')->create();
        $url = "/api/reporter/tickets/{$ticket->reference}/rating";
        $token = fake()->uuid();
        $first = $this->actingAs($reporter)->postJson($url, ['rating' => 4, 'submission_token' => $token])->assertCreated();
        $replay = $this->actingAs($reporter)->postJson($url, ['rating' => 1, 'submission_token' => $token])->assertOk();
        $this->assertSame($first->json('data'), $replay->json('data'));
        $this->actingAs($reporter)->postJson($url, ['rating' => 2, 'submission_token' => fake()->uuid()])->assertConflict()->assertJsonPath('code', 'RATING_ALREADY_EXISTS');
        $this->assertDatabaseHas('ticket_ratings', ['ticket_id' => $ticket->id, 'value' => 4]);
        $this->assertDatabaseCount('ticket_ratings', 1);
    }

    public function test_persistence_failure_rolls_back(): void
    {
        $reporter = User::factory()->create();
        $ticket = Ticket::factory()->completed()->for($reporter, 'reporter')->create();
        DB::statement("CREATE TRIGGER reject_ticket_rating BEFORE INSERT ON ticket_ratings BEGIN SELECT RAISE(ABORT, 'injected failure'); END");
        try {
            $this->actingAs($reporter)->postJson("/api/reporter/tickets/{$ticket->reference}/rating", ['rating' => 3, 'submission_token' => fake()->uuid()])->assertStatus(500);
        } finally {
            DB::statement('DROP TRIGGER IF EXISTS reject_ticket_rating');
        }
        $this->assertDatabaseCount('ticket_ratings', 0);
        $this->assertSame(Ticket::STATUS_COMPLETED, $ticket->fresh()->status);
    }
}
