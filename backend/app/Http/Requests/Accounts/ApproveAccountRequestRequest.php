<?php

namespace App\Http\Requests\Accounts;

use App\Http\Requests\Concerns\RejectsUnexpectedFields;
use Illuminate\Foundation\Http\FormRequest;

class ApproveAccountRequestRequest extends FormRequest
{
    use RejectsUnexpectedFields;

    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [];
    }

    protected function allowedInputKeys(): array
    {
        return [];
    }
}
