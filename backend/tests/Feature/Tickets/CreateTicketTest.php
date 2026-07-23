<?php

namespace Tests\Feature\Tickets;

use App\Actions\Tickets\CreateTicket;
use App\Models\Category;
use App\Models\Department;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Tests\TestCase;

class CreateTicketTest extends TestCase
{
    use RefreshDatabase;

    private User $reporter;

    private Department $department;

    private Category $category;

    private string $token;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('local');
        $this->reporter = User::factory()->create();
        $this->token = $this->reporter->createToken('test')->plainTextToken;
        $this->department = Department::factory()->create();
        $this->category = Category::factory()->create(['department_id' => $this->department->id]);
    }

    public function test_reporter_creates_authoritative_trimmed_ticket_without_photos(): void
    {
        $response = $this->withToken($this->token)->post('/api/reporter/tickets', $this->payload() + ['reporter_id' => 999, 'status' => 'closed']);
        $response->assertCreated()->assertJsonPath('data.status', 'new')->assertJsonPath('data.title', 'Leaking pipe');
        $this->assertMatchesRegularExpression('/^TKT-[A-Z0-9]{12}$/', $response->json('data.reference'));
        $this->assertDatabaseHas('tickets', ['reporter_id' => $this->reporter->id, 'status' => 'new', 'title' => 'Leaking pipe']);
        $this->assertDatabaseCount('ticket_photos', 0);
    }

    public function test_zero_through_five_valid_photos_are_accepted(): void
    {
        for ($count = 0; $count <= 5; $count++) {
            $payload = $this->payload(['submission_token' => (string) Str::uuid()]);
            $payload['photos'] = array_map(fn ($i) => $this->png("$i.png"), range(1, $count));
            if ($count === 0) {
                $payload['photos'] = [];
            }
            $this->withToken($this->token)->post('/api/reporter/tickets', $payload)->assertCreated()->assertJsonCount($count, 'data.photos');
        }
        $this->assertDatabaseCount('tickets', 6);
        $this->assertDatabaseCount('ticket_photos', 15);
    }

    public function test_validation_rejects_fields_relationship_priority_and_photo_boundaries_atomically(): void
    {
        $other = Department::factory()->create();
        $invalid = $this->payload(['title' => '   ', 'department_id' => $other->id, 'priority' => 'critical', 'photos' => array_map(fn ($i) => $this->png("$i.png"), range(1, 6))]);
        $this->withToken($this->token)->post('/api/reporter/tickets', $invalid)->assertUnprocessable()->assertJsonValidationErrors(['title', 'category_id', 'priority', 'photos']);
        $this->assertDatabaseCount('tickets', 0);
        $this->assertDatabaseCount('ticket_photos', 0);

        $this->withToken($this->token)->post('/api/reporter/tickets', $this->payload(['submission_token' => (string) Str::uuid(), 'photos' => [UploadedFile::fake()->create('bad.txt', 1, 'text/plain')]]))->assertUnprocessable()->assertJsonValidationErrors('photos.0');
        $this->withToken($this->token)->post('/api/reporter/tickets', $this->payload(['submission_token' => (string) Str::uuid(), 'photos' => [UploadedFile::fake()->create('huge.jpg', 10241, 'image/jpeg')]]))->assertUnprocessable()->assertJsonValidationErrors('photos.0');
        $this->assertDatabaseCount('tickets', 0);
    }

    public function test_inactive_reference_data_is_revalidated(): void
    {
        $this->department->update(['is_active' => false]);
        $this->withToken($this->token)->post('/api/reporter/tickets', $this->payload())->assertUnprocessable()->assertJsonValidationErrors(['department_id', 'category_id']);
        $this->assertDatabaseCount('tickets', 0);
    }

    public function test_same_reporter_submission_token_replays_without_duplicate(): void
    {
        $payload = $this->payload();
        $first = $this->withToken($this->token)->post('/api/reporter/tickets', $payload)->assertCreated();
        $second = $this->withToken($this->token)->post('/api/reporter/tickets', $payload)->assertCreated();
        $this->assertSame($first->json('data.reference'), $second->json('data.reference'));
        $this->assertDatabaseCount('tickets', 1);
    }

    public function test_storage_failure_after_a_photo_rolls_back_records_and_files(): void
    {
        $writes = 0;
        $this->app->instance(CreateTicket::class, new CreateTicket(function ($photo, $disk, $path) use (&$writes): bool {
            $writes++;
            if ($writes === 2) {
                return false;
            }

            return (bool) Storage::disk($disk)->putFileAs(dirname($path), $photo, basename($path));
        }));
        $payload = $this->payload(['photos' => [$this->png('one.png'), $this->png('two.png')]]);
        $this->withToken($this->token)->post('/api/reporter/tickets', $payload)->assertServerError()->assertJsonPath('code', 'SERVER_ERROR');
        $this->assertDatabaseCount('tickets', 0);
        $this->assertDatabaseCount('ticket_photos', 0);
        Storage::disk('local')->assertDirectoryEmpty('tickets');
    }

    public function test_authentication_active_account_and_reporter_role_are_required(): void
    {
        $this->postJson('/api/reporter/tickets', $this->payload())->assertUnauthorized();
        foreach ([User::factory()->technician()->create(), User::factory()->administrator()->create()] as $user) {
            $this->withToken($user->createToken('x')->plainTextToken)->postJson('/api/reporter/tickets', $this->payload())->assertForbidden()->assertJsonMissing(['title' => 'Leaking pipe']);
        }
    }

    public function test_inactive_reporter_is_unauthenticated(): void
    {
        $inactive = User::factory()->inactive()->create();
        $this->withToken($inactive->createToken('x')->plainTextToken)
            ->postJson('/api/reporter/tickets', $this->payload())
            ->assertUnauthorized()
            ->assertJsonPath('code', 'UNAUTHENTICATED');
    }

    private function payload(array $overrides = []): array
    {
        return array_replace(['submission_token' => (string) Str::uuid(), 'title' => '  Leaking pipe  ', 'description' => 'Water is leaking.', 'department_id' => $this->department->id, 'category_id' => $this->category->id, 'priority' => 'high', 'location' => '  Floor 2  '], $overrides);
    }

    private function png(string $name): UploadedFile
    {
        return UploadedFile::fake()->createWithContent($name, base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII='));
    }
}
