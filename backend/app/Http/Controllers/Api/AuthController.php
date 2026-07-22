<?php

namespace App\Http\Controllers\Api;

use App\Actions\Auth\LoginUser;
use App\Actions\Auth\LogoutUser;
use App\Actions\Auth\RegisterReporter;
use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function register(RegisterRequest $request, RegisterReporter $register): JsonResponse
    {
        $session = $register->execute($request->validated());

        return ApiResponse::success(
            message: 'Reporter account created.',
            data: [
                'user' => new UserResource($session['user']),
                'token' => $session['token'],
            ],
            status: 201,
        );
    }

    public function login(LoginRequest $request, LoginUser $login): JsonResponse
    {
        $session = $login->execute($request->validated());
        if ($session instanceof JsonResponse) {
            return $session;
        }

        return ApiResponse::success('Signed in successfully.', [
            'user' => new UserResource($session['user']),
            'token' => $session['token'],
        ]);
    }

    public function profile(Request $request): JsonResponse
    {
        return ApiResponse::success(
            'Profile retrieved.',
            new UserResource($request->user()),
        );
    }

    public function logout(Request $request, LogoutUser $logout): JsonResponse
    {
        $logout->execute($request->user());

        return ApiResponse::success('Signed out successfully.');
    }
}
