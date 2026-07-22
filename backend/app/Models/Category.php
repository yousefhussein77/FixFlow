<?php

namespace App\Models;

use Database\Factories\CategoryFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Category extends Model
{
    /** @use HasFactory<CategoryFactory> */
    use HasFactory;

    protected $fillable = ['department_id', 'name', 'normalized_name', 'is_active', 'version'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean', 'version' => 'integer'];
    }

    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }
}
