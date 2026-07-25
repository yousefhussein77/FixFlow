<?php

namespace Tests\Feature\Tickets;

use App\Models\Ticket;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminListTicketsTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_lists_all_reporters_with_stable_pages_and_explicit_assignment(): void
    {
        $admin = User::factory()->administrator()->create();
        $technician = User::factory()->technician()->create();
        $tickets = collect([
            Ticket::factory()->create(['created_at' => now()]),
            Ticket::factory()->assigned($technician)->create(['created_at' => now()]),
            Ticket::factory()->create(['created_at' => now()]),
        ]);
        $token = $admin->createToken('t')->plainTextToken;
        $one = $this->withToken($token)->getJson('/api/admin/tickets?per_page=2')->assertOk()->assertJsonCount(2, 'data')->assertJsonPath('meta.total', 3);
        $two = $this->withToken($token)->getJson('/api/admin/tickets?per_page=2&page=2')->assertOk()->assertJsonCount(1, 'data');
        $this->assertSame($tickets->sortByDesc('id')->pluck('reference')->all(), array_merge(array_column($one->json('data'), 'reference'), array_column($two->json('data'), 'reference')));
        $one->assertJsonStructure(['data' => [['reference', 'title', 'reporter' => ['id', 'name'], 'priority', 'department', 'category', 'status', 'assigned_technician', 'created_at']]]);
    }

    public function test_admin_list_validates_pages_and_conceals_from_other_actors(): void
    {
        $this->getJson('/api/admin/tickets')->assertUnauthorized()->assertJsonPath('data', null);
        foreach ([User::factory()->create(), User::factory()->technician()->create()] as $user) {
            $this->withToken($user->createToken('t')->plainTextToken)->getJson('/api/admin/tickets')->assertForbidden()->assertJsonMissingPath('meta');
        }
    }

    public function test_admin_list_validates_pagination_and_returns_empty_out_of_range(): void
    {
        $admin = User::factory()->administrator()->create();
        $token = $admin->createToken('t')->plainTextToken;
        $this->withToken($token)->getJson('/api/admin/tickets?page=99')->assertOk()->assertJsonCount(0, 'data');
        foreach (['page=0', 'per_page=101'] as $query) {
            $this->withToken($token)->getJson("/api/admin/tickets?$query")->assertUnprocessable();
        }
    }
}
