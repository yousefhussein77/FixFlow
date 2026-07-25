<?php

namespace App\Http\Requests\Tickets;

use App\Models\Ticket;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Validator;

class TransitionTicketStatusRequest extends FormRequest
{
    protected function prepareForValidation(): void
    {
        if (is_string($this->input('reason'))) {
            $this->merge(['reason' => trim($this->input('reason'))]);
        }
    }

    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'status' => ['required', 'string', Rule::in([Ticket::STATUS_IN_PROGRESS, Ticket::STATUS_COMPLETED, Ticket::STATUS_REJECTED])],
            'reason' => [Rule::prohibitedIf(fn (): bool => $this->input('status') !== Ticket::STATUS_REJECTED), Rule::requiredIf(fn (): bool => $this->input('status') === Ticket::STATUS_REJECTED), 'nullable', 'string', 'max:1000'],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator): void {
            foreach (array_diff(array_keys($this->all()), ['status', 'reason']) as $field) {
                $validator->errors()->add($field, 'This field is not supported.');
            }
        });
    }
}
