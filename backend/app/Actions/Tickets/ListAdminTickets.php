<?php

namespace App\Actions\Tickets;

use App\Models\Ticket;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class ListAdminTickets
{
    public function execute(int $perPage = 20): LengthAwarePaginator
    {
        return Ticket::query()->with(['reporter', 'department', 'category', 'assignedTechnician'])
            ->orderByDesc('created_at')->orderByDesc('id')->paginate($perPage);
    }
}
