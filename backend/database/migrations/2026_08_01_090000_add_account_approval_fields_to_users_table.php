<?php

use App\Enums\AccountStatus;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table): void {
            $table->enum('account_status', array_column(AccountStatus::cases(), 'value'))
                ->default(AccountStatus::Approved->value)
                ->after('is_active')
                ->index();
            $table->foreignId('approved_by')->nullable()->after('account_status')->constrained('users')->nullOnDelete();
            $table->timestamp('approved_at')->nullable()->after('approved_by');
            $table->foreignId('rejected_by')->nullable()->after('approved_at')->constrained('users')->nullOnDelete();
            $table->timestamp('rejected_at')->nullable()->after('rejected_by');
            $table->string('rejection_reason', 1000)->nullable()->after('rejected_at');
        });

        DB::table('users')->where('is_active', false)->update([
            'account_status' => AccountStatus::Inactive->value,
        ]);
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table): void {
            $table->dropForeign(['approved_by']);
            $table->dropForeign(['rejected_by']);
            $table->dropIndex(['account_status']);
            $table->dropColumn([
                'account_status',
                'approved_by',
                'approved_at',
                'rejected_by',
                'rejected_at',
                'rejection_reason',
            ]);
        });
    }
};
