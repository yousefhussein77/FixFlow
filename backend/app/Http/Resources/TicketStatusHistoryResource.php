<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TicketStatusHistoryResource extends JsonResource
{
    public static $wrap = null;

    public function toArray(Request $request): array
    {
        return [
            'from_status' => $this->from_status,
            'to_status' => $this->to_status,
            'actor' => ['id' => $this->actor->id, 'name' => $this->actor->name],
            'assigned_technician' => ['id' => $this->assignedTechnician->id, 'name' => $this->assignedTechnician->name],
            'occurred_at' => $this->occurred_at?->toISOString(),
            'reason' => $this->reason,
        ];
    }
}
