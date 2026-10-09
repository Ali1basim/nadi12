class BookingModel {
  final int id;
  final int classId;
  final String className;
  final DateTime startsAt;
  final String status;

  BookingModel({
    required this.id,
    required this.classId,
    required this.className,
    required this.startsAt,
    required this.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int,
      classId: json['class_id'] as int,
      className: (json['class_name'] ?? '') as String,
      startsAt: DateTime.parse(json['starts_at'] as String),
      status: (json['status'] ?? 'confirmed') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'class_name': className,
      'starts_at': startsAt.toIso8601String(),
      'status': status,
    };
  }

  /// Rule 4: A booking can only be cancelled up to 2 hours before the class start time.
  bool get canCancel {
    final now = DateTime.now();
    final difference = startsAt.difference(now);
    return difference.inMinutes >= 120; // 2 hours = 120 minutes
  }

  Duration get timeUntilStart => startsAt.difference(DateTime.now());
}
