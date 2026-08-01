<?php

namespace App\Actions\Notifications;

use App\Models\User;
use Illuminate\Support\Facades\DB;

class MarkAllNotificationsRead
{
    public function execute(User $user): int
    {
        return DB::transaction(fn (): int => $user->notifications()
            ->whereNull('read_at')
            ->update(['read_at' => now(), 'updated_at' => now()]), 3);
    }
}
