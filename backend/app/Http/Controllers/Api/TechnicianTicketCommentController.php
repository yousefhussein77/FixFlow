<?php

namespace App\Http\Controllers\Api;

use App\Actions\Tickets\CreateTicketComment;
use App\Actions\Tickets\ListTicketComments;
use App\Exceptions\TicketNotFoundException;
use App\Http\Controllers\Controller;
use App\Http\Requests\Tickets\CreateTicketCommentRequest;
use App\Http\Resources\TicketCommentResource;
use App\Models\User;
use App\Support\ApiResponse;
use App\Support\TicketEvent;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Throwable;

class TechnicianTicketCommentController extends Controller
{
    public function index(Request $request, string $reference, ListTicketComments $action): JsonResponse
    {
        try {
            $comments = $action->execute($request->user(), User::ROLE_TECHNICIAN, $reference);
            TicketEvent::record('ticket.comment_list', 'allowed', $request->user()->id, $reference);

            return ApiResponse::success('Comments retrieved.', TicketCommentResource::collection($comments)->resolve($request));
        } catch (TicketNotFoundException) {
            return $this->notFound($request);
        } catch (Throwable) {
            TicketEvent::record('ticket.comment_list', 'failed', $request->user()->id);

            return ApiResponse::error('An unexpected server error occurred.', 'SERVER_ERROR', 500);
        }
    }

    public function store(CreateTicketCommentRequest $request, string $reference, CreateTicketComment $action): JsonResponse
    {
        try {
            $result = $action->execute($request->user(), User::ROLE_TECHNICIAN, $reference, $request->string('content')->toString(), $request->string('submission_token')->toString());
            TicketEvent::record('ticket.comment_create', $result['replayed'] ? 'replayed' : 'accepted', $request->user()->id, $reference);

            return ApiResponse::success($result['replayed'] ? 'Comment already recorded.' : 'Comment added.', (new TicketCommentResource($result['comment']))->resolve($request), $result['replayed'] ? 200 : 201);
        } catch (TicketNotFoundException) {
            return $this->notFound($request);
        } catch (Throwable) {
            TicketEvent::record('ticket.comment_create', 'failed', $request->user()->id);

            return ApiResponse::error('An unexpected server error occurred.', 'SERVER_ERROR', 500);
        }
    }

    private function notFound(Request $request): JsonResponse
    {
        TicketEvent::record('ticket.comment_target', 'concealed_not_found', $request->user()->id);

        return ApiResponse::error('Ticket not found.', 'TICKET_NOT_FOUND', 404);
    }
}
