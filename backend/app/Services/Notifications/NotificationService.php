<?php

namespace App\Services\Notifications;

use App\Enums\AccountStatus;
use App\Models\Notification;
use App\Models\Ticket;
use App\Models\TicketComment;
use App\Models\User;

class NotificationService
{
    public function accountRequestCreated(User $account): void
    {
        $this->notifyAdministrators(
            type: 'account_request.created',
            title: 'طلب حساب جديد',
            message: "أرسل {$account->name} طلب إنشاء حساب جديد.",
            target: 'admin.account_requests',
            deduplicationKey: "account-request:{$account->id}:created",
            relatedType: 'account',
            relatedId: $account->id,
            payload: ['account_id' => $account->id],
        );
    }

    public function accountDecision(User $account): void
    {
        $approved = $account->account_status === AccountStatus::Approved;
        $this->notify(
            recipient: $account,
            type: $approved ? 'account_request.approved' : 'account_request.rejected',
            title: $approved ? 'تم اعتماد الحساب' : 'تم رفض طلب الحساب',
            message: $approved
                ? 'تم اعتماد حسابك ويمكنك الآن استخدام FixFlow.'
                : 'تم رفض طلب إنشاء الحساب. تواصل مع الإدارة عند الحاجة.',
            target: 'account.status',
            deduplicationKey: "account-request:{$account->id}:{$account->account_status->value}",
            relatedType: 'account',
            relatedId: $account->id,
            payload: ['account_status' => $account->account_status->value],
        );
    }

    public function ticketCreated(Ticket $ticket): void
    {
        $this->notifyAdministrators(
            type: 'ticket.created',
            title: 'تذكرة جديدة',
            message: "تم إنشاء التذكرة {$ticket->reference} وتحتاج إلى مراجعة الإدارة.",
            target: 'admin.tickets',
            deduplicationKey: "ticket:{$ticket->id}:created",
            relatedType: 'ticket',
            relatedId: $ticket->id,
            payload: ['ticket_reference' => $ticket->reference],
        );
    }

    public function ticketAssigned(Ticket $ticket): void
    {
        if ($ticket->assigned_technician_id !== null) {
            $technician = User::query()->find($ticket->assigned_technician_id);
            if ($technician !== null) {
                $this->notify(
                    recipient: $technician,
                    type: 'ticket.assigned',
                    title: 'تم إسناد تذكرة إليك',
                    message: "تم إسناد التذكرة {$ticket->reference} إليك.",
                    target: 'technician.ticket',
                    deduplicationKey: "ticket:{$ticket->id}:assigned:{$technician->id}",
                    relatedType: 'ticket',
                    relatedId: $ticket->id,
                    payload: ['ticket_reference' => $ticket->reference],
                );
            }
        }

        $reporter = User::query()->find($ticket->reporter_id);
        if ($reporter !== null) {
            $this->notify(
                recipient: $reporter,
                type: 'ticket.assigned.reporter',
                title: 'تم إسناد التذكرة',
                message: "تم إسناد التذكرة {$ticket->reference} إلى فني.",
                target: 'reporter.ticket',
                deduplicationKey: "ticket:{$ticket->id}:reporter-assigned",
                relatedType: 'ticket',
                relatedId: $ticket->id,
                payload: ['ticket_reference' => $ticket->reference],
            );
        }

        $this->notifyAdministrators(
            type: 'ticket.assignment.updated',
            title: 'تم إسناد تذكرة',
            message: "اكتمل إسناد التذكرة {$ticket->reference}.",
            target: 'admin.tickets',
            deduplicationKey: "ticket:{$ticket->id}:admin-assigned",
            relatedType: 'ticket',
            relatedId: $ticket->id,
            payload: ['ticket_reference' => $ticket->reference],
        );
    }

