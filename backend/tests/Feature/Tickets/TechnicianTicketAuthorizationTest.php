<?php

namespace Tests\Feature\Tickets;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TechnicianTicketAuthorizationTest extends TestCase
{
    use RefreshDatabase;

    public function test_routes_require_an_active_technician(): void
    {
        $this->getJson('/api/technician/tickets')->assertUnauthorized();
        $this->actingAs(User::factory()->create())->getJson('/api/technician/tickets')->assertForbidden();
        $this->actingAs(User::factory()->administrator()->create())->getJson('/api/technician/tickets')->assertForbidden();
        $this->actingAs(User::factory()->technician()->inactive()->create())->getJson('/api/technician/tickets')->assertUnauthorized();
    }
}
