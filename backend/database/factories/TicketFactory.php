<?php

namespace Database\Factories;

use App\Models\Category;
use App\Models\Department;
use App\Models\Ticket;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/** @extends Factory<Ticket> */
class TicketFactory extends Factory
{
    public function definition(): array
    {
        $department = Department::factory();

        return ['reference' => 'TKT-'.Str::upper(Str::random(12)), 'reporter_id' => User::factory(), 'department_id' => $department, 'category_id' => Category::factory()->state(fn () => ['department_id' => $department]), 'submission_token' => fake()->uuid(), 'title' => fake()->sentence(4), 'description' => fake()->paragraph(), 'priority' => fake()->randomElement(Ticket::PRIORITIES), 'location' => fake()->streetAddress(), 'status' => Ticket::STATUS_NEW];
    }
}
