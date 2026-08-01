<?php

namespace App\Models;

use App\Enums\AccountStatus;
use App\Enums\UserRole;
use App\Support\AccountInputNormalizer;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    public const ROLE_REPORTER = UserRole::Reporter->value;

    public const ROLE_TECHNICIAN = UserRole::Technician->value;

    public const ROLE_ADMINISTRATOR = UserRole::Administrator->value;

    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
            'is_active' => 'boolean',
            'account_status' => AccountStatus::class,
            'approved_at' => 'datetime',
            'rejected_at' => 'datetime',
        ];
    }

    public function setNameAttribute(mixed $value): void
    {
        $this->attributes['name'] = AccountInputNormalizer::name($value);
    }

    public function setEmailAttribute(mixed $value): void
    {
        $this->attributes['email'] = AccountInputNormalizer::email($value);
    }

    public function isApproved(): bool
    {
        return $this->is_active && $this->account_status === AccountStatus::Approved;
    }

    public function approver(): BelongsTo
    {
        return $this->belongsTo(self::class, 'approved_by');
    }

    public function rejector(): BelongsTo
    {
        return $this->belongsTo(self::class, 'rejected_by');
    }

    public function tickets(): HasMany
    {
        return $this->hasMany(Ticket::class, 'reporter_id');
    }

    public function assignedTickets(): HasMany
    {
        return $this->hasMany(Ticket::class, 'assigned_technician_id');
    }

    public function ticketComments(): HasMany
    {
        return $this->hasMany(TicketComment::class, 'author_id');
    }

    public function ticketRatings(): HasMany
    {
        return $this->hasMany(TicketRating::class, 'reporter_id');
    }

    public function notifications(): HasMany
    {
        return $this->hasMany(Notification::class, 'recipient_user_id');
    }
}
