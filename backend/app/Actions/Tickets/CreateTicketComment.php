<?php

namespace App\Actions\Tickets;

use App\Exceptions\TicketNotFoundException;
use App\Models\TicketComment;
use App\Models\User;
use App\Services\Tickets\TicketCommentAccess;
use Illuminate\Support\Facades\DB;

class CreateTicketComment
{
    public function __construct(private readonly TicketCommentAccess $access) {}

    /** @return array{comment: TicketComment, replayed: bool} */
    public function execute(User $actor, string $role, string $reference, string $content, string $submissionToken): array
    {
        return DB::transaction(function () use ($actor, $role, $reference, $content, $submissionToken): array {
            $ticket = $this->access->query($actor, $role)->where('reference', $reference)->lockForUpdate()->first();
            if (! $ticket) {
                throw new TicketNotFoundException;
            }

            $existing = TicketComment::query()->where('ticket_id', $ticket->id)->where('author_id', $actor->id)
                ->where('submission_token', $submissionToken)->with('author')->first();
            if ($existing) {
                return ['comment' => $existing, 'replayed' => true];
            }

            $comment = TicketComment::query()->create([
                'ticket_id' => $ticket->id,
                'author_id' => $actor->id,
                'author_role' => $role,
                'submission_token' => $submissionToken,
                'content' => $content,
                'created_at' => now(),
            ])->load('author');

            return ['comment' => $comment, 'replayed' => false];
        }, 3);
    }
}
