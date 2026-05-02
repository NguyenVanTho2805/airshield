import 'package:equatable/equatable.dart';

/// Health Condition Types
enum HealthConditionType {
  asthma,
  allergies,
  heartDisease,
  copd,
  diabetes,
  none;

  String get displayName {
    switch (this) {
      case HealthConditionType.asthma:
        return 'Asthma';
      case HealthConditionType.allergies:
        return 'Allergies';
      case HealthConditionType.heartDisease:
        return 'Heart Disease';
      case HealthConditionType.copd:
        return 'COPD';
      case HealthConditionType.diabetes:
        return 'Diabetes';
      case HealthConditionType.none:
        return 'None';
    }
  }

  String get icon {
    switch (this) {
      case HealthConditionType.asthma:
        return '🫁';
      case HealthConditionType.allergies:
        return '🤧';
      case HealthConditionType.heartDisease:
        return '❤️';
      case HealthConditionType.copd:
        return '💨';
      case HealthConditionType.diabetes:
        return '💉';
      case HealthConditionType.none:
        return '✅';
    }
  }
}

/// Health Condition Severity
enum HealthSeverity {
  mild,
  moderate,
  severe;

  String get displayName {
    switch (this) {
      case HealthSeverity.mild:
        return 'Mild';
      case HealthSeverity.moderate:
        return 'Moderate';
      case HealthSeverity.severe:
        return 'Severe';
    }
  }
}

/// Health Condition Model
class HealthCondition extends Equatable {
  final HealthConditionType type;
  final HealthSeverity severity;
  final bool isActive;
  final DateTime? diagnosedDate;

  const HealthCondition({
    required this.type,
    this.severity = HealthSeverity.mild,
    this.isActive = true,
    this.diagnosedDate,
  });

  HealthCondition copyWith({
    HealthConditionType? type,
    HealthSeverity? severity,
    bool? isActive,
    DateTime? diagnosedDate,
  }) {
    return HealthCondition(
      type: type ?? this.type,
      severity: severity ?? this.severity,
      isActive: isActive ?? this.isActive,
      diagnosedDate: diagnosedDate ?? this.diagnosedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'severity': severity.name,
      'is_active': isActive,
      'diagnosed_date': diagnosedDate?.toIso8601String(),
    };
  }

  factory HealthCondition.fromJson(Map<String, dynamic> json) {
    return HealthCondition(
      type: HealthConditionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HealthConditionType.none,
      ),
      severity: HealthSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => HealthSeverity.mild,
      ),
      isActive: json['is_active'] ?? true,
      diagnosedDate: json['diagnosed_date'] != null
          ? DateTime.tryParse(json['diagnosed_date'])
          : null,
    );
  }

  @override
  List<Object?> get props => [type, severity, isActive, diagnosedDate];
}
