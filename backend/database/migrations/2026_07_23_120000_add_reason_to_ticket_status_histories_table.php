<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('ticket_status_histories', function (Blueprint $table): void {
            $table->string('reason', 1000)->nullable()->after('assigned_technician_id');
        });
    }

    public function down(): void
    {
        Schema::table('ticket_status_histories', function (Blueprint $table): void {
            $table->dropColumn('reason');
        });
    }
};
