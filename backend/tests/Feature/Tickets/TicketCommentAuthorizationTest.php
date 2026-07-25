<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Route;
use Tests\TestCase;

class TicketCommentAuthorizationTest extends TestCase
{
    use RefreshDatabase;

    public function test_role_routes_reject_wrong_actors_and_only_six_comment_operations_exist(): void
    {
        $ticket = Ticket::factory()->create();
        $this->getJson("/api/technician/tickets/{$ticket->reference}/comments")->assertUnauthorized();
        $this->actingAs(User::factory()->create())->getJson("/api/admin/tickets/{$ticket->reference}/comments")->assertForbidden();
        $this->actingAs(User::factory()->administrator()->create())->getJson("/api/reporter/tickets/{$ticket->reference}/comments")->assertForbidden();
        $commentRoutes = collect(Route::getRoutes()->getRoutes())->filter(fn ($route) => str_ends_with($route->uri(), '/comments'));
        $this->assertCount(6, $commentRoutes);
        $this->assertTrue($commentRoutes->every(fn ($route) => count(array_intersect($route->methods(), ['GET', 'POST'])) === 1));
    }
}
