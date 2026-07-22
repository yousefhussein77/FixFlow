<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CategoryResource extends JsonResource
{
    public static $wrap = null;

    public function toArray(Request $request): array
    {
        return ['id' => $this->id, 'name' => $this->name, 'department' => ['id' => $this->department->id, 'name' => $this->department->name], 'is_active' => (bool) $this->is_active, 'version' => (int) $this->version, 'created_at' => $this->created_at?->toISOString(), 'updated_at' => $this->updated_at?->toISOString()];
    }
}
