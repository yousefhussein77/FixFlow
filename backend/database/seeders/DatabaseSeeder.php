<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Department;
use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $facilities = Department::factory()->create([
            'name' => 'Facilities',
            'normalized_name' => 'facilities',
        ]);
        Category::factory()->create([
            'department_id' => $facilities->id,
            'name' => 'Electrical',
            'normalized_name' => 'electrical',
        ]);

        User::factory()->create([
            'name' => 'Development Reporter',
            'email' => 'reporter@fixflow.test',
            'role' => User::ROLE_REPORTER,
        ]);
        User::factory()->technician()->create([
            'name' => 'Development Technician',
            'email' => 'technician@fixflow.test',
        ]);
        User::factory()->administrator()->create([
            'name' => 'Development Administrator',
            'email' => 'administrator@fixflow.test',
        ]);
        User::factory()->inactive()->create([
            'name' => 'Inactive Development User',
            'email' => 'inactive@fixflow.test',
        ]);
    }
}
