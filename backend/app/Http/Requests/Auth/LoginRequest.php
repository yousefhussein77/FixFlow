<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\Concerns\RejectsUnexpectedFields;
use App\Support\AccountInputNormalizer;
use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    use RejectsUnexpectedFields;

    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'email' => AccountInputNormalizer::email($this->input('email')),
        ]);
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'string', 'email:rfc', 'max:255'],
            'password' => ['required', 'string', 'max:128'],
        ];
    }

    protected function allowedInputKeys(): array
    {
        return ['email', 'password'];
    }

    public function messages(): array
    {
        return [
            'email.required' => 'البريد الإلكتروني مطلوب.',
            'email.email' => 'أدخل بريدًا إلكترونيًا صحيحًا.',
            'password.required' => 'كلمة المرور مطلوبة.',
        ];
    }
}
