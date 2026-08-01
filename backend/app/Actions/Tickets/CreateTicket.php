<?php

namespace App\Actions\Tickets;

use App\Models\Category;
use App\Models\Department;
use App\Models\Ticket;
use App\Models\User;
use App\Services\Notifications\NotificationService;
use App\Support\TicketEvent;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use RuntimeException;
use Throwable;

class CreateTicket
{
    private NotificationService $notifications;

    /** @param null|callable(UploadedFile,string,string):bool $photoWriter */
    public function __construct(private $photoWriter = null, ?NotificationService $notifications = null)
    {
        $this->notifications = $notifications ?? app(NotificationService::class);
    }

    public function execute(User $reporter, array $data): Ticket
    {
        $existing = Ticket::query()->where('reporter_id', $reporter->id)->where('submission_token', $data['submission_token'])->first();
        if ($existing) {
            return $existing->load(['department', 'category', 'photos']);
        }

        $disk = 'local';
        $written = [];
        try {
            $ticket = DB::transaction(function () use ($reporter, $data, $disk, &$written): Ticket {
                $department = Department::query()->whereKey($data['department_id'])->where('is_active', true)->lockForUpdate()->first();
                if (! $department) {
                    throw ValidationException::withMessages(['department_id' => ['The selected department is invalid.']]);
                }
                $category = Category::query()->whereKey($data['category_id'])->where('department_id', $department->id)->where('is_active', true)->lockForUpdate()->first();
                if (! $category) {
                    throw ValidationException::withMessages(['category_id' => ['The selected category is invalid for this department.']]);
                }
                $ticket = Ticket::create([
                    'reference' => $this->reference(), 'reporter_id' => $reporter->id,
                    'department_id' => $department->id, 'category_id' => $category->id,
                    'submission_token' => $data['submission_token'], 'title' => trim($data['title']),
                    'description' => trim($data['description']), 'priority' => $data['priority'],
                    'location' => trim($data['location']), 'status' => Ticket::STATUS_NEW,
                ]);
                foreach (($data['photos'] ?? []) as $position => $photo) {
                    $extension = match ($photo->getMimeType()) {
                        'image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp', default => throw new RuntimeException('Unsupported photo content.')
                    };
                    $path = "tickets/{$ticket->reference}/".Str::uuid().".$extension";
                    $ok = $this->photoWriter ? ($this->photoWriter)($photo, $disk, $path) : Storage::disk($disk)->putFileAs(dirname($path), $photo, basename($path));
                    if (! $ok) {
                        throw new RuntimeException('Photo storage failed.');
                    }
                    $written[] = $path;
                    $safeName = basename(str_replace('\\', '/', $photo->getClientOriginalName()));
                    $ticket->photos()->create(['disk' => $disk, 'path' => $path, 'original_name' => $safeName, 'mime_type' => $photo->getMimeType(), 'size' => $photo->getSize(), 'position' => $position]);
                }
                $this->notifications->ticketCreated($ticket);

                return $ticket;
            }, 3);
        } catch (Throwable $exception) {
            foreach ($written as $path) {
                Storage::disk($disk)->delete($path);
            }
            $replayed = Ticket::query()
                ->where('reporter_id', $reporter->id)
                ->where('submission_token', $data['submission_token'])
                ->first();
            if ($replayed) {
                TicketEvent::record('ticket.creation', 'replayed', $reporter->id, $replayed->reference);

                return $replayed->load(['department', 'category', 'photos']);
            }
            TicketEvent::record('ticket.creation', 'failed', $reporter->id);
            throw $exception;
        }
        TicketEvent::record('ticket.creation', 'created', $reporter->id, $ticket->reference);

        return $ticket->load(['department', 'category', 'photos']);
    }

    private function reference(): string
    {
        do {
            $reference = 'TKT-'.Str::upper(Str::random(12));
        } while (Ticket::where('reference', $reference)->exists());

        return $reference;
    }
}
