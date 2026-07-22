<?php

use Illuminate\Contracts\Console\Kernel;

require dirname(__DIR__).'/vendor/autoload.php';

$app = require dirname(__DIR__).'/bootstrap/app.php';
$app->make(Kernel::class)->bootstrap();

try {
    $result = $app['db']->connection('mysql')->selectOne(
        'SELECT DATABASE() AS database_name, '
        .'@@character_set_database AS charset_name, '
        .'@@collation_database AS collation_name, '
        .'VERSION() AS server_version, '
        .'CURRENT_USER() AS authenticated_account'
    );

    echo json_encode($result, JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES).PHP_EOL;
} catch (Throwable $exception) {
    $diagnostic = str_contains($exception->getMessage(), 'Access denied')
        ? 'authentication_failure'
        : 'database_connection_failure';

    fwrite(STDERR, $diagnostic.PHP_EOL);
    exit(1);
}
