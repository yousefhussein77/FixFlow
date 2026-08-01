<?php

namespace App\Enums;

enum UserRole: string
{
    case Reporter = 'reporter';
    case Technician = 'technician';
    case Administrator = 'administrator';

    /** @return list<string> */
    public static function publiclyRequestable(): array
    {
        return [self::Reporter->value, self::Technician->value];
    }
}
