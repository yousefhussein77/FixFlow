<?php

namespace App\Models;

use Database\Factories\DepartmentFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Department extends Model
{
    /** @use HasFactory<DepartmentFactory> */
    use HasFactory;

    protected $fillable = ['name', 'normalized_name', 'is_active', 'version'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean', 'version' => 'integer'];
    }

    public function categories(): HasMany
    {
        return $this->hasMany(Category::class);
    }
}
