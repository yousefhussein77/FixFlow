<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('categories', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('department_id')->constrained()->restrictOnDelete();
            $table->string('name', 120);
            $table->string('normalized_name', 120);
            $table->boolean('is_active')->default(true);
            $table->unsignedInteger('version')->default(1);
            $table->timestamps();
            $table->unique(['department_id', 'normalized_name']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('categories');
    }
};
