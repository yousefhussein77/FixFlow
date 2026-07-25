<?php

namespace Tests\Feature\Tickets;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TechnicianOptionsTest extends TestCase
{
    use RefreshDatabase;

    public function test_only_active_technicians_are_returned_with_minimal_fields(): void
    {
        $admin = User::factory()->administrator()->create();
        $b = User::factory()->technician()->create(['name' => 'Beta']);
        $a = User::factory()->technician()->create(['name' => 'alpha']);
        User::factory()->technician()->inactive()->create();
        User::factory()->create();
        $response = $this->withToken($admin->createToken('t')->plainTextToken)->getJson('/api/admin/options/technicians')->assertOk()->assertJsonCount(2, 'data');
        $this->assertSame([$a->id, $b->id], array_column($response->json('data'), 'id'));
        $response->assertJsonMissing(['email' => $a->email]);
    }

    public function test_options_require_active_administrator(): void
    {
        $this->getJson('/api/admin/options/technicians')->assertUnauthorized();
        foreach ([User::factory()->create(), User::factory()->technician()->create()] as $user) {
            $this->withToken($user->createToken('t')->plainTextToken)->getJson('/api/admin/options/technicians')->assertForbidden()->assertJsonPath('data', null);
        }
    }
}
