<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('tickets', function (Blueprint $table): void {
            $table->foreignId('assigned_technician_id')->nullable()->after('status')->constrained('users')->restrictOnDelete();
            $table->index(['assigned_technician_id', 'created_at', 'id']);
        });
    }

    public function down(): void
    {
        Schema::table('tickets', function (Blueprint $table): void {
            $table->dropIndex(['assigned_technician_id', 'created_at', 'id']);
            $table->dropConstrainedForeignId('assigned_technician_id');
        });
    }
};
