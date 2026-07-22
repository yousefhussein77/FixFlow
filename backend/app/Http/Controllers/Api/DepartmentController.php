<?php

namespace App\Http\Controllers\Api;

use App\Actions\ReferenceData\ManageDepartment;
use App\Http\Controllers\Controller;
use App\Http\Requests\ReferenceData\DepartmentRequest;
use App\Http\Requests\ReferenceData\VersionRequest;
use App\Http\Resources\DepartmentResource;
use App\Models\Department;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;

class DepartmentController extends Controller
{
    public function index(): JsonResponse
    {
        return ApiResponse::success('Departments retrieved.', DepartmentResource::collection(Department::orderBy('normalized_name')->get()));
    }

    public function store(DepartmentRequest $r, ManageDepartment $a): JsonResponse
    {
        return ApiResponse::success('Department created.', new DepartmentResource($a->create($r->validated())), 201);
    }

    public function show(int $id): JsonResponse
    {
        return ApiResponse::success('Department retrieved.', new DepartmentResource(Department::findOrFail($id)));
    }

    public function update(DepartmentRequest $r, int $id, ManageDepartment $a): JsonResponse
    {
        $v = $a->update(Department::findOrFail($id), $r->validated());

        return $v instanceof JsonResponse ? $v : ApiResponse::success('Department updated.', new DepartmentResource($v));
    }

    public function activate(VersionRequest $r, int $id, ManageDepartment $a): JsonResponse
    {
        return $this->status($r, $id, $a, true);
    }

    public function deactivate(VersionRequest $r, int $id, ManageDepartment $a): JsonResponse
    {
        return $this->status($r, $id, $a, false);
    }

    private function status(VersionRequest $r, int $id, ManageDepartment $a, bool $active): JsonResponse
    {
        $v = $a->status(Department::findOrFail($id), $active, (int) $r->validated('version'));

        return $v instanceof JsonResponse ? $v : ApiResponse::success($active ? 'Department activated.' : 'Department deactivated.',new DepartmentResource($v));
    }
}
