<?php

namespace App\Http\Requests\ReferenceData;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CategoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        if (is_string($this->name)) {
            $this->merge(['name' => trim($this->name), 'normalized_name' => mb_strtolower(trim($this->name))]);
        }
    }

    public function rules(): array
    {
        $id = $this->route('id');

        return ['department_id' => ['required', 'integer', Rule::exists('departments', 'id')->where(fn ($q) => $q->where('is_active', true))], 'name' => ['required', 'string', 'min:1', 'max:120'], 'normalized_name' => ['required', Rule::unique('categories', 'normalized_name')->where(fn ($q) => $q->where('department_id', $this->department_id))->ignore($id)], 'version' => $this->isMethod('put') ? ['required', 'integer', 'min:1'] : ['prohibited']];
    }
}
