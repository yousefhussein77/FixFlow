import '../../auth/services/token_store.dart';
import '../models/ticket_models.dart';
import '../services/ticket_api_service.dart';

abstract interface class TicketRepository {
  Future<List<TicketOption>> departments();
  Future<List<TicketOption>> categories(int departmentId);
  Future<TicketDetail> create(CreateTicketInput input);
  Future<TicketPage> list({int page = 1, int perPage = 20});
  Future<TicketDetail> detail(String reference);
}

class TicketRepositoryImpl implements TicketRepository {
  TicketRepositoryImpl(this.api, this.store);
  final TicketApiService api;
  final TokenStore store;
  Future<String> _token() async {
    final value = await store.read();
    if (value == null)
      throw const TicketFailure(
        TicketFailureKind.unauthorized,
        'يجب تسجيل الدخول للمتابعة.',
      );
    return value;
  }

  List<Map<String, dynamic>> _dataList(Map<String, dynamic> envelope) {
    final data = envelope['data'];
    if (data is! List)
      throw const TicketFailure(
        TicketFailureKind.contract,
        'تعذر معالجة قائمة التذاكر.',
      );
    return data.cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> _data(Map<String, dynamic> envelope) {
    final data = envelope['data'];
    if (data is! Map<String, dynamic>)
      throw const TicketFailure(
        TicketFailureKind.contract,
        'تعذر معالجة بيانات التذكرة.',
      );
    return data;
  }

  @override
  Future<List<TicketOption>> departments() async => _dataList(
    await api.get('/api/reporter/options/departments', await _token()),
  ).map(TicketOption.fromJson).toList();
  @override
  Future<List<TicketOption>> categories(int id) async => _dataList(
    await api.get(
      '/api/reporter/options/departments/$id/categories',
      await _token(),
    ),
  ).map(TicketOption.fromJson).toList();
  @override
  Future<TicketDetail> create(CreateTicketInput input) async =>
      TicketDetail.fromJson(_data(await api.create(input, await _token())));
  @override
  Future<TicketDetail> detail(String reference) async => TicketDetail.fromJson(
    _data(await api.get('/api/reporter/tickets/$reference', await _token())),
  );
  @override
  Future<TicketPage> list({int page = 1, int perPage = 20}) async {
    final e = await api.get(
      '/api/reporter/tickets?page=$page&per_page=$perPage',
      await _token(),
    );
    final meta = e['meta'];
    if (meta is! Map<String, dynamic>)
      throw const TicketFailure(
        TicketFailureKind.contract,
        'تعذر معالجة صفحات التذاكر.',
      );
    return TicketPage(
      _dataList(e).map(TicketSummary.fromJson).toList(),
      currentPage: meta['current_page'] as int,
      lastPage: meta['last_page'] as int,
      total: meta['total'] as int,
    );
  }
}
