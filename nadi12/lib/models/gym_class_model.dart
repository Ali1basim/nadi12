class GymClassModel {
  final int id;
  final String name;
  final DateTime startsAt;
  final DateTime endsAt;
  final int capacity;
  final int freePlaces;

  GymClassModel({
    required this.id,
    required this.name,
    required this.startsAt,
    required this.endsAt,
    required this.capacity,
    required this.freePlaces,
  });

  factory GymClassModel.fromJson(Map<String, dynamic> json) {
    return GymClassModel(
      id: json['id'] as int,
      name: json['name'] as String,
      startsAt: DateTime.parse(json['starts_at'] as String),
      endsAt: DateTime.parse(json['ends_at'] as String),
      capacity: json['capacity'] as int,
      freePlaces: (json['free_places'] ?? json['capacity']) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'starts_at': startsAt.toIso8601String(),
      'ends_at': endsAt.toIso8601String(),
      'capacity': capacity,
      'free_places': freePlaces,
    };
  }

  bool get isFull => freePlaces <= 0;

  GymClassModel copyWith({
    int? id,
    String? name,
    DateTime? startsAt,
    DateTime? endsAt,
    int? capacity,
    int? freePlaces,
  }) {
    return GymClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      capacity: capacity ?? this.capacity,
      freePlaces: freePlaces ?? this.freePlaces,
    );
  }
}
