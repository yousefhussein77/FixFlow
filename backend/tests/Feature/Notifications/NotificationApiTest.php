<?php

namespace Tests\Feature\Notifications;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class NotificationApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_lists_only_own_notifications_newest_first_and_receives_unread_count(): void
    {
        $user = User::factory()->create();
        $other = User::factory()->create();
        $older = Notification::factory()->for($user, 'recipient')->create([
            'created_at' => now()->subMinute(),
            'deduplication_key' => 'older',
        ]);
        $newer = Notification::factory()->for($user, 'recipient')->create([
            'created_at' => now(),
            'deduplication_key' => 'newer',
        ]);
        Notification::factory()->for($other, 'recipient')->create();

        $this->actingAs($user)->getJson('/api/notifications')
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.id', $newer->id)
            ->assertJsonPath('data.1.id', $older->id)
            ->assertJsonMissing(['recipient_user_id' => $other->id]);

        $this->actingAs($user)->getJson('/api/notifications/unread-count')
            ->assertOk()
            ->assertJsonPath('data.unread_count', 2);
    }

    public function test_user_marks_one_and_all_own_notifications_read_idempotently(): void
    {
        $user = User::factory()->create();
        $first = Notification::factory()->for($user, 'recipient')->create([
            'deduplication_key' => 'first',
        ]);
        $second = Notification::factory()->for($user, 'recipient')->create([
            'deduplication_key' => 'second',
        ]);

        $this->actingAs($user)->patchJson("/api/notifications/{$first->id}/read", [])
            ->assertOk()
            ->assertJsonPath('data.id', $first->id);
        $readAt = $first->fresh()->read_at;
        $this->actingAs($user)->patchJson("/api/notifications/{$first->id}/read", [])
            ->assertOk();
        $this->assertEquals($readAt, $first->fresh()->read_at);

        $this->actingAs($user)->patchJson('/api/notifications/read-all', [])
            ->assertOk()
            ->assertJsonPath('data.updated_count', 1);
        $this->assertNotNull($second->fresh()->read_at);
        $this->actingAs($user)->getJson('/api/notifications/unread-count')
            ->assertJsonPath('data.unread_count', 0);
    }

    public function test_notification_ownership_is_concealed_and_endpoints_require_authentication(): void
    {
        $owner = User::factory()->create();
        $other = User::factory()->create();
        $notification = Notification::factory()->for($owner, 'recipient')->create();

        $this->patchJson("/api/notifications/{$notification->id}/read", [])->assertUnauthorized();
        $this->getJson('/api/notifications')->assertUnauthorized();
        $this->actingAs($other)
            ->patchJson("/api/notifications/{$notification->id}/read", [])
            ->assertNotFound()
            ->assertJsonPath('code', 'NOTIFICATION_NOT_FOUND');
        $this->actingAs($other)
            ->patchJson('/api/notifications/read-all', ['unexpected' => true])
            ->assertUnprocessable();

        $this->assertNull($notification->fresh()->read_at);
    }
}
