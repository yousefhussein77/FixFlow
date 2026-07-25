<?php

namespace Tests\Feature\Tickets;

use App\Models\TicketStatusHistory;
use Illuminate\Foundation\Testing\RefreshDatabase;
use LogicException;
use Tests\TestCase;

class TicketProcessingPersistenceTest extends TestCase
{
    use RefreshDatabase;

    public function test_history_reason_is_nullable_bounded_and_immutable(): void
    {
        $history = TicketStatusHistory::factory()->create(['reason' => null]);
        $this->assertNull($history->reason);
        $this->expectException(LogicException::class);
        $history->delete();
    }
}
