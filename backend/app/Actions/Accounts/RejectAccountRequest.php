<?php

namespace App\Actions\Accounts;

use App\Enums\AccountStatus;
use App\Enums\UserRole;
use App\Exceptions\AccountRequestConflictException;
use App\Models\User;
use App\Services\Notifications\NotificationService;
use App\Support\AuthEvent;
use Illuminate\Support\Facades\DB;

class RejectAccountRequest
{
    public function __construct(private readonly NotificationService $notifications) {}

    public function execute(User $actor, User $account, ?string $reason): User
    {
        return DB::transaction(function () use ($actor, $account, $reason): User {
            $locked = User::query()->lockForUpdate()->findOrFail($account->id);
            if (
                $locked->account_status !== AccountStatus::Pending
                || ! in_array($locked->role, UserRole::publiclyRequestable(), true)
            ) {
                throw new AccountRequestConflictException('Account request is no longer pending.');
            }

            $locked->account_status = AccountStatus::Rejected;
            $locked->is_active = false;
            $locked->approved_by = null;
            $locked->approved_at = null;
            $locked->rejected_by = $actor->id;
            $locked->rejected_at = now();
            $locked->rejection_reason = $reason;
            $locked->save();
            $this->notifications->accountDecision($locked);
            $locked->tokens()->delete();

            AuthEvent::record('account.approval', 'rejected', $locked->id);

            return $locked->refresh();
        });
    }
}
