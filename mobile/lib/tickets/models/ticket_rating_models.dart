class TicketRating {
  const TicketRating({required this.value, required this.ratedAt});
  final int value;
  final DateTime ratedAt;

  factory TicketRating.fromJson(Map<String, dynamic> json) {
    final value = json['value'];
    if (value is! int || value < 1 || value > 5) throw const FormatException();
    return TicketRating(
      value: value,
      ratedAt: DateTime.parse(json['rated_at'] as String),
    );
  }
}
