import 'dart:typed_data';
import 'ticket_rating_models.dart';

enum TicketFailureKind {
  validation,
  unauthorized,
  notFound,
  conflict,
  offline,
  server,
  contract,
}

class TicketFailure implements Exception {
  const TicketFailure(
    this.kind,
    this.message, {
    this.fieldErrors = const {},
    this.code,
  });
  final TicketFailureKind kind;
  final String message;
  final Map<String, List<String>> fieldErrors;
  final String? code;
}

class TicketOption {
  const TicketOption(this.id, this.name);
  final int id;
  final String name;
  factory TicketOption.fromJson(Map<String, dynamic> json) =>
      TicketOption(json['id'] as int, json['name'] as String);
}

class SelectedPhoto {
  const SelectedPhoto({
    required this.name,
    required this.mimeType,
    required this.bytes,
  });
  final String name;
  final String mimeType;
  final Uint8List bytes;
  String? validate() {
    if (!const {'image/jpeg', 'image/png', 'image/webp'}.contains(mimeType))
      return 'Use a JPEG, PNG, or WebP photo.';
    if (bytes.length > 10 * 1024 * 1024)
      return 'Each photo must be 10 MB or smaller.';
    if (!_contentMatchesMime())
      return 'The photo content does not match a supported image type.';
    return null;
  }

  bool _contentMatchesMime() {
    if (mimeType == 'image/jpeg') {
      return bytes.length >= 3 &&
          bytes[0] == 0xff &&
          bytes[1] == 0xd8 &&
          bytes[2] == 0xff;
    }
    if (mimeType == 'image/png') {
      const signature = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
      return bytes.length >= signature.length &&
          List.generate(
            signature.length,
            (i) => bytes[i] == signature[i],
          ).every((matches) => matches);
    }
    return bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP';
  }
}

class TicketPhoto {
  const TicketPhoto({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    required this.position,
  });
  final int id;
  final String name;
  final String mimeType;
  final int size;
  final int position;
  factory TicketPhoto.fromJson(Map<String, dynamic> json) => TicketPhoto(
    id: json['id'] as int,
    name: json['name'] as String,
    mimeType: json['mime_type'] as String,
    size: json['size'] as int,
    position: json['position'] as int,
  );
}

class TicketSummary {
  const TicketSummary({
    required this.reference,
    required this.title,
    required this.status,
    required this.priority,
    required this.department,
    required this.category,
    required this.createdAt,
  });
  final String reference;
  final String title;
  final String status;
  final String priority;
  final TicketOption department;
  final TicketOption category;
  final DateTime createdAt;
  factory TicketSummary.fromJson(Map<String, dynamic> json) => TicketSummary(
    reference: json['reference'] as String,
    title: json['title'] as String,
    status: json['status'] as String,
    priority: json['priority'] as String,
    department: TicketOption.fromJson(
      json['department'] as Map<String, dynamic>,
    ),
    category: TicketOption.fromJson(json['category'] as Map<String, dynamic>),
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

class TicketDetail extends TicketSummary {
  const TicketDetail({
    required super.reference,
    required super.title,
    required super.status,
    required super.priority,
    required super.department,
    required super.category,
    required super.createdAt,
    required this.description,
    required this.location,
    required this.photos,
    required this.updatedAt,
    this.rating,
  });
  final String description;
  final String location;
  final List<TicketPhoto> photos;
  final DateTime updatedAt;
  final TicketRating? rating;
  factory TicketDetail.fromJson(Map<String, dynamic> json) {
    final s = TicketSummary.fromJson(json);
    return TicketDetail(
      reference: s.reference,
      title: s.title,
      status: s.status,
      priority: s.priority,
      department: s.department,
      category: s.category,
      createdAt: s.createdAt,
      description: json['description'] as String,
      location: json['location'] as String,
      photos: (json['photos'] as List)
          .cast<Map<String, dynamic>>()
          .map(TicketPhoto.fromJson)
          .toList(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      rating: json['rating'] == null
          ? null
          : TicketRating.fromJson(json['rating'] as Map<String, dynamic>),
    );
  }
}

class TicketPage {
  const TicketPage(
    this.items, {
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
  final List<TicketSummary> items;
  final int currentPage;
  final int lastPage;
  final int total;
}

class CreateTicketInput {
  const CreateTicketInput({
    required this.submissionToken,
    required this.title,
    required this.description,
    required this.departmentId,
    required this.categoryId,
    required this.priority,
    required this.location,
    this.photos = const [],
  });
  final String submissionToken;
  final String title;
  final String description;
  final int departmentId;
  final int categoryId;
  final String priority;
  final String location;
  final List<SelectedPhoto> photos;
}
