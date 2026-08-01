<?php

namespace App\Http\Controllers\Api;

use App\Actions\Notifications\ListNotifications;
use App\Actions\Notifications\MarkAllNotificationsRead;
use App\Actions\Notifications\MarkNotificationRead;
use App\Http\Controllers\Controller;
use App\Http\Requests\Notifications\EmptyNotificationRequest;
use App\Http\Resources\NotificationResource;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request, ListNotifications $action): JsonResponse
    {
        return ApiResponse::success(
            'تم تحميل الإشعارات.',
            NotificationResource::collection($action->execute($request->user()))->resolve($request),
        );
    }

    public function unreadCount(Request $request): JsonResponse
    {
        return ApiResponse::success('تم تحميل عدد الإشعارات غير المقروءة.', [
            'unread_count' => $request->user()->notifications()->whereNull('read_at')->count(),
        ]);
    }

    public function read(
        EmptyNotificationRequest $request,
        int $notification,
        MarkNotificationRead $action,
    ): JsonResponse {
        $updated = $action->execute($request->user(), $notification);
        if ($updated === null) {
            return ApiResponse::error(
                'تعذر العثور على الإشعار.',
                'NOTIFICATION_NOT_FOUND',
                404,
            );
        }

        return ApiResponse::success(
            'تم تعليم الإشعار كمقروء.',
            (new NotificationResource($updated))->resolve($request),
        );
    }

    public function readAll(
        EmptyNotificationRequest $request,
        MarkAllNotificationsRead $action,
    ): JsonResponse {
        return ApiResponse::success('تم تعليم جميع الإشعارات كمقروءة.', [
            'updated_count' => $action->execute($request->user()),
        ]);
    }
}
