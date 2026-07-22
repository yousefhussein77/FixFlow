<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('departments', function (Blueprint $table): void {
            $table->id();
            $table->string('name', 120);
            $table->string('normalized_name', 120)->unique();
            $table->boolean('is_active')->default(true);
            $table->unsignedInteger('version')->default(1);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('departments');
    }
};
