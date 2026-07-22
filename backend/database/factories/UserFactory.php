<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/** @extends Factory<User> */
class UserFactory extends Factory
{
    protected static ?string $password;

    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'password' => static::$password ??= Hash::make('Password1234'),
            'role' => User::ROLE_REPORTER,
            'is_active' => true,
            'remember_token' => Str::random(10),
        ];
    }

    public function inactive(): static
    {
        return $this->state(fn (): array => ['is_active' => false]);
    }

    public function technician(): static
    {
        return $this->state(fn (): array => ['role' => User::ROLE_TECHNICIAN]);
    }

    public function administrator(): static
    {
        return $this->state(fn (): array => ['role' => User::ROLE_ADMINISTRATOR]);
    }
}
