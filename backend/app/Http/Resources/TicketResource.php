<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;

class TicketResource extends TicketSummaryResource
{
    public function toArray(Request $request): array
    {
        return parent::toArray($request) + [
            'description' => $this->description,
            'location' => $this->location,
            'photos' => $this->photos->map(fn ($photo): array => [
                'id' => $photo->id,
                'name' => $photo->original_name,
                'mime_type' => $photo->mime_type,
                'size' => $photo->size,
                'position' => $photo->position,
            ])->values()->all(),
            'updated_at' => $this->updated_at?->toISOString(),
            'rating' => $this->rating ? (new TicketRatingResource($this->rating))->resolve($request) : null,
        ];
    }
}
