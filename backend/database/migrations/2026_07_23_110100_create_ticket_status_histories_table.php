<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ticket_status_histories', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('ticket_id')->constrained()->restrictOnDelete();
            $table->string('from_status', 30);
            $table->string('to_status', 30);
            $table->foreignId('actor_id')->constrained('users')->restrictOnDelete();
            $table->foreignId('assigned_technician_id')->constrained('users')->restrictOnDelete();
            $table->timestamp('occurred_at');
            $table->timestamp('created_at')->useCurrent();
            $table->index(['ticket_id', 'occurred_at', 'id']);
            $table->index('actor_id');
            $table->index('assigned_technician_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ticket_status_histories');
    }
};
