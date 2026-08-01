<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifications', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('recipient_user_id')->constrained('users')->cascadeOnDelete();
            $table->string('type', 80);
            $table->string('title', 160);
            $table->string('message', 500);
            $table->string('related_entity_type', 40)->nullable();
            $table->unsignedBigInteger('related_entity_id')->nullable();
            $table->string('navigation_target', 80);
            $table->json('payload')->nullable();
            $table->string('deduplication_key', 191);
            $table->timestamp('read_at')->nullable();
            $table->timestamps();

            $table->unique(['recipient_user_id', 'deduplication_key']);
            $table->index(['recipient_user_id', 'read_at']);
            $table->index(['recipient_user_id', 'created_at', 'id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};
