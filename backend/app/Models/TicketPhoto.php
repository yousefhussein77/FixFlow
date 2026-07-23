<?php

namespace App\Models;

use Database\Factories\TicketPhotoFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TicketPhoto extends Model
{
    /** @use HasFactory<TicketPhotoFactory> */
    use HasFactory;

    protected $fillable = ['ticket_id', 'disk', 'path', 'original_name', 'mime_type', 'size', 'position'];

    protected function casts(): array
    {
        return ['size' => 'integer', 'position' => 'integer'];
    }

    public function ticket(): BelongsTo
    {
        return $this->belongsTo(Ticket::class);
    }
}
