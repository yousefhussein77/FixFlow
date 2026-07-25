<?php

namespace App\Models;

use Database\Factories\TicketRatingFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use LogicException;

class TicketRating extends Model
{
    /** @use HasFactory<TicketRatingFactory> */
    use HasFactory;

    public const UPDATED_AT = null;

    protected $fillable = ['ticket_id', 'reporter_id', 'submission_token', 'value', 'created_at'];

    protected function casts(): array
    {
        return ['value' => 'integer', 'created_at' => 'immutable_datetime'];
    }

    protected static function booted(): void
    {
        static::updating(fn () => throw new LogicException('Ticket ratings are immutable.'));
        static::deleting(fn () => throw new LogicException('Ticket ratings are immutable.'));
    }

    public function ticket(): BelongsTo
    {
        return $this->belongsTo(Ticket::class);
    }

    public function reporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reporter_id');
    }
}
