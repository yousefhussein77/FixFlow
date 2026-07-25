<?php

namespace App\Http\Middleware;

use App\Models\User;
use App\Support\ApiResponse;
use App\Support\TicketEvent;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsTechnician
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user()?->role !== User::ROLE_TECHNICIAN) {
            TicketEvent::record('ticket.technician_access', 'role_denied', $request->user()?->id);

            return ApiResponse::error('You are not authorized to perform this operation.', 'FORBIDDEN', 403);
        }

        return $next($request);
    }
}
