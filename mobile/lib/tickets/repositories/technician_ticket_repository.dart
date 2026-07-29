import '../../auth/services/token_store.dart';
import '../models/technician_ticket_models.dart';
import '../models/ticket_models.dart';
import '../services/technician_ticket_api_service.dart';

abstract interface class TechnicianTicketRepository {
  Future<TechnicianTicketPage> list({int page = 1, int perPage = 20});
  Future<TechnicianTicket> details(String reference);
  Future<TechnicianTicket> transition(
    String reference,
    String status, {
    String? reason,
  });
}

class TechnicianTicketRepositoryImpl implements TechnicianTicketRepository {
  TechnicianTicketRepositoryImpl(this.api, this.store);
  final TechnicianTicketApiService api;
  final TokenStore store;
  Future<String> _token() async =>
      await store.read() ??
      (throw const TicketFailure(
        TicketFailureKind.unauthorized,
        'Authentication required.',
      ));
  Map<String, dynamic> _data(Map<String, dynamic> value) {
    final data = value['data'];
    if (data is! Map<String, dynamic>)
      throw const TicketFailure(
        TicketFailureKind.contract,
        'Invalid ticket response.',
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
        'تعذر معالجة بيانات تذاكر الفني.',
      );
    }
  }

  @override
  Future<TechnicianTicketPage> list({int page = 1, int perPage = 20}) async {
    final envelope = await api.get(
      '/api/technician/tickets?page=$page&per_page=$perPage',
      await _token(),
    );
    final data = envelope['data'], meta = envelope['meta'];
    if (data is! List || meta is! Map<String, dynamic>)
      throw const TicketFailure(
        TicketFailureKind.contract,
        'Invalid ticket page.',
      );
    return _parse(
      () => TechnicianTicketPage(
        data
            .cast<Map<String, dynamic>>()
            .map(TechnicianTicketSummary.fromJson)
            .toList(),
        currentPage: meta['current_page'] as int,
        lastPage: meta['last_page'] as int,
        total: meta['total'] as int,
      ),
    );
  }

  @override
  Future<TechnicianTicket> details(String reference) async {
    final envelope = await api.get(
      '/api/technician/tickets/$reference',
      await _token(),
    );
    return _parse(() => TechnicianTicket.fromJson(_data(envelope)));
  }

  @override
  Future<TechnicianTicket> transition(
    String reference,
    String status, {
    String? reason,
  }) async {
    if (!const {'in_progress', 'completed', 'rejected'}.contains(status))
      throw const TicketFailure(
        TicketFailureKind.validation,
        'Unsupported status.',
      );
    final trimmed = reason?.trim();
    if (status == 'rejected' &&
        (trimmed == null || trimmed.isEmpty || trimmed.length > 1000))
      throw const TicketFailure(
        TicketFailureKind.validation,
        'A rejection reason is required.',
      );
    final envelope = await api.patch(
      '/api/technician/tickets/$reference/status',
      await _token(),
      {'status': status, if (status == 'rejected') 'reason': trimmed},
    );
    return _parse(() => TechnicianTicket.fromJson(_data(envelope)));
  }
}
