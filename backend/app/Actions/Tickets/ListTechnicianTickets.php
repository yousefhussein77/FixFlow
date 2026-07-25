<?php

namespace App\Actions\Tickets;

use App\Models\Ticket;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class ListTechnicianTickets
{
    public function execute(User $technician, int $perPage = 20): LengthAwarePaginator
    {
        return Ticket::query()->where('assigned_technician_id', $technician->id)->with(['department', 'category'])
            ->orderByDesc('created_at')->orderByDesc('id')->paginate($perPage);
    }
}
