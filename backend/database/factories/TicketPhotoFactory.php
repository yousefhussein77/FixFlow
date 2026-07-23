<?php

namespace Database\Factories;

use App\Models\Ticket;
use App\Models\TicketPhoto;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/** @extends Factory<TicketPhoto> */
class TicketPhotoFactory extends Factory
{
    public function definition(): array
    {
        return ['ticket_id' => Ticket::factory(), 'disk' => 'local', 'path' => 'tickets/'.Str::uuid().'.jpg', 'original_name' => 'photo.jpg', 'mime_type' => 'image/jpeg', 'size' => 1024, 'position' => 0];
    }
}
