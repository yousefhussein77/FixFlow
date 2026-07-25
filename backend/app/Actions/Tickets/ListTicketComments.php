<?php

namespace App\Actions\Tickets;

use App\Exceptions\TicketNotFoundException;
use App\Models\TicketComment;
use App\Models\User;
use App\Services\Tickets\TicketCommentAccess;
use Illuminate\Database\Eloquent\Collection;

class ListTicketComments
{
    public function __construct(private readonly TicketCommentAccess $access) {}

    /** @return Collection<int, TicketComment> */
    public function execute(User $actor, string $role, string $reference): Collection
    {
        $ticket = $this->access->query($actor, $role)->where('reference', $reference)->first();
        if (! $ticket) {
            throw new TicketNotFoundException;
        }

        return $ticket->comments()->with('author')->get();
    }
}
