<?php

namespace Tests\Feature;

use Tests\TestCase;

class HealthTest extends TestCase
{
    public function test_the_foundation_health_endpoint_is_ready(): void
    {
        $response = $this->get('/up');

        $response
            ->assertOk()
            ->assertHeader('Content-Type', 'text/html; charset=UTF-8');
    }
}
