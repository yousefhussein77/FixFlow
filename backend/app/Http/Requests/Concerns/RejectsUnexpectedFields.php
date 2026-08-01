<?php

namespace App\Http\Requests\Concerns;

use Illuminate\Validation\Validator;

trait RejectsUnexpectedFields
{
    /** @return list<string> */
    abstract protected function allowedInputKeys(): array;

    /** @return list<callable> */
    public function after(): array
    {
        return [function (Validator $validator): void {
            $unexpected = array_diff(array_keys($this->all()), $this->allowedInputKeys());
            foreach ($unexpected as $field) {
                $validator->errors()->add($field, 'هذا الحقل غير مدعوم.');
            }
        }];
    }
}
