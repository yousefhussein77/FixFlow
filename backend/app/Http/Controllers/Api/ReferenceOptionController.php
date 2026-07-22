<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Department;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;

class ReferenceOptionController extends Controller
{
    public function departments(): JsonResponse
    {
        return ApiResponse::success('Department options retrieved.', Department::where('is_active', true)->orderBy('normalized_name')->get(['id', 'name']));
    }

    public function categories(int $departmentId): JsonResponse
    {
        $d = Department::whereKey($departmentId)->where('is_active', true)->first();
        if (! $d) {
            return ApiResponse::error('The selected department is invalid.', 'VALIDATION_ERROR', 422, ['department_id' => ['The selected department is invalid.']]);
        }

return ApiResponse::success('Category options retrieved.', Category::where('department_id', $d->id)->where('is_active', true)->orderBy('normalized_name')->get(['id', 'name']));
    }
}
