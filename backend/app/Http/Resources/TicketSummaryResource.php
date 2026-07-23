<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TicketSummaryResource extends JsonResource
{
    public static $wrap = null;

    public function toArray(Request $request): array
    {
        return [
            'reference' => $this->reference,
            'title' => $this->title,
            'status' => $this->status,
            'priority' => $this->priority,
            'department' => ['id' => $this->department->id, 'name' => $this->department->name],
            'category' => ['id' => $this->category->id, 'name' => $this->category->name],
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
