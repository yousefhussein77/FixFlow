<?php

namespace App\Actions\Auth;

use App\Models\User;
use App\Support\AuthEvent;

class LogoutUser
{
    public function execute(User $user): void
    {
        $user->currentAccessToken()?->delete();
        AuthEvent::record('auth.logout', 'success', $user->id);
    }
}
