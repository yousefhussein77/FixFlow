import 'ticket_models.dart';

class UserSummary {
  const UserSummary(this.id, this.name);
  final int id;
  final String name;
  factory UserSummary.fromJson(Map<String, dynamic> json) =>
      UserSummary(json['id'] as int, json['name'] as String);
}

class TechnicianOption extends UserSummary {
  const TechnicianOption(super.id, super.name);
  factory TechnicianOption.fromJson(Map<String, dynamic> json) =>
      TechnicianOption(json['id'] as int, json['name'] as String);
}

class AdminTicketSummary {
  const AdminTicketSummary({
    required this.reference,
    required this.title,
    required this.reporter,
    required this.priority,
    required this.department,
    required this.category,
    required this.status,
    required this.assignedTechnician,
    required this.createdAt,
  });
  final String reference;
  final String title;
  final UserSummary reporter;
  final String priority;
  final TicketOption department;
  final TicketOption category;
  final String status;
  final UserSummary? assignedTechnician;
  final DateTime createdAt;
  bool get canAssign => status == 'new' && assignedTechnician == null;
  factory AdminTicketSummary.fromJson(Map<String, dynamic> json) {
    final assigned = json['assigned_technician'];
    return AdminTicketSummary(
      reference: json['reference'] as String,
      title: json['title'] as String,
      reporter: UserSummary.fromJson(json['reporter'] as Map<String, dynamic>),
      priority: json['priority'] as String,
      department: TicketOption.fromJson(
        json['department'] as Map<String, dynamic>,
      ),
      category: TicketOption.fromJson(json['category'] as Map<String, dynamic>),
      status: json['status'] as String,
      assignedTechnician: assigned == null
          ? null
          : UserSummary.fromJson(assigned as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class AdminTicketPage {
  const AdminTicketPage(
    this.items, {
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
  final List<AdminTicketSummary> items;
  final int currentPage;
  final int lastPage;
  final int total;
}
