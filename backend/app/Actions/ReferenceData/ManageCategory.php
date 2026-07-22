<?php

namespace App\Actions\ReferenceData;

use App\Models\Category;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;

class ManageCategory
{
    public function create(array $data): Category
    {
        return Category::create($data)->refresh()->load('department');
    }

    public function update(Category $c, array $data): Category|JsonResponse
    {
        return $this->change($c, $data);
    }

    public function status(Category $c, bool $active, int $version): Category|JsonResponse
    {
        if ($c->is_active === $active) {
            return $c->load('department');
        }

return $this->change($c, ['is_active' => $active, 'version' => $version]);
    }

    private function change(Category $c, array $data): Category|JsonResponse
    {
        $v = (int) $data['version'];
        unset($data['version']);
        $data['version'] = $v + 1;
        if (! Category::whereKey($c->id)->where('version', $v)->update($data)) {
            return ApiResponse::error('The record was changed by another operation.', 'STALE_CONFLICT', 409);
        }

return $c->fresh()->load('department');
    }
}
