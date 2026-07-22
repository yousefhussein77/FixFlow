<?php

namespace Database\Factories;

use App\Models\Category;
use App\Models\Department;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/** @extends Factory<Category> */
class CategoryFactory extends Factory
{
    public function definition(): array
    {
        $name = fake()->unique()->word();

        return ['department_id' => Department::factory(), 'name' => $name, 'normalized_name' => Str::lower(trim($name)), 'is_active' => true, 'version' => 1];
    }

    public function inactive(): static
    {
        return $this->state(fn () => ['is_active' => false]);
    }
}
