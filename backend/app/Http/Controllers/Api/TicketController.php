<?php

namespace App\Http\Controllers\Api;

use App\Actions\Tickets\CreateTicket;
use App\Http\Controllers\Controller;
use App\Http\Requests\Tickets\CreateTicketRequest;
use App\Http\Requests\Tickets\ListTicketsRequest;
use App\Http\Resources\TicketResource;
use App\Http\Resources\TicketSummaryResource;
use App\Support\ApiResponse;
use App\Support\TicketEvent;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;
use Throwable;

class TicketController extends Controller
{
    public function __construct(private readonly CreateTicket $createTicket) {}

    public function store(CreateTicketRequest $request): JsonResponse
    {
        try {
            $ticket = $this->createTicket->execute($request->user(), $request->validated());

            return ApiResponse::success('Ticket created.', (new TicketResource($ticket))->resolve($request), 201);
        } catch (ValidationException $exception) {
            throw $exception;
        } catch (Throwable) {
            return ApiResponse::error('The ticket could not be created. Please retry safely.', 'SERVER_ERROR', 500);
        }
    }

    public function index(ListTicketsRequest $request): JsonResponse
    {
        $page = $request->user()->tickets()->with(['department', 'category'])->orderByDesc('created_at')->orderByDesc('id')->paginate($request->integer('per_page', 20));
        TicketEvent::record('ticket.list', 'allowed', $request->user()->id);

        return ApiResponse::success('Tickets retrieved.', TicketSummaryResource::collection($page->items())->resolve($request), meta: ['current_page' => $page->currentPage(), 'per_page' => $page->perPage(), 'total' => $page->total(), 'last_page' => $page->lastPage()]);
    }

    public function show(string $reference): JsonResponse
    {
        $request = request();
        $ticket = $request->user()->tickets()->with(['department', 'category', 'photos', 'rating'])->where('reference', $reference)->first();
        if (! $ticket) {
            TicketEvent::record('ticket.detail', 'concealed_not_found', $request->user()->id);

            return ApiResponse::error('Ticket not found.', 'TICKET_NOT_FOUND', 404);
        }
        TicketEvent::record('ticket.detail', 'allowed', $request->user()->id, $ticket->reference);

        return ApiResponse::success('Ticket retrieved.', (new TicketResource($ticket))->resolve($request));
    }
}
