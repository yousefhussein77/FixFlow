<?php

namespace Tests\Feature\ReferenceData;

use App\Models\Category;
use App\Models\Department;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ReferenceOptionTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_roles_receive_only_effectively_active_options(): void
    {
        $active = Department::factory()->create(['name' => 'Active', 'normalized_name' => 'active']);
        $inactive = Department::factory()->inactive()->create(['name' => 'Inactive', 'normalized_name' => 'inactive']);
        Category::factory()->create(['department_id' => $active->id, 'name' => 'Good', 'normalized_name' => 'good']);
        Category::factory()->inactive()->create(['department_id' => $active->id, 'name' => 'Off', 'normalized_name' => 'off']);
        Category::factory()->create(['department_id' => $inactive->id, 'name' => 'Hidden', 'normalized_name' => 'hidden']);
        foreach ([User::ROLE_REPORTER, User::ROLE_TECHNICIAN, User::ROLE_ADMINISTRATOR] as $role) {
            $t = User::factory()->create(['role' => $role])->createToken('t')->plainTextToken;
            $this->withToken($t)->getJson('/api/options/departments')->assertOk()->assertJsonCount(1, 'data')->assertJsonPath('data.0.name', 'Active');
            $this->withToken($t)->getJson("/api/options/departments/$active->id/categories")->assertOk()->assertJsonCount(1, 'data')->assertJsonPath('data.0.name', 'Good');
            $this->withToken($t)->getJson("/api/options/departments/$inactive->id/categories")->assertUnprocessable();
        }
    }

    public function test_options_require_authentication(): void
    {
        $this->getJson('/api/options/departments')->assertUnauthorized();
    }
}
