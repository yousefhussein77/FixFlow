<?php

namespace Database\Factories;

use App\Models\Ticket;
use App\Models\TicketStatusHistory;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/** @extends Factory<TicketStatusHistory> */
class TicketStatusHistoryFactory extends Factory
{
    public function definition(): array
    {
        return [
            'ticket_id' => Ticket::factory(),
            'from_status' => Ticket::STATUS_NEW,
            'to_status' => Ticket::STATUS_ASSIGNED,
            'actor_id' => User::factory()->administrator(),
            'assigned_technician_id' => User::factory()->technician(),
            'reason' => null,
            'occurred_at' => now(),
        ];
    }
}
