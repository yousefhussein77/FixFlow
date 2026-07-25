<?php

namespace App\Actions\Tickets;

use App\Exceptions\AssignmentConflictException;
use App\Exceptions\TicketNotFoundException;
use App\Models\Ticket;
use App\Models\TicketStatusHistory;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class AssignTicket
{
    public function execute(User $actor, string $reference, int $technicianId): Ticket
    {
        return DB::transaction(function () use ($actor, $reference, $technicianId): Ticket {
            $ticket = Ticket::query()->where('reference', $reference)->lockForUpdate()->first();
            if (! $ticket) {
                throw new TicketNotFoundException;
            }
            if ($ticket->status !== Ticket::STATUS_NEW || $ticket->assigned_technician_id !== null) {
                throw new AssignmentConflictException;
            }
            $technician = User::query()->find($technicianId);
            if (! $technician || ! $technician->is_active || $technician->role !== User::ROLE_TECHNICIAN) {
                throw ValidationException::withMessages(['technician_id' => ['The selected technician is not eligible for assignment.']]);
            }
            $occurredAt = now();
            $ticket->forceFill(['assigned_technician_id' => $technician->id, 'status' => Ticket::STATUS_ASSIGNED])->save();
            TicketStatusHistory::query()->create([
                'ticket_id' => $ticket->id, 'from_status' => Ticket::STATUS_NEW,
                'to_status' => Ticket::STATUS_ASSIGNED, 'actor_id' => $actor->id,
                'assigned_technician_id' => $technician->id, 'occurred_at' => $occurredAt,
            ]);

            return $ticket->load(['reporter', 'department', 'category', 'assignedTechnician']);
        }, 3);
    }
}
