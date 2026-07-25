import 'admin_ticket_models.dart';
import 'ticket_models.dart';

class TicketHistoryEntry {
  const TicketHistoryEntry({
    required this.fromStatus,
    required this.toStatus,
    required this.actor,
    required this.assignedTechnician,
    required this.reason,
    required this.occurredAt,
  });
  final String fromStatus, toStatus;
  final UserSummary actor, assignedTechnician;
  final String? reason;
  final DateTime occurredAt;
  factory TicketHistoryEntry.fromJson(Map<String, dynamic> json) =>
      TicketHistoryEntry(
        fromStatus: json['from_status'] as String,
        toStatus: json['to_status'] as String,
        actor: UserSummary.fromJson(json['actor'] as Map<String, dynamic>),
        assignedTechnician: UserSummary.fromJson(
          json['assigned_technician'] as Map<String, dynamic>,
        ),
        reason: json['reason'] as String?,
        occurredAt: DateTime.parse(json['occurred_at'] as String),
      );
}

class TechnicianTicketSummary {
  const TechnicianTicketSummary({
    required this.reference,
    required this.title,
    required this.priority,
    required this.department,
    required this.category,
    required this.status,
    required this.createdAt,
  });
  final String reference, title, priority, status;
  final TicketOption department, category;
  final DateTime createdAt;
  factory TechnicianTicketSummary.fromJson(Map<String, dynamic> json) =>
      TechnicianTicketSummary(
        reference: json['reference'] as String,
        title: json['title'] as String,
        priority: json['priority'] as String,
        department: TicketOption.fromJson(
          json['department'] as Map<String, dynamic>,
        ),
        category: TicketOption.fromJson(
          json['category'] as Map<String, dynamic>,
        ),
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class TechnicianTicket extends TechnicianTicketSummary {
  const TechnicianTicket({
    required super.reference,
    required super.title,
    required super.priority,
    required super.department,
    required super.category,
    required super.status,
    required super.createdAt,
    required this.description,
    required this.location,
    required this.photos,
    required this.assignedTechnician,
    required this.history,
    required this.updatedAt,
  });
  final String description, location;
  final List<TicketPhoto> photos;
  final UserSummary assignedTechnician;
  final List<TicketHistoryEntry> history;
  final DateTime updatedAt;
  factory TechnicianTicket.fromJson(Map<String, dynamic> json) {
    final summary = TechnicianTicketSummary.fromJson(json);
    return TechnicianTicket(
      reference: summary.reference,
      title: summary.title,
      priority: summary.priority,
      department: summary.department,
      category: summary.category,
      status: summary.status,
      createdAt: summary.createdAt,
      description: json['description'] as String,
      location: json['location'] as String,
      photos: (json['photos'] as List)
          .cast<Map<String, dynamic>>()
          .map(TicketPhoto.fromJson)
          .toList(),
      assignedTechnician: UserSummary.fromJson(
        json['assigned_technician'] as Map<String, dynamic>,
      ),
      history: (json['status_history'] as List)
          .cast<Map<String, dynamic>>()
          .map(TicketHistoryEntry.fromJson)
          .toList(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class TechnicianTicketPage {
  const TechnicianTicketPage(
    this.items, {
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
  final List<TechnicianTicketSummary> items;
  final int currentPage, lastPage, total;
}
