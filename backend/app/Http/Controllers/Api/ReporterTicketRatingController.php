<?php

namespace App\Http\Controllers\Api;

use App\Actions\Tickets\CreateTicketRating;
use App\Exceptions\RatingAlreadyExistsException;
use App\Exceptions\TicketNotCompletedException;
use App\Exceptions\TicketNotFoundException;
use App\Http\Controllers\Controller;
use App\Http\Requests\Tickets\CreateTicketRatingRequest;
use App\Http\Resources\TicketRatingResource;
use App\Support\ApiResponse;
use App\Support\TicketEvent;
use Illuminate\Http\JsonResponse;
use Throwable;

class ReporterTicketRatingController extends Controller
{
    public function store(CreateTicketRatingRequest $request, string $reference, CreateTicketRating $action): JsonResponse
    {
        try {
            $result = $action->execute($request->user(), $reference, $request->integer('rating'), $request->string('submission_token')->toString());
            TicketEvent::record('ticket.rating_create', $result['replayed'] ? 'replayed' : 'accepted', $request->user()->id, $reference);

            return ApiResponse::success(
                $result['replayed'] ? 'Rating already recorded.' : 'Ticket rated.',
                (new TicketRatingResource($result['rating']))->resolve($request),
                $result['replayed'] ? 200 : 201,
            );
        } catch (TicketNotFoundException) {
            TicketEvent::record('ticket.rating_target', 'concealed_not_found', $request->user()->id);

            return ApiResponse::error('Ticket not found.', 'TICKET_NOT_FOUND', 404);
        } catch (TicketNotCompletedException) {
            TicketEvent::record('ticket.rating_create', 'not_completed', $request->user()->id, $reference);

            return ApiResponse::error('Only completed tickets can be rated.', 'TICKET_NOT_COMPLETED', 409);
        } catch (RatingAlreadyExistsException) {
            TicketEvent::record('ticket.rating_create', 'already_exists', $request->user()->id, $reference);

            return ApiResponse::error('This ticket has already been rated.', 'RATING_ALREADY_EXISTS', 409);
        } catch (Throwable) {
            TicketEvent::record('ticket.rating_create', 'failed', $request->user()->id);

            return ApiResponse::error('An unexpected server error occurred.', 'SERVER_ERROR', 500);
        }
    }
}
