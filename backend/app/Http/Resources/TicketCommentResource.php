<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TicketCommentResource extends JsonResource
{
    public static $wrap = null;

    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'content' => $this->content,
            'author' => ['id' => $this->author->id, 'name' => $this->author->name, 'role' => $this->author_role],
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
