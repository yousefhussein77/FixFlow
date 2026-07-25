<?php

namespace App\Http\Requests\Tickets;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Validator;

class CreateTicketRatingRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return ['rating' => ['required', 'integer', 'between:1,5'], 'submission_token' => ['required', 'uuid']];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator): void {
            if ($this->has('rating') && ! is_int($this->input('rating'))) {
                $validator->errors()->add('rating', 'The rating must be a whole number from 1 to 5.');
            }
            foreach (array_diff(array_keys($this->all()), ['rating', 'submission_token']) as $field) {
                $validator->errors()->add($field, 'This field is not supported.');
            }
        });
    }
}
