<?php

namespace App\Http\Middleware;

use App\Enums\AccountStatus;
use App\Support\ApiResponse;
use App\Support\AuthEvent;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsActive
{
    public function handle(Request $request, Closure $next): Response
    {
        if (! $request->user()?->isApproved()) {
            AuthEvent::record('auth.protected_operation', 'inactive_denied', $request->user()?->id);

            $isApprovalBlocked = in_array(
                $request->user()?->account_status,
                [AccountStatus::Pending, AccountStatus::Rejected],
                true,
            );

            return ApiResponse::error(
                message: $isApprovalBlocked
                    ? 'هذا الحساب غير مصرح له بالوصول.'
                    : 'يرجى تسجيل الدخول للمتابعة.',
                code: $isApprovalBlocked ? 'ACCOUNT_NOT_APPROVED' : 'UNAUTHENTICATED',
                status: 401,
            );
        }

        return $next($request);
    }
}
