<?php

namespace App\Actions\Auth;

use App\Enums\AccountStatus;
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

        if (! $user || ! $passwordMatches) {
            AuthEvent::record('auth.login', 'denied');

            return ApiResponse::error(
                message: 'بيانات تسجيل الدخول غير صحيحة.',
                code: 'INVALID_CREDENTIALS',
                status: 401,
            );
        }

        if (! $user->isApproved()) {
            AuthEvent::record('auth.login', 'account_status_denied', $user->id);

            return match ($user->account_status) {
                AccountStatus::Pending => ApiResponse::error(
                    'طلب إنشاء الحساب قيد مراجعة الإدارة.',
                    'ACCOUNT_PENDING',
                    403,
                ),
                AccountStatus::Rejected => ApiResponse::error(
                    'تم رفض طلب إنشاء الحساب. يمكنك التواصل مع الإدارة للمزيد من المعلومات.',
                    'ACCOUNT_REJECTED',
                    403,
                ),
                default => ApiResponse::error(
                    'هذا الحساب غير نشط. يرجى التواصل مع الإدارة.',
                    'ACCOUNT_INACTIVE',
                    403,
                ),
            };
        }

        AuthEvent::record('auth.login', 'success', $user->id);

        return [
            'user' => $user,
            'token' => $user->createToken('fixflow-mobile')->plainTextToken,
        ];
    }
}
