<?php

namespace App\Http\Requests\ReferenceData;

use Illuminate\Foundation\Http\FormRequest;

class VersionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return ['version' => ['required', 'integer', 'min:1']];
    }
}
