class UserModel {
  final int id;
  final String name;
  final String email;
  final String memberId;
  final String role; // Member Role ONLY
  final bool isSubscriptionActive;
  final DateTime subscriptionExpiry;
  final String planName;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.memberId,
    this.role = 'member',
    required this.isSubscriptionActive,
    required this.subscriptionExpiry,
    this.planName = 'All Access',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 1,
      name: json['name'] as String? ?? 'Rana Samir',
      email: json['email'] as String? ?? 'rana.samir@example.com',
      memberId: json['member_id'] as String? ?? 'NADI-84920',
      role: json['role'] as String? ?? 'member',
      isSubscriptionActive: json['is_subscription_active'] as bool? ?? true,
      subscriptionExpiry: json['subscription_expiry'] != null
          ? DateTime.parse(json['subscription_expiry'] as String)
          : DateTime.now().add(const Duration(days: 30)),
      planName: json['plan_name'] as String? ?? 'All Access',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'member_id': memberId,
      'role': role,
      'is_subscription_active': isSubscriptionActive,
      'subscription_expiry': subscriptionExpiry.toIso8601String(),
      'plan_name': planName,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? memberId,
    String? role,
    bool? isSubscriptionActive,
    DateTime? subscriptionExpiry,
    String? planName,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      memberId: memberId ?? this.memberId,
      role: role ?? this.role,
      isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      planName: planName ?? this.planName,
    );
  }
}
