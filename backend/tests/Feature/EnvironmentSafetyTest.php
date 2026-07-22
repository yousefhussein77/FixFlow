<?php

namespace Tests\Feature;

use Tests\TestCase;

class EnvironmentSafetyTest extends TestCase
{
    public function test_the_example_environment_is_safe_and_complete(): void
    {
        $example = parse_ini_file(base_path('.env.example'), false, INI_SCANNER_RAW);

        $this->assertIsArray($example);
        $this->assertSame('FixFlow', $example['APP_NAME'] ?? null);
        $this->assertSame('local', $example['APP_ENV'] ?? null);
        $this->assertSame('', $example['APP_KEY'] ?? null);
        $this->assertSame('true', $example['APP_DEBUG'] ?? null);
        $this->assertSame('http://127.0.0.1:8000', $example['APP_URL'] ?? null);
        $this->assertSame('mysql', $example['DB_CONNECTION'] ?? null);
        $this->assertSame('127.0.0.1', $example['DB_HOST'] ?? null);
        $this->assertSame('3306', $example['DB_PORT'] ?? null);
        $this->assertSame('fixflow', $example['DB_DATABASE'] ?? null);
        $this->assertSame('fixflow_local', $example['DB_USERNAME'] ?? null);
        $this->assertSame('', $example['DB_PASSWORD'] ?? null);
    }

    public function test_real_environment_files_are_ignored_and_untracked(): void
    {
        $repository = dirname(__DIR__, 3);

        [$ignoreExitCode, $ignoreOutput] = $this->runGit(
            $repository,
            ['check-ignore', 'backend/.env'],
        );
        [$trackedExitCode, $trackedOutput] = $this->runGit(
            $repository,
            ['ls-files', '--', 'backend/.env'],
        );

        $this->assertSame(0, $ignoreExitCode, implode(PHP_EOL, $ignoreOutput));
        $this->assertSame(['backend/.env'], $ignoreOutput);
        $this->assertSame(0, $trackedExitCode, implode(PHP_EOL, $trackedOutput));
        $this->assertSame([], $trackedOutput, 'A real backend environment file is tracked.');
    }

    /**
     * @param  list<string>  $arguments
     * @return array{int, list<string>}
     */
    private function runGit(string $repository, array $arguments): array
    {
        $command = sprintf(
            'git -C %s %s 2>&1',
            escapeshellarg($repository),
            implode(' ', array_map(escapeshellarg(...), $arguments)),
        );
        $output = [];
        exec($command, $output, $exitCode);

        return [$exitCode, $output];
    }
}
