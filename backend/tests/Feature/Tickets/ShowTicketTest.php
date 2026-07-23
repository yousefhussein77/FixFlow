<?php

namespace Tests\Feature\Tickets;

use App\Models\Category;
use App\Models\Department;
use App\Models\Ticket;
use App\Models\TicketPhoto;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ShowTicketTest extends TestCase
{
    use RefreshDatabase;

    public function test_owned_detail_contains_all_contract_fields_and_photos(): void
    {
        $reporter = User::factory()->create();
        $department = Department::factory()->create();
        $category = Category::factory()->create(['department_id' => $department->id]);
        $ticket = Ticket::factory()->create(['reporter_id' => $reporter->id, 'department_id' => $department->id, 'category_id' => $category->id]);
        TicketPhoto::factory()->create(['ticket_id' => $ticket->id]);
        $this->withToken($reporter->createToken('t')->plainTextToken)->getJson("/api/reporter/tickets/$ticket->reference")->assertOk()->assertJsonStructure(['data' => ['reference', 'title', 'description', 'status', 'priority', 'location', 'department', 'category', 'photos', 'created_at', 'updated_at']])->assertJsonCount(1, 'data.photos');
    }

    public function test_non_owned_and_unknown_are_identical_concealed_not_found(): void
    {
        $owner = User::factory()->create();
        $viewer = User::factory()->create();
        $ticket = Ticket::factory()->create(['reporter_id' => $owner->id]);
        $token = $viewer->createToken('t')->plainTextToken;
        $hidden = $this->withToken($token)->getJson("/api/reporter/tickets/$ticket->reference")->assertNotFound();
        $unknown = $this->withToken($token)->getJson('/api/reporter/tickets/TKT-UNKNOWN00000')->assertNotFound();
        $this->assertSame($hidden->json(), $unknown->json());
    }

    public function test_detail_requires_authentication_and_reporter_role(): void
    {
        $ticket = Ticket::factory()->create();
        $this->getJson("/api/reporter/tickets/$ticket->reference")->assertUnauthorized();
        $tech = User::factory()->technician()->create();
        $this->withToken($tech->createToken('t')->plainTextToken)->getJson("/api/reporter/tickets/$ticket->reference")->assertForbidden()->assertJsonMissing(['reference' => $ticket->reference]);
    }
}
