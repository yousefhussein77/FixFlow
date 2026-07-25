<?php

namespace App\Http\Controllers\Api;

use App\Actions\Tickets\AssignTicket;
use App\Actions\Tickets\ListAdminTickets;
use App\Exceptions\AssignmentConflictException;
use App\Exceptions\TicketNotFoundException;
use App\Http\Controllers\Controller;
use App\Http\Requests\Tickets\AdminListTicketsRequest;
use App\Http\Requests\Tickets\AssignTicketRequest;
use App\Http\Resources\AdminTicketSummaryResource;
use App\Support\ApiResponse;
use App\Support\TicketEvent;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;
use Throwable;

class AdminTicketController extends Controller
{
    public function index(AdminListTicketsRequest $request, ListAdminTickets $action): JsonResponse
    {
        $page = $action->execute($request->integer('per_page', 20));
        TicketEvent::record('ticket.admin_list', 'allowed', $request->user()->id);

        return ApiResponse::success('Tickets retrieved.', AdminTicketSummaryResource::collection($page->items())->resolve($request), meta: ['current_page' => $page->currentPage(), 'per_page' => $page->perPage(), 'total' => $page->total(), 'last_page' => $page->lastPage()]);
    }

    public function assign(AssignTicketRequest $request, string $reference, AssignTicket $action): JsonResponse
    {
        try {
            $ticket = $action->execute($request->user(), $reference, $request->integer('technician_id'));
            TicketEvent::record('ticket.assignment', 'accepted', $request->user()->id, $ticket->reference);

            return ApiResponse::success('Ticket assigned.', (new AdminTicketSummaryResource($ticket))->resolve($request));
        } catch (TicketNotFoundException) {
            TicketEvent::record('ticket.assignment', 'concealed_not_found', $request->user()->id);

            return ApiResponse::error('Ticket not found.', 'TICKET_NOT_FOUND', 404);
        } catch (AssignmentConflictException) {
            TicketEvent::record('ticket.assignment', 'conflict', $request->user()->id, $reference);

            return ApiResponse::error('The ticket can no longer be assigned. Refresh and review its current state.', 'ASSIGNMENT_CONFLICT', 409);
        } catch (ValidationException $exception) {
            TicketEvent::record('ticket.assignment', 'ineligible_technician', $request->user()->id, $reference);
            throw $exception;
        } catch (Throwable) {
            TicketEvent::record('ticket.assignment', 'failed', $request->user()->id, $reference);

            return ApiResponse::error('An unexpected server error occurred.', 'SERVER_ERROR', 500);
        }
    }
}