    public function ticketStatusChanged(Ticket $ticket, string $fromStatus): void
    {
        $completed = $ticket->status === Ticket::STATUS_COMPLETED;
        $reporter = User::query()->find($ticket->reporter_id);
        if ($reporter !== null) {
            $this->notify(
                recipient: $reporter,
                type: $completed ? 'ticket.completed' : 'ticket.status_changed',
                title: $completed ? 'اكتملت التذكرة' : 'تغيرت حالة التذكرة',
                message: $completed
                    ? "اكتمل العمل على التذكرة {$ticket->reference} وهي جاهزة للتقييم."
                    : "تغيرت حالة التذكرة {$ticket->reference}.",
                target: $completed ? 'reporter.ticket_rating' : 'reporter.ticket',
                deduplicationKey: "ticket:{$ticket->id}:status:{$fromStatus}:{$ticket->status}",
                relatedType: 'ticket',
                relatedId: $ticket->id,
                payload: ['ticket_reference' => $ticket->reference, 'status' => $ticket->status],
            );
        }

        $this->notifyAdministrators(
            type: 'ticket.status_changed.admin',
            title: 'تحديث حالة تذكرة',
            message: "تغيرت حالة التذكرة {$ticket->reference}.",
            target: 'admin.tickets',
            deduplicationKey: "ticket:{$ticket->id}:admin-status:{$fromStatus}:{$ticket->status}",
            relatedType: 'ticket',
            relatedId: $ticket->id,
            payload: ['ticket_reference' => $ticket->reference, 'status' => $ticket->status],
        );
    }

    public function commentCreated(TicketComment $comment, string $submissionToken): void
    {
        $ticket = $comment->ticket()->firstOrFail();
        $recipients = collect([
            $ticket->reporter_id,
            $ticket->assigned_technician_id,
        ])->filter()->unique()->reject(fn (int $id): bool => $id === $comment->author_id);

        foreach (User::query()->whereIn('id', $recipients)->get() as $recipient) {
            $target = $recipient->role === User::ROLE_TECHNICIAN
                ? 'technician.ticket_comments'
                : 'reporter.ticket_comments';
            $this->notify(
                recipient: $recipient,
                type: 'ticket.comment_created',
                title: 'تعليق جديد على التذكرة',
                message: "تمت إضافة تعليق جديد إلى التذكرة {$ticket->reference}.",
                target: $target,
                deduplicationKey: "ticket:{$ticket->id}:comment:{$comment->author_id}:{$submissionToken}",
                relatedType: 'comment',
                relatedId: $comment->id,
                payload: ['ticket_reference' => $ticket->reference],
            );
        }
    }

    /** @param array<string, mixed> $payload */
    public function notify(
        User $recipient,
        string $type,
        string $title,
        string $message,
        string $target,
        string $deduplicationKey,
        ?string $relatedType = null,
        ?int $relatedId = null,
        array $payload = [],
    ): Notification {
        return Notification::query()->firstOrCreate(
            [
                'recipient_user_id' => $recipient->id,
                'deduplication_key' => $deduplicationKey,
            ],
            [
                'type' => $type,
                'title' => $title,
                'message' => $message,
                'related_entity_type' => $relatedType,
                'related_entity_id' => $relatedId,
                'navigation_target' => $target,
                'payload' => $payload ?: null,
            ],
        );
    }

    /** @param array<string, mixed> $payload */
    private function notifyAdministrators(
        string $type,
        string $title,
        string $message,
        string $target,
        string $deduplicationKey,
        ?string $relatedType = null,
        ?int $relatedId = null,
        array $payload = [],
    ): void {
        $administrators = User::query()
            ->where('role', User::ROLE_ADMINISTRATOR)
            ->where('is_active', true)
            ->where('account_status', AccountStatus::Approved)
            ->get();

        foreach ($administrators as $administrator) {
            $this->notify(
                $administrator,
                $type,
                $title,
                $message,
                $target,
                $deduplicationKey,
                $relatedType,
                $relatedId,
                $payload,
            );
        }
    }
}
