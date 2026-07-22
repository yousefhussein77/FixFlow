<?php

namespace Tests\Feature\ReferenceData;

use App\Models\Department;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CategoryTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_manages_scoped_unique_categories_and_active_relationships(): void
    {
        $t = User::factory()->administrator()->create()->createToken('t')->plainTextToken;
        $a = Department::factory()->create(['name' => 'A', 'normalized_name' => 'a']);
        $b = Department::factory()->create(['name' => 'B', 'normalized_name' => 'b']);
        $r = $this->withToken($t)->postJson('/api/admin/categories', ['department_id' => $a->id, 'name' => 'Electrical'])->assertCreated();
        $id = $r->json('data.id');
        $this->withToken($t)->postJson('/api/admin/categories', ['department_id' => $a->id, 'name' => 'electrical'])->assertUnprocessable();
        $this->withToken($t)->postJson('/api/admin/categories', ['department_id' => $b->id, 'name' => 'electrical'])->assertCreated();
        $this->withToken($t)->putJson("/api/admin/categories/$id", ['department_id' => $b->id, 'name' => 'Plumbing', 'version' => 1])->assertOk()->assertJsonPath('data.version', 2);
        $b->update(['is_active' => false]);
        $this->withToken($t)->putJson("/api/admin/categories/$id", ['department_id' => $b->id, 'name' => 'Other', 'version' => 2])->assertUnprocessable();
        $this->assertDatabaseCount('categories', 2);
    }

    public function test_reporter_cannot_probe_category_ids(): void
    {
        $t = User::factory()->create()->createToken('t')->plainTextToken;
        foreach ([1, 999] as $id) {
            $this->withToken($t)->getJson("/api/admin/categories/$id")->assertForbidden()->assertJsonPath('code', 'FORBIDDEN');
        }
    }
}
