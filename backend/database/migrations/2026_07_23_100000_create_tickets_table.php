<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tickets', function (Blueprint $table): void {
            $table->id();
            $table->string('reference', 16)->unique();
            $table->foreignId('reporter_id')->constrained('users')->restrictOnDelete();
            $table->foreignId('department_id')->constrained()->restrictOnDelete();
            $table->foreignId('category_id')->constrained()->restrictOnDelete();
            $table->uuid('submission_token');
            $table->string('title', 160);
            $table->text('description');
            $table->enum('priority', ['low', 'medium', 'high', 'urgent']);
            $table->string('location', 255);
            $table->string('status', 30)->default('new');
            $table->timestamps();
            $table->unique(['reporter_id', 'submission_token']);
            $table->index(['reporter_id', 'created_at', 'id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tickets');
    }
};
