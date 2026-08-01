<?php

namespace App\Actions\Tickets;

use App\Enums\AccountStatus;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

class ListActiveTechnicians
{
    public function execute(): Collection
    {
        return User::query()
            ->where('role', User::ROLE_TECHNICIAN)
            ->where('is_active', true)
            ->where('account_status', AccountStatus::Approved)
            ->orderByRaw('LOWER(name)')->orderBy('id')->get(['id', 'name']);
    }
}
