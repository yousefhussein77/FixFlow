<?php

namespace App\Support;

use Illuminate\Support\Facades\Log;

final class TicketEvent
{
    public static function record(string $event, string $outcome, ?int $actorId = null, ?string $reference = null): void
    {
        Log::info('ticket_event', array_filter([
            'event_type' => $event,
            'outcome' => $outcome,
            'occurred_at' => now()->toISOString(),
            'correlation_id' => request()?->header('X-Correlation-ID') ?? request()?->attributes->get('request_id'),
            'actor_id' => $actorId,
            'ticket_reference' => $reference,
        ], fn ($value) => $value !== null));
    }
}
