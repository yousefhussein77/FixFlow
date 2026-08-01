<?php

namespace App\Actions\Auth;

use App\Enums\AccountStatus;
use App\Models\User;
use App\Services\Notifications\NotificationService;
use App\Support\AuthEvent;
use Illuminate\Support\Facades\DB;

class RegisterPendingAccount
{
    public function __construct(private readonly NotificationService $notifications) {}

    public function execute(array $attributes): User
    {
        return DB::transaction(function () use ($attributes): User {
            $user = new User;
            $user->name = $attributes['name'];
            $user->email = $attributes['email'];
            $user->password = $attributes['password'];
            $user->role = $attributes['role'];
            $user->is_active = false;
            $user->account_status = AccountStatus::Pending;
            $user->save();
            $this->notifications->accountRequestCreated($user);

            AuthEvent::record('auth.registration', 'pending', $user->id);

            return $user;
        });
    }
}
