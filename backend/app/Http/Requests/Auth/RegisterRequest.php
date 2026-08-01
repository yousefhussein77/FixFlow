<?php

namespace App\Http\Requests\Auth;

use App\Enums\UserRole;
use App\Http\Requests\Concerns\RejectsUnexpectedFields;
use App\Models\User;
use App\Support\AccountInputNormalizer;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;

class RegisterRequest extends FormRequest
{
    use RejectsUnexpectedFields;

    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'name' => AccountInputNormalizer::name($this->input('name')),
            'email' => AccountInputNormalizer::email($this->input('email')),
            'role' => $this->input('role', User::ROLE_REPORTER),
        ]);
    }

    public function rules(): array
    {
        return [
            'name' => [
                'required',
                'string',
                'min:2',
                'max:100',
                'regex:/^[A-Za-z\x{0621}-\x{063A}\x{0641}-\x{064A}\x{066E}-\x{06D3}\x{064B}-\x{065F}\x{0670}]+(?:[ \-\'’][A-Za-z\x{0621}-\x{063A}\x{0641}-\x{064A}\x{066E}-\x{06D3}\x{064B}-\x{065F}\x{0670}]+)*$/u',
            ],
            'email' => [
                'required',
                'string',
                'email:rfc',
                'max:255',
                Rule::unique('users', 'email'),
            ],
            'role' => ['required', 'string', Rule::in(UserRole::publiclyRequestable())],
            'password' => [
                'required',
                'string',
                'max:128',
                Password::min(12)->letters()->mixedCase()->numbers(),
                'confirmed',
            ],
        ];
    }

    protected function allowedInputKeys(): array
    {
        return ['name', 'email', 'role', 'password', 'password_confirmation'];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'الاسم مطلوب.',
            'name.min' => 'يجب ألا يقل الاسم عن حرفين.',
            'name.max' => 'يجب ألا يزيد الاسم عن 100 حرف.',
            'name.regex' => 'استخدم حروفًا عربية أو إنجليزية ومسافات أو شرطات أو فواصل عليا فقط.',
            'email.required' => 'البريد الإلكتروني مطلوب.',
            'email.email' => 'أدخل بريدًا إلكترونيًا صحيحًا.',
            'email.max' => 'البريد الإلكتروني طويل جدًا.',
            'email.unique' => 'يوجد حساب مسجل بهذا البريد الإلكتروني.',
            'role.in' => 'نوع الحساب المطلوب غير مدعوم.',
            'password.required' => 'كلمة المرور مطلوبة.',
            'password.min' => 'يجب ألا تقل كلمة المرور عن 12 حرفًا.',
            'password.max' => 'كلمة المرور طويلة جدًا.',
            'password.letters' => 'يجب أن تحتوي كلمة المرور على حرف واحد على الأقل.',
            'password.mixed' => 'يجب أن تحتوي كلمة المرور على حرف كبير وحرف صغير.',
            'password.numbers' => 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل.',
            'password.confirmed' => 'تأكيد كلمة المرور غير مطابق.',
        ];
    }
}
