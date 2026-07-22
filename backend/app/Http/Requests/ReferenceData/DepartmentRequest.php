<?php

namespace App\Http\Requests\ReferenceData;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class DepartmentRequest extends FormRequest
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

        return ['name' => ['required', 'string', 'min:1', 'max:120'], 'normalized_name' => ['required', Rule::unique('departments', 'normalized_name')->ignore($id)], 'version' => $this->isMethod('put') ? ['required', 'integer', 'min:1'] : ['prohibited']];
    }
}
