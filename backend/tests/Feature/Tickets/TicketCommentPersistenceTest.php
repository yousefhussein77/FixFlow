<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\TicketComment;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use LogicException;
use Tests\TestCase;

class TicketCommentPersistenceTest extends TestCase
{
    use RefreshDatabase;

    public function test_comments_are_related_ordered_and_immutable(): void
    {
        $reporter = User::factory()->create();
        $ticket = Ticket::factory()->for($reporter, 'reporter')->create();
        $later = TicketComment::factory()->create(['ticket_id' => $ticket->id, 'author_id' => $reporter->id, 'created_at' => now()->addSecond()]);
        $earlier = TicketComment::factory()->create(['ticket_id' => $ticket->id, 'author_id' => $reporter->id, 'created_at' => now()]);
        $this->assertSame([$earlier->id, $later->id], $ticket->comments()->pluck('id')->all());
        $this->expectException(LogicException::class);
        $earlier->update(['content' => 'changed']);
    }
}
