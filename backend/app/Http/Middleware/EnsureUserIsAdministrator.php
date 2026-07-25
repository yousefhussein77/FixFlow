<?php

namespace App\Http\Middleware;

use App\Models\User;
use App\Support\ApiResponse;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsAdministrator
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user()?->role !== User::ROLE_ADMINISTRATOR) {
            return ApiResponse::error('You are not authorized to perform this operation.', 'FORBIDDEN', 403);
        }

        return $next($request);
    }
}
