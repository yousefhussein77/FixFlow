<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\TicketRating;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use LogicException;
use Tests\TestCase;

class TicketRatingPersistenceTest extends TestCase
{
    use RefreshDatabase;

    public function test_rating_relationships_are_one_to_one_and_immutable(): void
    {
        $reporter = User::factory()->create();
        $ticket = Ticket::factory()->completed()->for($reporter, 'reporter')->create();
        $rating = TicketRating::factory()->for($ticket)->for($reporter, 'reporter')->create(['value' => 1]);
        $this->assertTrue($ticket->rating->is($rating));
        $this->assertTrue($reporter->ticketRatings->first()->is($rating));
        $this->assertNull($rating->updated_at);
        $this->expectException(LogicException::class);
        $rating->update(['value' => 5]);
    }

    public function test_rating_cannot_be_deleted(): void
    {
        $rating = TicketRating::factory()->create();
        $this->expectException(LogicException::class);
        $rating->delete();
    }

    public function test_database_rejects_values_outside_one_through_five(): void
    {
        $reporter = User::factory()->create();
        $ticket = Ticket::factory()->completed()->for($reporter, 'reporter')->create();
        $this->expectException(QueryException::class);
        TicketRating::query()->insert(['ticket_id' => $ticket->id, 'reporter_id' => $reporter->id, 'submission_token' => fake()->uuid(), 'value' => 6, 'created_at' => now()]);
    }
}
