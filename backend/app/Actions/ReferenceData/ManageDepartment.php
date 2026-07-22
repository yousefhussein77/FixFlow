<?php

namespace App\Actions\ReferenceData;

use App\Models\Department;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;

class ManageDepartment
{
    public function create(array $data): Department
    {
        return Department::create($data)->refresh();
    }

    public function update(Department $d, array $data): Department|JsonResponse
    {
        return $this->change($d, $data);
    }

    public function status(Department $d, bool $active, int $version): Department|JsonResponse
    {
        if ($d->is_active === $active) {
            return $d;
        }

return $this->change($d, ['is_active' => $active, 'version' => $version]);
    }

    private function change(Department $d, array $data): Department|JsonResponse
    {
        $v = (int) $data['version'];
        unset($data['version']);
        $data['version'] = $v + 1;
        if (! Department::whereKey($d->id)->where('version', $v)->update($data)) {
            return ApiResponse::error('The record was changed by another operation.', 'STALE_CONFLICT', 409);
        }

return $d->fresh();
    }
}
