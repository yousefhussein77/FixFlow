<?php

use App\Http\Controllers\Api\AdminAccountRequestController;
use App\Http\Controllers\Api\AdminTechnicianOptionController;
use App\Http\Controllers\Api\AdminTicketCommentController;
use App\Http\Controllers\Api\AdminTicketController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\DepartmentController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ReferenceOptionController;
use App\Http\Controllers\Api\ReporterTicketCommentController;
use App\Http\Controllers\Api\ReporterTicketRatingController;
use App\Http\Controllers\Api\TechnicianTicketCommentController;
use App\Http\Controllers\Api\TechnicianTicketController;
use App\Http\Controllers\Api\TicketController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware(['auth:sanctum', 'active'])->group(function (): void {
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
    Route::patch('/notifications/read-all', [NotificationController::class, 'readAll']);
    Route::patch('/notifications/{notification}/read', [NotificationController::class, 'read'])
        ->whereNumber('notification');
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
        Route::get('/tickets/{reference}/comments', [ReporterTicketCommentController::class, 'index']);
        Route::post('/tickets/{reference}/comments', [ReporterTicketCommentController::class, 'store']);
        Route::post('/tickets/{reference}/rating', [ReporterTicketRatingController::class, 'store']);
    });

    Route::prefix('admin')->middleware('administrator')->group(function (): void {
        Route::get('/account-requests', [AdminAccountRequestController::class, 'index']);
        Route::patch('/account-requests/{account}/approve', [AdminAccountRequestController::class, 'approve']);
        Route::patch('/account-requests/{account}/reject', [AdminAccountRequestController::class, 'reject']);
        Route::get('/tickets', [AdminTicketController::class, 'index']);
        Route::get('/options/technicians', AdminTechnicianOptionController::class);
        Route::patch('/tickets/{reference}/assignment', [AdminTicketController::class, 'assign']);
        Route::get('/tickets/{reference}/comments', [AdminTicketCommentController::class, 'index']);
        Route::post('/tickets/{reference}/comments', [AdminTicketCommentController::class, 'store']);
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

    Route::prefix('technician')->middleware('technician')->group(function (): void {
        Route::get('/tickets', [TechnicianTicketController::class, 'index']);
        Route::get('/tickets/{reference}', [TechnicianTicketController::class, 'show']);
        Route::patch('/tickets/{reference}/status', [TechnicianTicketController::class, 'transition']);
        Route::get('/tickets/{reference}/comments', [TechnicianTicketCommentController::class, 'index']);
        Route::post('/tickets/{reference}/comments', [TechnicianTicketCommentController::class, 'store']);
    });
});
