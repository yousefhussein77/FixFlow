<?php

namespace App\Support;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

final class AuthEvent
{
    public static function record(string $event, string $outcome, ?int $userId = null): void
    {
        Log::info($event, array_filter([
            'outcome' => $outcome,
            'user_id' => $userId,
            'correlation_id' => request()->header('X-Request-ID') ?: (string) Str::uuid(),
        ], static fn (mixed $value): bool => $value !== null));
    }
}
