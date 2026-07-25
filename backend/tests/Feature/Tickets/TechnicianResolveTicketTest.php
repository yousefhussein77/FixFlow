<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TechnicianResolveTicketTest extends TestCase
{
    use RefreshDatabase;

    public function test_completion_and_rejection_obey_exact_matrix_and_reason_validation(): void
    {
        $technician = User::factory()->technician()->create();
        $progress = Ticket::factory()->inProgress($technician)->create();
        $assigned = Ticket::factory()->assigned($technician)->create();
        $this->actingAs($technician)->patchJson("/api/technician/tickets/{$progress->reference}/status", ['status' => 'completed'])->assertOk();
        $this->actingAs($technician)->patchJson("/api/technician/tickets/{$assigned->reference}/status", ['status' => 'rejected'])->assertUnprocessable();
        $this->actingAs($technician)->patchJson("/api/technician/tickets/{$assigned->reference}/status", ['status' => 'rejected', 'reason' => str_repeat('x', 1001)])->assertUnprocessable();
        $this->actingAs($technician)->patchJson("/api/technician/tickets/{$assigned->reference}/status", ['status' => 'in_progress', 'reason' => 'not applicable'])->assertUnprocessable();
        $this->actingAs($technician)->patchJson("/api/technician/tickets/{$assigned->reference}/status", ['status' => 'in_progress', 'unexpected' => true])->assertUnprocessable();
        $this->actingAs($technician)->patchJson("/api/technician/tickets/{$assigned->reference}/status", ['status' => 'rejected', 'reason' => 'Cannot safely proceed'])->assertOk();
    }
}
