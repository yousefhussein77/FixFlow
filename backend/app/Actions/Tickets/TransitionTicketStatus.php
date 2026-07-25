<?php

namespace App\Actions\Tickets;

use App\Exceptions\StatusTransitionConflictException;
use App\Exceptions\TicketNotFoundException;
use App\Models\Ticket;
use App\Models\TicketStatusHistory;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class TransitionTicketStatus
{
    public function execute(User $technician, string $reference, string $toStatus, ?string $reason): Ticket
    {
        return DB::transaction(function () use ($technician, $reference, $toStatus, $reason): Ticket {
            $ticket = Ticket::query()->where('reference', $reference)->where('assigned_technician_id', $technician->id)->lockForUpdate()->first();
            if (! $ticket) {
                throw new TicketNotFoundException;
            }
            if (! $ticket->canTechnicianTransitionTo($toStatus)) {
                throw new StatusTransitionConflictException;
            }
            $fromStatus = $ticket->status;
            $occurredAt = now();
            $ticket->forceFill(['status' => $toStatus])->save();
            TicketStatusHistory::query()->create(['ticket_id' => $ticket->id, 'from_status' => $fromStatus, 'to_status' => $toStatus, 'actor_id' => $technician->id, 'assigned_technician_id' => $technician->id, 'reason' => $toStatus === Ticket::STATUS_REJECTED ? $reason : null, 'occurred_at' => $occurredAt]);

            return $ticket->load(['department', 'category', 'photos', 'assignedTechnician', 'statusHistories.actor', 'statusHistories.assignedTechnician']);
        }, 3);
    }
}
