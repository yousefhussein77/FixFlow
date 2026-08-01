<?php

use App\Http\Middleware\EnsureUserIsActive;
use App\Http\Middleware\EnsureUserIsAdministrator;
use App\Http\Middleware\EnsureUserIsReporter;
use App\Http\Middleware\EnsureUserIsTechnician;
use App\Support\ApiResponse;
use App\Support\AuthEvent;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'active' => EnsureUserIsActive::class,
            'administrator' => EnsureUserIsAdministrator::class,
            'reporter' => EnsureUserIsReporter::class,
            'technician' => EnsureUserIsTechnician::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->render(function (ValidationException $exception, Request $request) {
            if ($request->is('api/*')) {
                AuthEvent::record('auth.request_validation', 'denied');

                return ApiResponse::error(
                    message: 'البيانات المدخلة غير صالحة.',
                    code: 'VALIDATION_ERROR',
                    status: 422,
                    errors: $exception->errors(),
                );
            }
        });

        $exceptions->render(function (AuthenticationException $exception, Request $request) {
            if ($request->is('api/*')) {
                AuthEvent::record('auth.protected_operation', 'unauthenticated');

                return ApiResponse::error(
                    message: 'يرجى تسجيل الدخول للمتابعة.',
                    code: 'UNAUTHENTICATED',
                    status: 401,
                );
            }
        });

        $exceptions->render(function (Throwable $exception, Request $request) {
            if ($request->is('api/*') && ! config('app.debug')) {
                return ApiResponse::error(
                    message: 'حدث خطأ غير متوقع. حاول مرة أخرى لاحقًا.',
                    code: 'SERVER_ERROR',
                    status: 500,
                );
            }
        });
    })->create();
