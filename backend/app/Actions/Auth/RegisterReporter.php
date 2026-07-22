<?php

namespace App\Actions\Auth;

use App\Models\User;
use App\Support\AuthEvent;
use Illuminate\Support\Facades\DB;

class RegisterReporter
{
    /** @return array{user: User, token: string} */
    public function execute(array $attributes): array
    {
        return DB::transaction(function () use ($attributes): array {
            $user = new User;
            $user->name = $attributes['name'];
            $user->email = $attributes['email'];
            $user->password = $attributes['password'];
            $user->role = User::ROLE_REPORTER;
            $user->is_active = true;
            $user->save();
            AuthEvent::record('auth.registration', 'success', $user->id);

            return [
                'user' => $user,
                'token' => $user->createToken('fixflow-mobile')->plainTextToken,
            ];
        });
    }
}
