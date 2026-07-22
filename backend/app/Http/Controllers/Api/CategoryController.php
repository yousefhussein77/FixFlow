<?php

namespace App\Http\Controllers\Api;

use App\Actions\ReferenceData\ManageCategory;
use App\Http\Controllers\Controller;
use App\Http\Requests\ReferenceData\CategoryRequest;
use App\Http\Requests\ReferenceData\VersionRequest;
use App\Http\Resources\CategoryResource;
use App\Models\Category;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;

class CategoryController extends Controller
{
    public function index(): JsonResponse
    {
        return ApiResponse::success('Categories retrieved.', CategoryResource::collection(Category::with('department')->orderBy('normalized_name')->get()));
    }

    public function store(CategoryRequest $r, ManageCategory $a): JsonResponse
    {
        return ApiResponse::success('Category created.', new CategoryResource($a->create($r->validated())), 201);
    }

    public function show(int $id): JsonResponse
    {
        return ApiResponse::success('Category retrieved.', new CategoryResource(Category::with('department')->findOrFail($id)));
    }

    public function update(CategoryRequest $r, int $id, ManageCategory $a): JsonResponse
    {
        $v = $a->update(Category::findOrFail($id), $r->validated());

        return $v instanceof JsonResponse ? $v : ApiResponse::success('Category updated.', new CategoryResource($v));
    }

    public function activate(VersionRequest $r, int $id, ManageCategory $a): JsonResponse
    {
        return $this->status($r, $id, $a, true);
    }

    public function deactivate(VersionRequest $r, int $id, ManageCategory $a): JsonResponse
    {
        return $this->status($r, $id, $a, false);
    }

    private function status(VersionRequest $r, int $id, ManageCategory $a, bool $active): JsonResponse
    {
        $v = $a->status(Category::findOrFail($id), $active, (int) $r->validated('version'));

        return $v instanceof JsonResponse ? $v : ApiResponse::success($active ? 'Category activated.' : 'Category deactivated.',new CategoryResource($v));
    }
}
