<?php

namespace App\Services\Tickets;

use App\Models\Ticket;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;

class TicketCommentAccess
{
    public function query(User $actor, string $role): Builder
    {
        $query = Ticket::query();

        return match ($role) {
            User::ROLE_REPORTER => $query->where('reporter_id', $actor->id),
            User::ROLE_TECHNICIAN => $query->where('assigned_technician_id', $actor->id),
            User::ROLE_ADMINISTRATOR => $query,
            default => $query->whereRaw('1 = 0'),
        };
    }
}
