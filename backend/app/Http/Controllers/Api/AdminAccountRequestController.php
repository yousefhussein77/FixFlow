<?php

namespace App\Http\Controllers\Api;

use App\Actions\Accounts\ApproveAccountRequest;
use App\Actions\Accounts\RejectAccountRequest;
use App\Enums\UserRole;
use App\Exceptions\AccountRequestConflictException;
use App\Http\Controllers\Controller;
use App\Http\Requests\Accounts\ApproveAccountRequestRequest;
use App\Http\Requests\Accounts\ListAccountRequestsRequest;
use App\Http\Requests\Accounts\RejectAccountRequestRequest;
use App\Http\Resources\AccountRequestResource;
use App\Models\User;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;

class AdminAccountRequestController extends Controller
{
    public function index(ListAccountRequestsRequest $request): JsonResponse
    {
        $status = $request->string('status')->toString();
        $accounts = User::query()
            ->with(['approver:id,name', 'rejector:id,name'])
            ->whereIn('role', UserRole::publiclyRequestable())
            ->when($status !== 'all', fn ($query) => $query->where('account_status', $status))
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->get();

        return ApiResponse::success(
            'تم تحميل طلبات الحسابات.',
            AccountRequestResource::collection($accounts),
        );
    }

    public function approve(
        ApproveAccountRequestRequest $request,
        int $account,
        ApproveAccountRequest $action,
    ): JsonResponse {
        $accountRequest = $this->findAccountRequest($account);
        if ($accountRequest === null) {
            return $this->notFound();
        }

        try {
            $updated = $action->execute($request->user(), $accountRequest);
        } catch (AccountRequestConflictException) {
            return ApiResponse::error(
                'لا يمكن اعتماد هذا الطلب لأن حالته تغيرت.',
                'ACCOUNT_REQUEST_NOT_PENDING',
                409,
            );
        }

        return ApiResponse::success(
            'تم اعتماد طلب الحساب بنجاح.',
            new AccountRequestResource($updated->load(['approver:id,name', 'rejector:id,name'])),
        );
    }

    public function reject(
        RejectAccountRequestRequest $request,
        int $account,
        RejectAccountRequest $action,
    ): JsonResponse {
        $accountRequest = $this->findAccountRequest($account);
        if ($accountRequest === null) {
            return $this->notFound();
        }

        try {
            $updated = $action->execute(
                $request->user(),
                $accountRequest,
                $request->validated('rejection_reason'),
            );
        } catch (AccountRequestConflictException) {
            return ApiResponse::error(
                'لا يمكن رفض هذا الطلب لأن حالته تغيرت.',
                'ACCOUNT_REQUEST_NOT_PENDING',
                409,
            );
        }

        return ApiResponse::success(
            'تم رفض طلب الحساب.',
            new AccountRequestResource($updated->load(['approver:id,name', 'rejector:id,name'])),
        );
    }

    private function findAccountRequest(int $id): ?User
    {
        return User::query()
            ->whereKey($id)
            ->whereIn('role', UserRole::publiclyRequestable())
            ->first();
    }

    private function notFound(): JsonResponse
    {
        return ApiResponse::error(
            'تعذر العثور على طلب الحساب.',
            'ACCOUNT_REQUEST_NOT_FOUND',
            404,
        );
    }
}
