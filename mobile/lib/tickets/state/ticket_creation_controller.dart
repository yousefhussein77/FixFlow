import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/ticket_models.dart';
import '../repositories/ticket_repository.dart';

enum TicketCreationStatus {
  idle,
  loadingOptions,
  ready,
  empty,
  photoValidation,
  submitting,
  success,
  validation,
  unauthorized,
  offline,
  conflict,
  serverError,
}

class TicketCreationState {
  const TicketCreationState(
    this.status, {
    this.message,
    this.errors = const {},
    this.ticket,
  });
  final TicketCreationStatus status;
  final String? message;
  final Map<String, List<String>> errors;
  final TicketDetail? ticket;
}

class TicketCreationController extends ChangeNotifier {
  TicketCreationController(this.repository);
  final TicketRepository repository;
  TicketCreationState state = const TicketCreationState(
    TicketCreationStatus.idle,
  );
  List<TicketOption> departments = [];
  List<TicketOption> categories = [];
  int? selectedDepartmentId;
  int? selectedCategoryId;
  List<SelectedPhoto> photos = [];
  int _optionGeneration = 0;
  String _submissionToken = _uuid();
  bool get isSubmitting => state.status == TicketCreationStatus.submitting;
  void _set(TicketCreationState value) {
    state = value;
    notifyListeners();
  }

  Future<void> loadDepartments() async {
    final g = ++_optionGeneration;
    _set(const TicketCreationState(TicketCreationStatus.loadingOptions));
    try {
      final value = await repository.departments();
      if (g != _optionGeneration) return;
      departments = value;
      _set(
        TicketCreationState(
          value.isEmpty
              ? TicketCreationStatus.empty
              : TicketCreationStatus.ready,
        ),
      );
    } on TicketFailure catch (e) {
      if (g == _optionGeneration) _fail(e);
    }
  }

  Future<void> selectDepartment(int id) async {
    selectedDepartmentId = id;
    selectedCategoryId = null;
    categories = [];
    final g = ++_optionGeneration;
    _set(const TicketCreationState(TicketCreationStatus.loadingOptions));
    try {
      final value = await repository.categories(id);
      if (g != _optionGeneration || selectedDepartmentId != id) return;
      categories = value;
      _set(
        TicketCreationState(
          value.isEmpty
              ? TicketCreationStatus.empty
              : TicketCreationStatus.ready,
        ),
      );
    } on TicketFailure catch (e) {
      if (g == _optionGeneration) _fail(e);
    }
  }

  void selectCategory(int? id) {
    selectedCategoryId = id;
    notifyListeners();
  }

  bool setPhotos(List<SelectedPhoto> value) {
    if (value.length > 5) {
      _set(
        const TicketCreationState(
          TicketCreationStatus.photoValidation,
          message: 'Choose no more than five photos.',
        ),
      );
      return false;
    }
    for (final p in value) {
      final error = p.validate();
      if (error != null) {
        _set(
          TicketCreationState(
            TicketCreationStatus.photoValidation,
            message: error,
          ),
        );
        return false;
      }
    }
    photos = List.unmodifiable(value);
    _set(const TicketCreationState(TicketCreationStatus.ready));
    return true;
  }

  Future<void> submit({
    required String title,
    required String description,
    required String priority,
    required String location,
  }) async {
    if (isSubmitting) return;
    final department = selectedDepartmentId;
    final category = selectedCategoryId;
    if (department == null || category == null) {
      _set(
        const TicketCreationState(
          TicketCreationStatus.validation,
          errors: {
            'category_id': ['Select a department and category.'],
          },
        ),
      );
      return;
    }
    _set(const TicketCreationState(TicketCreationStatus.submitting));
    try {
      final ticket = await repository.create(
        CreateTicketInput(
          submissionToken: _submissionToken,
          title: title,
          description: description,
          departmentId: department,
          categoryId: category,
          priority: priority,
          location: location,
          photos: photos,
        ),
      );
      _submissionToken = _uuid();
      _set(TicketCreationState(TicketCreationStatus.success, ticket: ticket));
    } on TicketFailure catch (e) {
      _fail(e);
    }
  }

  void _fail(TicketFailure e) {
    final status = switch (e.kind) {
      TicketFailureKind.validation => TicketCreationStatus.validation,
      TicketFailureKind.unauthorized => TicketCreationStatus.unauthorized,
      TicketFailureKind.offline => TicketCreationStatus.offline,
      TicketFailureKind.conflict => TicketCreationStatus.conflict,
      _ => TicketCreationStatus.serverError,
    };
    _set(
      TicketCreationState(status, message: e.message, errors: e.fieldErrors),
    );
  }

  static String _uuid() {
    final r = Random.secure();
    String h(int n) =>
        List.generate(n, (_) => r.nextInt(16).toRadixString(16)).join();
    return '${h(8)}-${h(4)}-4${h(3)}-${(8 + r.nextInt(4)).toRadixString(16)}${h(3)}-${h(12)}';
  }
}
