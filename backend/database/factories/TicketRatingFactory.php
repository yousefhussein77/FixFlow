<?php

namespace Database\Factories;

use App\Models\Ticket;
use App\Models\TicketRating;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/** @extends Factory<TicketRating> */
class TicketRatingFactory extends Factory
{
    public function definition(): array
    {
        $reporter = User::factory();

        return [
            'ticket_id' => Ticket::factory()->completed()->for($reporter, 'reporter'),
            'reporter_id' => $reporter,
            'submission_token' => fake()->uuid(),
            'value' => fake()->numberBetween(1, 5),
            'created_at' => now(),
        ];
    }
}
