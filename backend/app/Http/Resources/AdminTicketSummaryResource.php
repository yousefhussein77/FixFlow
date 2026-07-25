<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AdminTicketSummaryResource extends JsonResource
{
    public static $wrap = null;

    public function toArray(Request $request): array
    {
        return [
            'reference' => $this->reference,
            'title' => $this->title,
            'reporter' => ['id' => $this->reporter->id, 'name' => $this->reporter->name],
            'priority' => $this->priority,
            'department' => ['id' => $this->department->id, 'name' => $this->department->name],
            'category' => ['id' => $this->category->id, 'name' => $this->category->name],
            'status' => $this->status,
            'assigned_technician' => $this->assignedTechnician ? ['id' => $this->assignedTechnician->id, 'name' => $this->assignedTechnician->name] : null,
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
