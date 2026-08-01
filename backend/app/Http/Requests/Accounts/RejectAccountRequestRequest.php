<?php

namespace App\Http\Requests\Accounts;

use App\Http\Requests\Concerns\RejectsUnexpectedFields;
use Illuminate\Foundation\Http\FormRequest;

class RejectAccountRequestRequest extends FormRequest
{
    use RejectsUnexpectedFields;

    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        if (is_string($this->input('rejection_reason'))) {
            $this->merge([
                'rejection_reason' => preg_replace('/\s+/u', ' ', trim($this->input('rejection_reason'))),
            ]);
        }
    }

    public function rules(): array
    {
        return ['rejection_reason' => ['nullable', 'string', 'max:1000']];
    }

    protected function allowedInputKeys(): array
    {
        return ['rejection_reason'];
    }

    public function messages(): array
    {
        return ['rejection_reason.max' => 'يجب ألا يزيد سبب الرفض عن 1000 حرف.'];
    }
}
