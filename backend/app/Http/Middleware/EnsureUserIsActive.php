<?php

namespace App\Http\Middleware;

use App\Support\ApiResponse;
use App\Support\AuthEvent;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsActive
{
    public function handle(Request $request, Closure $next): Response
    {
        if (! $request->user()?->is_active) {
            AuthEvent::record('auth.protected_operation', 'inactive_denied', $request->user()?->id);

            return ApiResponse::error(
                message: 'Authentication required.',
                code: 'UNAUTHENTICATED',
                status: 401,
            );
        }

        return $next($request);
    }
}
