<?php

namespace Database\Factories;

use App\Enums\AccountStatus;
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
            'account_status' => AccountStatus::Approved,
            'remember_token' => Str::random(10),
        ];
    }

    public function inactive(): static
    {
        return $this->state(fn (): array => [
            'is_active' => false,
            'account_status' => AccountStatus::Inactive,
        ]);
    }

    public function pending(): static
    {
        return $this->state(fn (): array => [
            'is_active' => false,
            'account_status' => AccountStatus::Pending,
        ]);
    }

    public function rejected(): static
    {
        return $this->state(fn (): array => [
            'is_active' => false,
            'account_status' => AccountStatus::Rejected,
            'rejected_at' => now(),
        ]);
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
