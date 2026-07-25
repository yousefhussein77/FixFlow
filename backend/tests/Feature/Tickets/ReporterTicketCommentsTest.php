<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ReporterTicketCommentsTest extends TestCase
{
    use RefreshDatabase;

    public function test_reporter_lists_and_adds_plain_text_only_on_owned_ticket(): void
    {
        $reporter = User::factory()->create();
        $owned = Ticket::factory()->for($reporter, 'reporter')->create();
        $other = Ticket::factory()->create();
        $url = "/api/reporter/tickets/{$owned->reference}/comments";

        $this->actingAs($reporter)->getJson($url)->assertOk()->assertJsonPath('data', []);
        $this->actingAs($reporter)->postJson($url, ['content' => "  <b>Line</b>\nTwo  ", 'submission_token' => fake()->uuid()])
            ->assertCreated()->assertJsonPath('data.content', "<b>Line</b>\nTwo")->assertJsonPath('data.author.id', $reporter->id);
        $hidden = $this->actingAs($reporter)->getJson("/api/reporter/tickets/{$other->reference}/comments");
        $unknown = $this->actingAs($reporter)->getJson('/api/reporter/tickets/UNKNOWN/comments');
        $this->assertSame($hidden->getContent(), $unknown->getContent());
    }

    public function test_comment_validation_creates_nothing(): void
    {
        $reporter = User::factory()->create();
        $ticket = Ticket::factory()->for($reporter, 'reporter')->create();
        $url = "/api/reporter/tickets/{$ticket->reference}/comments";
        foreach ([['content' => ' ', 'submission_token' => fake()->uuid()], ['content' => str_repeat('x', 2001), 'submission_token' => fake()->uuid()], ['content' => 'ok', 'submission_token' => 'bad'], ['content' => 'ok', 'submission_token' => fake()->uuid(), 'author_id' => 99]] as $payload) {
            $this->actingAs($reporter)->postJson($url, $payload)->assertUnprocessable();
        }
        $this->assertDatabaseCount('ticket_comments', 0);
    }
}
