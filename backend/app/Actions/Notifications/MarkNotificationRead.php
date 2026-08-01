<?php

namespace App\Actions\Notifications;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class MarkNotificationRead
{
    public function execute(User $user, int $notificationId): ?Notification
    {
        return DB::transaction(function () use ($user, $notificationId): ?Notification {
            $notification = $user->notifications()
                ->whereKey($notificationId)
                ->lockForUpdate()
                ->first();
            if ($notification === null) {
                return null;
            }
            if ($notification->read_at === null) {
                $notification->forceFill(['read_at' => now()])->save();
            }

            return $notification->refresh();
        }, 3);
    }
}
