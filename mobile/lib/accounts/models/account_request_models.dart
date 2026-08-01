enum AccountRequestStatus { pending, approved, rejected, inactive }

extension AccountRequestStatusValue on AccountRequestStatus {
  String get apiValue => name;

  String get label => switch (this) {
    AccountRequestStatus.pending => 'قيد المراجعة',
    AccountRequestStatus.approved => 'معتمد',
    AccountRequestStatus.rejected => 'مرفوض',
    AccountRequestStatus.inactive => 'غير نشط',
  };
}

class AccountReviewer {
  const AccountReviewer({required this.id, required this.name});

  final int id;
  final String name;

  factory AccountReviewer.fromJson(Map<String, dynamic> json) =>
      AccountReviewer(id: json['id'] as int, name: json['name'] as String);
}

class AccountRequest {
  const AccountRequest({
    required this.id,
    required this.name,
    required this.email,
    required this.requestedRole,
    required this.status,
    required this.registeredAt,
    this.approvedBy,
    this.approvedAt,
    this.rejectedBy,
    this.rejectedAt,
    this.rejectionReason,
  });

  final int id;
  final String name;
  final String email;
  final String requestedRole;
  final AccountRequestStatus status;
  final DateTime registeredAt;
  final AccountReviewer? approvedBy;
  final DateTime? approvedAt;
  final AccountReviewer? rejectedBy;
  final DateTime? rejectedAt;
  final String? rejectionReason;

  String get roleLabel => requestedRole == 'technician' ? 'فني' : 'مُبلّغ';

  factory AccountRequest.fromJson(Map<String, dynamic> json) {
    try {
      return AccountRequest(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        requestedRole: json['requested_role'] as String,
        status: AccountRequestStatus.values.byName(json['status'] as String),
        registeredAt: DateTime.parse(json['registered_at'] as String),
        approvedBy: _reviewer(json['approved_by']),
        approvedAt: _date(json['approved_at']),
        rejectedBy: _reviewer(json['rejected_by']),
        rejectedAt: _date(json['rejected_at']),
        rejectionReason: json['rejection_reason'] as String?,
      );
    } catch (_) {
      throw const AccountRequestFailure(
        AccountRequestFailureKind.contract,
        'تعذر معالجة بيانات طلبات الحسابات.',
      );
    }
  }

  static AccountReviewer? _reviewer(dynamic value) => value == null
      ? null
      : AccountReviewer.fromJson(value as Map<String, dynamic>);

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.parse(value as String);
}

enum AccountRequestFailureKind {
  unauthenticated,
  unauthorized,
  validation,
  conflict,
  offline,
  server,
  contract,
}

class AccountRequestFailure implements Exception {
  const AccountRequestFailure(this.kind, this.message);

  final AccountRequestFailureKind kind;
  final String message;
}
