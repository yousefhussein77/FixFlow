<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;

class TechnicianTicketResource extends TechnicianTicketSummaryResource
{
    public function toArray(Request $request): array
    {
        return parent::toArray($request) + [
            'description' => $this->description,
            'location' => $this->location,
            'photos' => $this->photos->map(fn ($photo): array => ['id' => $photo->id, 'name' => $photo->original_name, 'mime_type' => $photo->mime_type, 'size' => $photo->size, 'position' => $photo->position])->values()->all(),
            'assigned_technician' => ['id' => $this->assignedTechnician->id, 'name' => $this->assignedTechnician->name],
            'status_history' => TicketStatusHistoryResource::collection($this->statusHistories)->resolve($request),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
