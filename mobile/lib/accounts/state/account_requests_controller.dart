import 'package:flutter/foundation.dart';

import '../models/account_request_models.dart';
import '../repositories/account_request_repository.dart';

enum AccountRequestsViewStatus {
  initial,
  loading,
  loaded,
  empty,
  acting,
  unauthorized,
  offline,
  conflict,
  validationError,
  serverError,
}

class AccountRequestsState {
  const AccountRequestsState({
    this.status = AccountRequestsViewStatus.initial,
    this.items = const [],
    this.filter = AccountRequestStatus.pending,
    this.message,
    this.actingId,
  });

  final AccountRequestsViewStatus status;
  final List<AccountRequest> items;
  final AccountRequestStatus filter;
  final String? message;
  final int? actingId;
}

class AccountRequestsController extends ChangeNotifier {
  AccountRequestsController(this._repository);

  final AccountRequestRepository _repository;
  AccountRequestsState _state = const AccountRequestsState();
  int _generation = 0;

  AccountRequestsState get state => _state;

  void _set(AccountRequestsState value) {
    _state = value;
    notifyListeners();
  }

  Future<void> load({AccountRequestStatus? filter}) async {
    final selected = filter ?? _state.filter;
    final generation = ++_generation;
    _set(
      AccountRequestsState(
        status: AccountRequestsViewStatus.loading,
        items: _state.items,
        filter: selected,
      ),
    );
    try {
      final items = await _repository.list(selected);
      if (generation != _generation) return;
      _set(
        AccountRequestsState(
          status: items.isEmpty
              ? AccountRequestsViewStatus.empty
              : AccountRequestsViewStatus.loaded,
          items: items,
          filter: selected,
        ),
      );
    } on AccountRequestFailure catch (failure) {
      if (generation == _generation) _failure(failure, selected);
    }
  }

  Future<bool> approve(int id) => _act(id, () => _repository.approve(id));

  Future<bool> reject(int id, {String? reason}) =>
      _act(id, () => _repository.reject(id, reason: reason));

  Future<bool> _act(int id, Future<AccountRequest> Function() operation) async {
    final generation = ++_generation;
    _set(
      AccountRequestsState(
        status: AccountRequestsViewStatus.acting,
        items: _state.items,
        filter: _state.filter,
        actingId: id,
      ),
    );
    try {
      await operation();
      if (generation != _generation) return false;
      await load(filter: _state.filter);
      return true;
    } on AccountRequestFailure catch (failure) {
      if (generation != _generation) return false;
      if (failure.kind == AccountRequestFailureKind.conflict) {
        await _refreshAfterConflict(generation, failure, _state.filter);
      } else {
        _failure(failure, _state.filter);
      }
      return false;
    }
  }

  Future<void> _refreshAfterConflict(
    int generation,
    AccountRequestFailure failure,
    AccountRequestStatus filter,
  ) async {
    var items = _state.items;
    try {
      items = await _repository.list(filter);
    } on AccountRequestFailure {
      // Preserve the original conflict and last known list when refresh fails.
    }
    if (generation != _generation) return;
    _set(
      AccountRequestsState(
        status: AccountRequestsViewStatus.conflict,
        items: items,
        filter: filter,
        message: failure.message,
      ),
    );
  }

  void _failure(AccountRequestFailure failure, AccountRequestStatus filter) {
    final status = switch (failure.kind) {
      AccountRequestFailureKind.unauthenticated ||
      AccountRequestFailureKind.unauthorized =>
        AccountRequestsViewStatus.unauthorized,
      AccountRequestFailureKind.offline => AccountRequestsViewStatus.offline,
      AccountRequestFailureKind.conflict => AccountRequestsViewStatus.conflict,
      AccountRequestFailureKind.validation =>
        AccountRequestsViewStatus.validationError,
      AccountRequestFailureKind.server || AccountRequestFailureKind.contract =>
        AccountRequestsViewStatus.serverError,
    };
    _set(
      AccountRequestsState(
        status: status,
        items: _state.items,
        filter: filter,
        message: failure.message,
      ),
    );
  }
}
