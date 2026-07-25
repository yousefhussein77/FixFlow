<?php

namespace App\Http\Controllers\Api;

use App\Actions\Tickets\ListActiveTechnicians;
use App\Http\Controllers\Controller;
use App\Http\Resources\TechnicianOptionResource;
use App\Support\ApiResponse;
use App\Support\TicketEvent;
use Illuminate\Http\JsonResponse;

class AdminTechnicianOptionController extends Controller
{
    public function __invoke(ListActiveTechnicians $action): JsonResponse
    {
        $users = $action->execute();
        TicketEvent::record('ticket.technician_options', 'allowed', request()->user()->id);

        return ApiResponse::success('Technicians retrieved.', TechnicianOptionResource::collection($users)->resolve(request()));
    }
}
