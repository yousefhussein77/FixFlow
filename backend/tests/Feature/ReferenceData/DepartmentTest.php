<?php

namespace Tests\Feature\ReferenceData;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DepartmentTest extends TestCase
{
    use RefreshDatabase;

    private function admin(): string
    {
        return User::factory()->administrator()->create()->createToken('t')->plainTextToken;
    }

    public function test_admin_crud_lifecycle_uniqueness_and_conflict(): void
    {
        $t = $this->admin();
        $r = $this->withToken($t)->postJson('/api/admin/departments', ['name' => '  Facilities ']);
        $r->assertCreated()->assertJsonPath('data.name', 'Facilities')->assertJsonPath('data.is_active', true);
        $id = $r->json('data.id');
        $this->withToken($t)->postJson('/api/admin/departments', ['name' => 'facilities'])->assertUnprocessable();
        $this->withToken($t)->putJson("/api/admin/departments/$id", ['name' => 'Operations', 'version' => 1])->assertOk()->assertJsonPath('data.version', 2);
        $this->withToken($t)->putJson("/api/admin/departments/$id", ['name' => 'Stale', 'version' => 1])->assertConflict();
        $this->withToken($t)->patchJson("/api/admin/departments/$id/deactivate", ['version' => 2])->assertOk()->assertJsonPath('data.is_active', false);
        $this->assertDatabaseCount('departments', 1);
    }

    public function test_nonadmins_are_concealed_and_cannot_change_data(): void
    {
        $t = User::factory()->create()->createToken('t')->plainTextToken;
        foreach ([1, 999] as $id) {
            $this->withToken($t)->getJson("/api/admin/departments/$id")->assertForbidden()->assertJsonPath('code', 'FORBIDDEN');
        }
        $this->assertDatabaseCount('departments', 0);
        $this->app['auth']->forgetGuards();
        $this->withHeader('Authorization', '')->getJson('/api/admin/departments')->assertUnauthorized();
    }
}
