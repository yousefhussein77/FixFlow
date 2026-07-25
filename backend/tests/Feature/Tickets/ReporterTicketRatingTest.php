<?php

namespace Tests\Feature\Tickets;

use App\Actions\Tickets\CreateTicketRating;
use App\Models\Ticket;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

class ReporterTicketRatingTest extends TestCase
{
    use RefreshDatabase;

    public function test_reporter_rates_owned_completed_ticket_and_detail_shows_rating(): void
    {
        $reporter = User::factory()->create();
        foreach ([1, 2, 3, 4, 5] as $value) {
            $ticket = Ticket::factory()->completed()->for($reporter, 'reporter')->create();
            $this->actingAs($reporter)->postJson("/api/reporter/tickets/{$ticket->reference}/rating", ['rating' => $value, 'submission_token' => fake()->uuid()])
                ->assertCreated()->assertJsonPath('data.value', $value)->assertJsonMissingPath('data.submission_token');
            $this->actingAs($reporter)->getJson("/api/reporter/tickets/{$ticket->reference}")->assertOk()->assertJsonPath('data.rating.value', $value);
        }
        $this->assertDatabaseCount('ticket_ratings', 5);
    }

    public function test_strict_validation_creates_nothing(): void
    {
        $reporter = User::factory()->create();
        $ticket = Ticket::factory()->completed()->for($reporter, 'reporter')->create();
        foreach ([null, 0, 6, -1, 1.5, '5', true, [], ['x' => 1]] as $value) {
            $this->actingAs($reporter)->postJson("/api/reporter/tickets/{$ticket->reference}/rating", ['rating' => $value, 'submission_token' => fake()->uuid()])->assertUnprocessable();
        }
        $this->actingAs($reporter)->postJson("/api/reporter/tickets/{$ticket->reference}/rating", ['rating' => 5, 'submission_token' => 'bad'])->assertUnprocessable();
        $this->actingAs($reporter)->postJson("/api/reporter/tickets/{$ticket->reference}/rating", ['rating' => 5, 'submission_token' => fake()->uuid(), 'review' => 'no'])->assertUnprocessable();
        $this->assertDatabaseCount('ticket_ratings', 0);
    }

    public function test_internal_action_rejects_invalid_value(): void
    {
        $reporter = User::factory()->create();
        $ticket = Ticket::factory()->completed()->for($reporter, 'reporter')->create();

        try {
            app(CreateTicketRating::class)->execute($reporter, $ticket->reference, 0, fake()->uuid());
            $this->fail('Expected validation failure.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey('rating', $exception->errors());
        }

        $this->assertDatabaseCount('ticket_ratings', 0);
    }
}
