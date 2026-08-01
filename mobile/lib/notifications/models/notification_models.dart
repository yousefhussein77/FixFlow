enum NotificationFailureKind {
  unauthenticated,
  unauthorized,
  notFound,
  offline,
  server,
  contract,
}

class NotificationFailure implements Exception {
  const NotificationFailure(this.kind, this.message);

  final NotificationFailureKind kind;
  final String message;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.navigationTarget,
    required this.payload,
    required this.createdAt,
    this.relatedEntityType,
    this.relatedEntityId,
    this.readAt,
  });

  final int id;
  final String type;
  final String title;
  final String message;
  final String? relatedEntityType;
  final int? relatedEntityId;
  final String navigationTarget;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  AppNotification copyWith({DateTime? readAt}) => AppNotification(
    id: id,
    type: type,
    title: title,
    message: message,
    relatedEntityType: relatedEntityType,
    relatedEntityId: relatedEntityId,
    navigationTarget: navigationTarget,
    payload: payload,
    createdAt: createdAt,
    readAt: readAt ?? this.readAt,
  );

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'];
    if (payload is! Map<String, dynamic>) throw const FormatException();
    return AppNotification(
      id: json['id'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      relatedEntityType: json['related_entity_type'] as String?,
      relatedEntityId: json['related_entity_id'] as int?,
      navigationTarget: json['navigation_target'] as String,
      payload: Map<String, dynamic>.unmodifiable(payload),
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
    );
  }
}
