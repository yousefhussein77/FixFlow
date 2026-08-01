import '../../auth/services/token_store.dart';
import '../models/account_request_models.dart';
import '../services/account_request_api_service.dart';

abstract interface class AccountRequestRepository {
  Future<List<AccountRequest>> list(AccountRequestStatus status);
  Future<AccountRequest> approve(int id);
  Future<AccountRequest> reject(int id, {String? reason});
}

class AccountRequestRepositoryImpl implements AccountRequestRepository {
  AccountRequestRepositoryImpl(this._api, this._tokenStore);

  final AccountRequestApiService _api;
  final TokenStore _tokenStore;

  Future<String> _token() async {
    final token = await _tokenStore.read();
    if (token == null || token.isEmpty) {
      throw const AccountRequestFailure(
        AccountRequestFailureKind.unauthenticated,
        'انتهت الجلسة. سجل الدخول مرة أخرى.',
      );
    }
    return token;
  }

  @override
  Future<List<AccountRequest>> list(AccountRequestStatus status) async {
    final envelope = await _api.list(await _token(), status.apiValue);
    try {
      final data = envelope['data'];
      if (data is! List) throw const FormatException();
      return [
        for (final item in data)
          AccountRequest.fromJson(item as Map<String, dynamic>),
      ];
    } on AccountRequestFailure {
      rethrow;
    } catch (_) {
      throw const AccountRequestFailure(
        AccountRequestFailureKind.contract,
        'تعذر معالجة بيانات طلبات الحسابات.',
      );
    }
  }

  @override
  Future<AccountRequest> approve(int id) async {
    final envelope = await _api.approve(await _token(), id);
    return _item(envelope);
  }

  @override
  Future<AccountRequest> reject(int id, {String? reason}) async {
    final normalized = reason?.trim().replaceAll(RegExp(r'\s+'), ' ');
    final envelope = await _api.reject(
      await _token(),
      id,
      normalized == null || normalized.isEmpty ? null : normalized,
    );
    return _item(envelope);
  }

  AccountRequest _item(Map<String, dynamic> envelope) {
    try {
      return AccountRequest.fromJson(envelope['data'] as Map<String, dynamic>);
    } on AccountRequestFailure {
      rethrow;
    } catch (_) {
      throw const AccountRequestFailure(
        AccountRequestFailureKind.contract,
        'تعذر معالجة بيانات طلب الحساب.',
      );
    }
  }
}
