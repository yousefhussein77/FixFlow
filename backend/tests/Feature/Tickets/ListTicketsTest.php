<?php

namespace Tests\Feature\Tickets;

use App\Models\Category;
use App\Models\Department;
use App\Models\Ticket;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ListTicketsTest extends TestCase
{
    use RefreshDatabase;

    public function test_list_is_ownership_filtered_before_count_and_stably_paginated_newest_first(): void
    {
        $reporter = User::factory()->create();
        $other = User::factory()->create();
        $department = Department::factory()->create();
        $category = Category::factory()->create(['department_id' => $department->id]);
        $base = ['department_id' => $department->id, 'category_id' => $category->id, 'created_at' => now()];
        $tickets = collect(range(1, 3))->map(fn () => Ticket::factory()->create($base + ['reporter_id' => $reporter->id]));
        Ticket::factory()->create($base + ['reporter_id' => $other->id]);
        $token = $reporter->createToken('t')->plainTextToken;
        $one = $this->withToken($token)->getJson('/api/reporter/tickets?per_page=2&page=1')->assertOk()->assertJsonCount(2, 'data')->assertJsonPath('meta.total', 3);
        $two = $this->withToken($token)->getJson('/api/reporter/tickets?per_page=2&page=2')->assertOk()->assertJsonCount(1, 'data');
        $actual = array_merge(array_column($one->json('data'), 'reference'), array_column($two->json('data'), 'reference'));
        $expected = $tickets->sortByDesc('id')->pluck('reference')->all();
        $this->assertSame($expected, $actual);
    }

    public function test_empty_out_of_range_and_invalid_pagination_are_distinct(): void
    {
        $token = User::factory()->create()->createToken('t')->plainTextToken;
        $this->withToken($token)->getJson('/api/reporter/tickets')->assertOk()->assertJsonCount(0, 'data')->assertJsonPath('meta.total', 0);
        $this->withToken($token)->getJson('/api/reporter/tickets?page=99')->assertOk()->assertJsonCount(0, 'data');
        foreach (['page=0', 'page=no', 'per_page=101'] as $query) {
            $this->withToken($token)->getJson("/api/reporter/tickets?$query")->assertUnprocessable();
        }
    }

    public function test_list_requires_reporter_authentication(): void
    {
        $this->getJson('/api/reporter/tickets')->assertUnauthorized();
        $admin = User::factory()->administrator()->create();
        $this->withToken($admin->createToken('t')->plainTextToken)->getJson('/api/reporter/tickets')->assertForbidden();
    }
}
