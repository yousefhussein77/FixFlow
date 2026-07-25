<?php

namespace App\Http\Controllers\Api;

use App\Actions\Tickets\ListTechnicianTickets;
use App\Actions\Tickets\TransitionTicketStatus;
use App\Exceptions\StatusTransitionConflictException;
use App\Exceptions\TicketNotFoundException;
use App\Http\Controllers\Controller;
use App\Http\Requests\Tickets\TechnicianListTicketsRequest;
use App\Http\Requests\Tickets\TransitionTicketStatusRequest;
use App\Http\Resources\TechnicianTicketResource;
use App\Http\Resources\TechnicianTicketSummaryResource;
use App\Models\Ticket;
use App\Support\ApiResponse;
use App\Support\TicketEvent;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Throwable;

class TechnicianTicketController extends Controller
{
    public function index(TechnicianListTicketsRequest $request, ListTechnicianTickets $action): JsonResponse
    {
        $page = $action->execute($request->user(), $request->integer('per_page', 20));
        TicketEvent::record('ticket.technician_list', 'allowed', $request->user()->id);

        return ApiResponse::success('Assigned tickets retrieved.', TechnicianTicketSummaryResource::collection($page->items())->resolve($request), meta: ['current_page' => $page->currentPage(), 'per_page' => $page->perPage(), 'total' => $page->total(), 'last_page' => $page->lastPage()]);
    }

    public function show(Request $request, string $reference): JsonResponse
    {
        $ticket = $this->ownedTicket($request, $reference);
        if (! $ticket) {
            return $this->notFound($request);
        }
        TicketEvent::record('ticket.technician_detail', 'allowed', $request->user()->id, $reference);

        return ApiResponse::success('Assigned ticket retrieved.', (new TechnicianTicketResource($ticket))->resolve($request));
    }

    public function transition(TransitionTicketStatusRequest $request, string $reference, TransitionTicketStatus $action): JsonResponse
    {
        try {
            $ticket = $action->execute($request->user(), $reference, $request->string('status')->toString(), $request->input('reason'));
            TicketEvent::record('ticket.technician_transition', 'accepted', $request->user()->id, $reference);

            return ApiResponse::success('Ticket status updated.', (new TechnicianTicketResource($ticket))->resolve($request));
        } catch (TicketNotFoundException) {
            return $this->notFound($request);
        } catch (StatusTransitionConflictException) {
            TicketEvent::record('ticket.technician_transition', 'conflict', $request->user()->id, $reference);

            return ApiResponse::error('The ticket status changed. Refresh and review its current state.', 'STATUS_TRANSITION_CONFLICT', 409);
        } catch (Throwable) {
            TicketEvent::record('ticket.technician_transition', 'failed', $request->user()->id, $reference);

            return ApiResponse::error('An unexpected server error occurred.', 'SERVER_ERROR', 500);
        }
    }

    private function ownedTicket(Request $request, string $reference): ?Ticket
    {
        return Ticket::query()->where('reference', $reference)->where('assigned_technician_id', $request->user()->id)
            ->with(['department', 'category', 'photos', 'assignedTechnician', 'statusHistories.actor', 'statusHistories.assignedTechnician'])->first();
    }

    private function notFound(Request $request): JsonResponse
    {
        TicketEvent::record('ticket.technician_target', 'concealed_not_found', $request->user()->id);

        return ApiResponse::error('Ticket not found.', 'TICKET_NOT_FOUND', 404);
    }
}
