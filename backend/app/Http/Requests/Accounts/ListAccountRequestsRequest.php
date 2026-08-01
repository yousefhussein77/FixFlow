<?php

namespace App\Http\Requests\Accounts;

use App\Enums\AccountStatus;
use App\Http\Requests\Concerns\RejectsUnexpectedFields;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ListAccountRequestsRequest extends FormRequest
{
    use RejectsUnexpectedFields;

    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $this->merge(['status' => $this->input('status', AccountStatus::Pending->value)]);
    }

    public function rules(): array
    {
        return [
            'status' => [
                'required',
                'string',
                Rule::in([...array_column(AccountStatus::cases(), 'value'), 'all']),
            ],
        ];
    }

    protected function allowedInputKeys(): array
    {
        return ['status'];
    }
}
