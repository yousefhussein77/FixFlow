<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\DepartmentController;
use App\Http\Controllers\Api\ReferenceOptionController;
use App\Http\Controllers\Api\TicketController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware(['auth:sanctum', 'active'])->group(function (): void {
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/options/departments', [ReferenceOptionController::class, 'departments']);
    Route::get('/options/departments/{departmentId}/categories', [ReferenceOptionController::class, 'categories']);

    Route::prefix('reporter')->middleware('reporter')->group(function (): void {
        Route::get('/options/departments', [ReferenceOptionController::class, 'departments']);
        Route::get('/options/departments/{departmentId}/categories', [ReferenceOptionController::class, 'categories']);
        Route::get('/tickets', [TicketController::class, 'index']);
        Route::post('/tickets', [TicketController::class, 'store']);
        Route::get('/tickets/{reference}', [TicketController::class, 'show']);
    });

    Route::prefix('admin')->middleware('administrator')->group(function (): void {
        Route::get('/departments', [DepartmentController::class, 'index']);
        Route::post('/departments', [DepartmentController::class, 'store']);
        Route::get('/departments/{id}', [DepartmentController::class, 'show']);
        Route::put('/departments/{id}', [DepartmentController::class, 'update']);
        Route::patch('/departments/{id}/activate', [DepartmentController::class, 'activate']);
        Route::patch('/departments/{id}/deactivate', [DepartmentController::class, 'deactivate']);
        Route::get('/categories', [CategoryController::class, 'index']);
        Route::post('/categories', [CategoryController::class, 'store']);
        Route::get('/categories/{id}', [CategoryController::class, 'show']);
        Route::put('/categories/{id}', [CategoryController::class, 'update']);
        Route::patch('/categories/{id}/activate', [CategoryController::class, 'activate']);
        Route::patch('/categories/{id}/deactivate', [CategoryController::class, 'deactivate']);
    });
});
