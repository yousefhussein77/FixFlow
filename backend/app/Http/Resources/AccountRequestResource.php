<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AccountRequestResource extends JsonResource
{
    public static $wrap = null;

    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'requested_role' => $this->role,
            'status' => $this->account_status->value,
            'registered_at' => $this->created_at?->toISOString(),
            'approved_by' => $this->whenLoaded('approver', fn () => $this->reviewer($this->approver)),
            'approved_at' => $this->approved_at?->toISOString(),
            'rejected_by' => $this->whenLoaded('rejector', fn () => $this->reviewer($this->rejector)),
            'rejected_at' => $this->rejected_at?->toISOString(),
            'rejection_reason' => $this->rejection_reason,
        ];
    }

    private function reviewer(mixed $reviewer): ?array
    {
        return $reviewer === null ? null : ['id' => $reviewer->id, 'name' => $reviewer->name];
    }
}
