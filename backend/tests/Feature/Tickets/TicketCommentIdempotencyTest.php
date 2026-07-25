<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class TicketCommentIdempotencyTest extends TestCase
{
    use RefreshDatabase;

    public function test_same_token_replays_and_distinct_token_creates_distinct_comment(): void
    {
        $reporter = User::factory()->create();
        $ticket = Ticket::factory()->for($reporter, 'reporter')->create();
        $url = "/api/reporter/tickets/{$ticket->reference}/comments";
        $token = fake()->uuid();
        $first = $this->actingAs($reporter)->postJson($url, ['content' => 'Same', 'submission_token' => $token])->assertCreated();
        $replay = $this->actingAs($reporter)->postJson($url, ['content' => 'Changed retry text', 'submission_token' => $token])->assertOk();
        $this->assertSame($first->json('data.id'), $replay->json('data.id'));
        $this->assertSame('Same', $replay->json('data.content'));
        $this->actingAs($reporter)->postJson($url, ['content' => 'Same', 'submission_token' => fake()->uuid()])->assertCreated();
        $this->assertDatabaseCount('ticket_comments', 2);
    }

    public function test_persistence_failure_rolls_back_without_mutating_ticket(): void
    {
        $reporter = User::factory()->create();
        $ticket = Ticket::factory()->for($reporter, 'reporter')->create();
        $original = $ticket->only(['reporter_id', 'title', 'description', 'priority', 'location', 'status', 'updated_at']);

        DB::statement("CREATE TRIGGER reject_ticket_comment BEFORE INSERT ON ticket_comments BEGIN SELECT RAISE(ABORT, 'injected failure'); END");

        try {
            $this->actingAs($reporter)->postJson(
                "/api/reporter/tickets/{$ticket->reference}/comments",
                ['content' => 'Must roll back', 'submission_token' => fake()->uuid()],
            )->assertStatus(500)->assertJsonPath('message', 'An unexpected server error occurred.');
        } finally {
            DB::statement('DROP TRIGGER IF EXISTS reject_ticket_comment');
        }

        $this->assertDatabaseCount('ticket_comments', 0);
        $this->assertEquals($original, $ticket->fresh()->only(array_keys($original)));
    }
}
