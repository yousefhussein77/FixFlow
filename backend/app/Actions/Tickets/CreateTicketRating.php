<?php

namespace App\Actions\Tickets;

use App\Exceptions\RatingAlreadyExistsException;
use App\Exceptions\TicketNotCompletedException;
use App\Exceptions\TicketNotFoundException;
use App\Models\Ticket;
use App\Models\TicketRating;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class CreateTicketRating
{
    /** @return array{rating: TicketRating, replayed: bool} */
    public function execute(User $reporter, string $reference, int $value, string $submissionToken): array
    {
        if ($value < 1 || $value > 5) {
            throw ValidationException::withMessages(['rating' => ['The rating must be a whole number from 1 to 5.']]);
        }

        return DB::transaction(function () use ($reporter, $reference, $value, $submissionToken): array {
            $ticket = $reporter->tickets()->where('reference', $reference)->lockForUpdate()->first();
            if (! $ticket) {
                throw new TicketNotFoundException;
            }

            $existing = TicketRating::query()->where('ticket_id', $ticket->id)->first();
            if ($existing) {
                if ($existing->reporter_id === $reporter->id && hash_equals($existing->submission_token, $submissionToken)) {
                    return ['rating' => $existing, 'replayed' => true];
                }
                throw new RatingAlreadyExistsException;
            }

            if ($ticket->status !== Ticket::STATUS_COMPLETED) {
                throw new TicketNotCompletedException;
            }

            $rating = TicketRating::query()->create([
                'ticket_id' => $ticket->id,
                'reporter_id' => $reporter->id,
                'submission_token' => $submissionToken,
                'value' => $value,
                'created_at' => now(),
            ]);

            return ['rating' => $rating, 'replayed' => false];
        }, 3);
    }
}
