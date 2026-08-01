<?php

namespace App\Actions\Accounts;

use App\Enums\AccountStatus;
use App\Enums\UserRole;
use App\Exceptions\AccountRequestConflictException;
use App\Models\User;
use App\Services\Notifications\NotificationService;
use App\Support\AuthEvent;
use Illuminate\Support\Facades\DB;

class ApproveAccountRequest
{
    public function __construct(private readonly NotificationService $notifications) {}

    public function execute(User $actor, User $account): User
    {
        return DB::transaction(function () use ($actor, $account): User {
            $locked = User::query()->lockForUpdate()->findOrFail($account->id);
            if (
                $locked->account_status !== AccountStatus::Pending
                || ! in_array($locked->role, UserRole::publiclyRequestable(), true)
            ) {
                throw new AccountRequestConflictException('Account request is no longer pending.');
            }

            $locked->account_status = AccountStatus::Approved;
            $locked->is_active = true;
            $locked->approved_by = $actor->id;
            $locked->approved_at = now();
            $locked->rejected_by = null;
            $locked->rejected_at = null;
            $locked->rejection_reason = null;
            $locked->save();
            $this->notifications->accountDecision($locked);

            AuthEvent::record('account.approval', 'approved', $locked->id);

            return $locked->refresh();
        });
    }
}
