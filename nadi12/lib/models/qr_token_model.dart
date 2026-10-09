class QrTokenModel {
  final String token;
  final DateTime expiresAt;

  QrTokenModel({required this.token, required this.expiresAt});

  factory QrTokenModel.fromJson(Map<String, dynamic> json) {
    return QrTokenModel(
      token: json['token'] as String? ?? '',
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  int get remainingSeconds {
    final diff = expiresAt.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }
}
