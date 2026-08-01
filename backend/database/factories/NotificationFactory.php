<?php

namespace Database\Factories;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/** @extends Factory<Notification> */
class NotificationFactory extends Factory
{
    protected $model = Notification::class;

    public function definition(): array
    {
        return [
            'recipient_user_id' => User::factory(),
            'type' => 'ticket.status_changed',
            'title' => 'تحديث تذكرة',
            'message' => 'تغيرت حالة إحدى التذاكر.',
            'related_entity_type' => 'ticket',
            'related_entity_id' => fake()->numberBetween(1, 1000),
            'navigation_target' => 'reporter.ticket',
            'payload' => ['ticket_reference' => 'TKT-EXAMPLE'],
            'deduplication_key' => fake()->uuid(),
            'read_at' => null,
        ];
    }
}
