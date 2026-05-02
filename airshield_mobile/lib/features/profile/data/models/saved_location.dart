import 'package:equatable/equatable.dart';

/// Location Types
enum LocationType {
  home,
  work,
  custom;

  String get displayName {
    switch (this) {
      case LocationType.home:
        return 'Home';
      case LocationType.work:
        return 'Work';
      case LocationType.custom:
        return 'Custom';
    }
  }

  String get icon {
    switch (this) {
      case LocationType.home:
        return '🏠';
      case LocationType.work:
        return '🏢';
      case LocationType.custom:
        return '📍';
    }
  }
}

/// Saved Location Model
class SavedLocation extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final LocationType type;
  final bool isDefault;
  final DateTime createdAt;

  const SavedLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.type = LocationType.custom,
    this.isDefault = false,
    required this.createdAt,
  });

  SavedLocation copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    LocationType? type,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return SavedLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'type': type.name,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      type: LocationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LocationType.custom,
      ),
      isDefault: json['is_default'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        latitude,
        longitude,
        address,
        type,
        isDefault,
        createdAt,
      ];
}
