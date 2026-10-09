class CheckInModel {
  final int id;
  final DateTime checkedInAt;
  final String method; // 'code' or 'qr'

  CheckInModel({
    required this.id,
    required this.checkedInAt,
    required this.method,
  });

  factory CheckInModel.fromJson(Map<String, dynamic> json) {
    return CheckInModel(
      id: json['id'] as int,
      checkedInAt: DateTime.parse(json['checked_in_at'] as String),
      method: (json['method'] ?? 'qr') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checked_in_at': checkedInAt.toIso8601String(),
      'method': method,
    };
  }
}
