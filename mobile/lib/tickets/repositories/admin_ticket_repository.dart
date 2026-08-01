import '../../auth/services/token_store.dart';
import '../models/admin_ticket_models.dart';
import '../models/ticket_models.dart';
import '../services/admin_ticket_api_service.dart';

abstract interface class AdminTicketRepository {
  Future<AdminTicketPage> list({int page = 1, int perPage = 20});
  Future<List<TechnicianOption>> technicians();
  Future<AdminTicketSummary> assign(String reference, int technicianId);
}

class AdminTicketRepositoryImpl implements AdminTicketRepository {
  AdminTicketRepositoryImpl(this.api, this.store);
  final AdminTicketApiService api;
  final TokenStore store;
  Future<String> _token() async =>
      await store.read() ??
      (throw const TicketFailure(
        TicketFailureKind.unauthorized,
        'يجب تسجيل الدخول للمتابعة.',
      ));
  List<Map<String, dynamic>> _list(Map<String, dynamic> envelope) {
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

  T _parse<T>(T Function() parser) {
    try {
      return parser();
    } on TicketFailure {
      rethrow;
    } catch (_) {
      throw const TicketFailure(
        TicketFailureKind.contract,
        'تعذر معالجة بيانات تذاكر المسؤول.',
      );
    }
  }

  @override
  Future<AdminTicketPage> list({int page = 1, int perPage = 20}) async {
    final envelope = await api.get(
      '/api/admin/tickets?page=$page&per_page=$perPage',
      await _token(),
    );
    final meta = envelope['meta'];
    if (meta is! Map<String, dynamic>)
      throw const TicketFailure(
        TicketFailureKind.contract,
        'تعذر معالجة صفحات التذاكر.',
      );
    return _parse(
      () => AdminTicketPage(
        _list(envelope).map(AdminTicketSummary.fromJson).toList(),
        currentPage: meta['current_page'] as int,
        lastPage: meta['last_page'] as int,
        total: meta['total'] as int,
      ),
    );
  }

  @override
  Future<List<TechnicianOption>> technicians() async {
    final envelope = await api.get(
      '/api/admin/options/technicians',
      await _token(),
    );
    return _parse(
      () => _list(envelope).map(TechnicianOption.fromJson).toList(),
    );
  }

  @override
  Future<AdminTicketSummary> assign(String reference, int technicianId) async {
    final envelope = await api.patch(
      '/api/admin/tickets/$reference/assignment',
      await _token(),
      {'technician_id': technicianId},
    );
    return _parse(() => AdminTicketSummary.fromJson(_data(envelope)));
  }
}
