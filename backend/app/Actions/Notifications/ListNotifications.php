<?php

namespace App\Actions\Notifications;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

class ListNotifications
{
    /** @return Collection<int, Notification> */
    public function execute(User $user): Collection
    {
        return $user->notifications()
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->limit(100)
            ->get();
    }
}
