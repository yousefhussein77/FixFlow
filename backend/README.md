# FixFlow API

## Authentication API

FixFlow exposes a Sanctum bearer-token authentication API:

- `POST /api/register` creates a pending reporter or technician request and never returns a token. Required fields are `name`, `email`, `password`, and `password_confirmation`; optional `role` defaults to `reporter`.
- `POST /api/login` signs in only an approved active account with email and password.
- `GET /api/profile` returns only the bearer token owner's profile.
- `POST /api/logout` revokes only the bearer token used for the request.

Registration passwords are 12–128 characters, require mixed-case letters and a number, and must match confirmation. Names and emails are normalized before validation and storage. Administrators review requests through `GET /api/admin/account-requests` and the corresponding `approve` and `reject` routes. See [`docs/account-approval.md`](../docs/account-approval.md) for the lifecycle, validation, endpoints, and migration behavior.

Run `php artisan test`, `composer validate --strict`, and `vendor\\bin\\pint --test` before integration. The development seeder creates approved reporter, technician, administrator, and inactive fixtures with the factory's development-only password; public registration never creates administrator users.

## In-app notifications

Authenticated users receive role-specific, Arabic in-app notifications for supported account and ticket events. See [`docs/notifications.md`](../docs/notifications.md) for endpoints, transaction and deduplication guarantees, event mappings, and client behavior.

## Reference data API

Administrators manage retained departments and categories under `/api/admin`. Every update supplies the current integer `version`; stale changes return `409`. Authenticated users load new-work choices from `/api/options/departments` and `/api/options/departments/{id}/categories`. There are no permanent-delete endpoints.

<p align="center"><a href="https://laravel.com" target="_blank"><img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo"></a></p>

<p align="center">
<a href="https://github.com/laravel/framework/actions"><img src="https://github.com/laravel/framework/workflows/tests/badge.svg" alt="Build Status"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/dt/laravel/framework" alt="Total Downloads"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/v/laravel/framework" alt="Latest Stable Version"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/l/laravel/framework" alt="License"></a>
</p>

## About Laravel

Laravel is a web application framework with expressive, elegant syntax. We believe development must be an enjoyable and creative experience to be truly fulfilling. Laravel takes the pain out of development by easing common tasks used in many web projects, such as:

- [Simple, fast routing engine](https://laravel.com/docs/routing).
- [Powerful dependency injection container](https://laravel.com/docs/container).
- Multiple back-ends for [session](https://laravel.com/docs/session) and [cache](https://laravel.com/docs/cache) storage.
- Expressive, intuitive [database ORM](https://laravel.com/docs/eloquent).
- Database agnostic [schema migrations](https://laravel.com/docs/migrations).
- [Robust background job processing](https://laravel.com/docs/queues).
- [Real-time event broadcasting](https://laravel.com/docs/broadcasting).

Laravel is accessible, powerful, and provides tools required for large, robust applications.

## Learning Laravel

Laravel has the most extensive and thorough [documentation](https://laravel.com/docs) and video tutorial library of all modern web application frameworks, making it a breeze to get started with the framework.

In addition, [Laracasts](https://laracasts.com) contains thousands of video tutorials on a range of topics including Laravel, modern PHP, unit testing, and JavaScript. Boost your skills by digging into our comprehensive video library.

You can also watch bite-sized lessons with real-world projects on [Laravel Learn](https://laravel.com/learn), where you will be guided through building a Laravel application from scratch while learning PHP fundamentals.

## Agentic Development

Laravel's predictable structure and conventions make it ideal for AI coding agents like Claude Code, Cursor, and GitHub Copilot. Install [Laravel Boost](https://laravel.com/docs/ai) to supercharge your AI workflow:

```bash
composer require laravel/boost --dev

php artisan boost:install
```

Boost provides your agent 15+ tools and skills that help agents build Laravel applications while following best practices.

## Contributing

Thank you for considering contributing to the Laravel framework! The contribution guide can be found in the [Laravel documentation](https://laravel.com/docs/contributions).

## Code of Conduct

In order to ensure that the Laravel community is welcoming to all, please review and abide by the [Code of Conduct](https://laravel.com/docs/contributions#code-of-conduct).

## Security Vulnerabilities

If you discover a security vulnerability within Laravel, please send an e-mail to Taylor Otwell via [taylor@laravel.com](mailto:taylor@laravel.com). All security vulnerabilities will be promptly addressed.

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
