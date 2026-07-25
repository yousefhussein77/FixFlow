<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ticket_ratings', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('ticket_id')->unique()->constrained()->restrictOnDelete();
            $table->foreignId('reporter_id')->constrained('users')->restrictOnDelete();
            $table->uuid('submission_token');
            $table->unsignedTinyInteger('value');
            $table->timestamp('created_at');
            $table->unique(['ticket_id', 'reporter_id', 'submission_token']);
        });

        if (DB::getDriverName() === 'sqlite') {
            DB::statement("CREATE TRIGGER ticket_ratings_value_insert BEFORE INSERT ON ticket_ratings WHEN NEW.value < 1 OR NEW.value > 5 BEGIN SELECT RAISE(ABORT, 'ticket rating must be between 1 and 5'); END");
            DB::statement("CREATE TRIGGER ticket_ratings_value_update BEFORE UPDATE OF value ON ticket_ratings WHEN NEW.value < 1 OR NEW.value > 5 BEGIN SELECT RAISE(ABORT, 'ticket rating must be between 1 and 5'); END");
        } else {
            DB::statement('ALTER TABLE ticket_ratings ADD CONSTRAINT ticket_ratings_value_check CHECK (value BETWEEN 1 AND 5)');
        }
    }

    public function down(): void
    {
        if (DB::getDriverName() === 'sqlite') {
            DB::statement('DROP TRIGGER IF EXISTS ticket_ratings_value_insert');
            DB::statement('DROP TRIGGER IF EXISTS ticket_ratings_value_update');
        }
        Schema::dropIfExists('ticket_ratings');
    }
};
