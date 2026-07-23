<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ticket_photos', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('ticket_id')->constrained()->cascadeOnDelete();
            $table->string('disk', 40);
            $table->string('path')->unique();
            $table->string('original_name');
            $table->string('mime_type', 50);
            $table->unsignedBigInteger('size');
            $table->unsignedTinyInteger('position');
            $table->timestamps();
            $table->unique(['ticket_id', 'position']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ticket_photos');
    }
};
