import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/ticket_models.dart';
import '../models/ticket_rating_models.dart';
import '../repositories/ticket_rating_repository.dart';

enum TicketRatingStatus {
  eligible,
  submitting,
  success,
  alreadyRated,
  notCompleted,
  conflict,
  validation,
  notFound,
  unauthorized,
  offline,
  serverError,
}

class TicketRatingController extends ChangeNotifier {
  TicketRatingController(
    this.repository,
    this.reference, {
    TicketRating? rating,
  }) : storedRating = rating,
       status = rating == null
           ? TicketRatingStatus.eligible
           : TicketRatingStatus.alreadyRated;
  final TicketRatingRepository repository;
  final String reference;
  TicketRatingStatus status;
  TicketRating? storedRating;
  int? selectedValue;
  String? message, _submissionToken;
  bool get isSubmitting => status == TicketRatingStatus.submitting;

  void select(int value) {
    if (storedRating != null || isSubmitting) return;
    selectedValue = value;
    status = TicketRatingStatus.eligible;
    message = null;
    notifyListeners();
  }

  Future<bool> submit() async {
    if (isSubmitting) return false;
    if (selectedValue == null || selectedValue! < 1 || selectedValue! > 5) {
      status = TicketRatingStatus.validation;
      message = 'اختر تقييماً من 1 إلى 5.';
      notifyListeners();
      return false;
    }
    _submissionToken ??= _uuid();
    status = TicketRatingStatus.submitting;
    notifyListeners();
    try {
      storedRating = await repository.create(
        reference,
        rating: selectedValue!,
        submissionToken: _submissionToken!,
      );
      _submissionToken = null;
      status = TicketRatingStatus.success;
      message = null;
      notifyListeners();
      return true;
    } on TicketFailure catch (failure) {
      if (failure.kind == TicketFailureKind.unauthorized ||
          failure.kind == TicketFailureKind.notFound) {
        storedRating = null;
        selectedValue = null;
        _submissionToken = null;
      }
      status = switch (failure.kind) {
        TicketFailureKind.validation => TicketRatingStatus.validation,
        TicketFailureKind.notFound => TicketRatingStatus.notFound,
        TicketFailureKind.unauthorized => TicketRatingStatus.unauthorized,
        TicketFailureKind.offline => TicketRatingStatus.offline,
        TicketFailureKind.conflict => switch (failure.code) {
          'RATING_ALREADY_EXISTS' => TicketRatingStatus.alreadyRated,
          'TICKET_NOT_COMPLETED' => TicketRatingStatus.notCompleted,
          _ => TicketRatingStatus.conflict,
        },
        _ => TicketRatingStatus.serverError,
      };
      message = failure.message;
      notifyListeners();
      return false;
    }
  }

  String _uuid() {
    final random = Random.secure();
    String hex(int count) => List.generate(
      count,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
    return '${hex(8)}-${hex(4)}-4${hex(3)}-${(8 + random.nextInt(4)).toRadixString(16)}${hex(3)}-${hex(12)}';
  }
}
