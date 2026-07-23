<?php

namespace App\Http\Middleware;

use App\Models\User;
use App\Support\ApiResponse;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsReporter
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user() && ! $request->user()->is_active) {
            return ApiResponse::error('Authentication required.', 'UNAUTHENTICATED', 401);
        }

        if ($request->user()?->role !== User::ROLE_REPORTER) {
            return ApiResponse::error('You are not authorized to perform this operation.', 'FORBIDDEN', 403);
        }

        return $next($request);
    }
}
