<?php

namespace App\Http\Requests\Tickets;

use App\Models\Category;
use App\Models\Department;
use App\Models\Ticket;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CreateTicketRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $values = [];
        foreach (['title', 'description', 'location'] as $field) {
            if (is_string($this->input($field))) {
                $values[$field] = trim($this->input($field));
            }
        }
        $this->merge($values);
    }

    public function rules(): array
    {
        return [
            'submission_token' => ['required', 'uuid'],
            'title' => ['required', 'string', 'max:160', 'regex:/\S/u'],
            'description' => ['required', 'string', 'max:5000', 'regex:/\S/u'],
            'department_id' => ['required', 'integer', Rule::exists(Department::class, 'id')->where('is_active', true)],
            'category_id' => ['required', 'integer', function (string $attribute, mixed $value, \Closure $fail): void {
                if (! Category::query()->whereKey($value)->where('department_id', $this->integer('department_id'))->where('is_active', true)->whereHas('department', fn ($q) => $q->where('is_active', true))->exists()) {
                    $fail('The selected category is invalid for this department.');
                }
            }],
            'priority' => ['required', Rule::in(Ticket::PRIORITIES)],
            'location' => ['required', 'string', 'max:255', 'regex:/\S/u'],
            'photos' => ['sometimes', 'array', 'max:5'],
            'photos.*' => ['file', 'max:10240', 'mimetypes:image/jpeg,image/png,image/webp'],
        ];
    }
}
