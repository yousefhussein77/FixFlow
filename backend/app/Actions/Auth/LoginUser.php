<?php

namespace App\Actions\Auth;

use App\Models\User;
use App\Support\ApiResponse;
use App\Support\AuthEvent;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;

class LoginUser
{
    /** @return array{user: User, token: string}|JsonResponse */
    public function execute(array $credentials): array|JsonResponse
    {
        $user = User::query()->where('email', $credentials['email'])->first();
        $hash = $user?->password ?? Hash::make('invalid-credential-placeholder');
        $passwordMatches = Hash::check($credentials['password'], $hash);

        if (! $user || ! $passwordMatches || ! $user->is_active) {
            AuthEvent::record('auth.login', 'denied');

            return ApiResponse::error(
                message: 'The provided credentials are invalid.',
                code: 'INVALID_CREDENTIALS',
                status: 401,
            );
        }

        AuthEvent::record('auth.login', 'success', $user->id);

        return [
            'user' => $user,
            'token' => $user->createToken('fixflow-mobile')->plainTextToken,
        ];
    }
}
