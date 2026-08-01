<?php

namespace App\Support;

use Illuminate\Support\Str;

final class AccountInputNormalizer
{
    public static function name(mixed $value): mixed
    {
        if (! is_string($value)) {
            return $value;
        }

        return preg_replace('/\s+/u', ' ', trim($value)) ?? trim($value);
    }

    public static function email(mixed $value): mixed
    {
        return is_string($value) ? Str::lower(trim($value)) : $value;
    }
}
