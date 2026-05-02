import 'package:flutter/material.dart';

/// Automation Rule Model
/// 
/// Represents an automation rule with trigger conditions and actions
class AutomationRule {
  final String id;
  final String name;
  final bool isEnabled;
  final RuleTrigger trigger;
  final RuleAction action;
  final DateTime createdAt;
  final DateTime? lastTriggered;

  const AutomationRule({
    required this.id,
    required this.name,
    required this.isEnabled,
    required this.trigger,
    required this.action,
    required this.createdAt,
    this.lastTriggered,
  });

  /// Create from JSON
  factory AutomationRule.fromJson(Map<String, dynamic> json) {
    return AutomationRule(
      id: json['id'] as String,
      name: json['name'] as String,
      isEnabled: json['is_enabled'] as bool,
      trigger: RuleTrigger.fromJson(json['trigger'] as Map<String, dynamic>),
      action: RuleAction.fromJson(json['action'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      lastTriggered: json['last_triggered'] != null
          ? DateTime.parse(json['last_triggered'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_enabled': isEnabled,
      'trigger': trigger.toJson(),
      'action': action.toJson(),
      'created_at': createdAt.toIso8601String(),
      'last_triggered': lastTriggered?.toIso8601String(),
    };
  }

  AutomationRule copyWith({
    String? id,
    String? name,
    bool? isEnabled,
    RuleTrigger? trigger,
    RuleAction? action,
    DateTime? createdAt,
    DateTime? lastTriggered,
  }) {
    return AutomationRule(
      id: id ?? this.id,
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
      trigger: trigger ?? this.trigger,
      action: action ?? this.action,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
    );
  }
}

/// Rule Trigger
class RuleTrigger {
  final TriggerType type;
  final int? aqiThreshold;
  final String? deviceId;
  final TimeOfDay? timeOfDay;

  const RuleTrigger({
    required this.type,
    this.aqiThreshold,
    this.deviceId,
    this.timeOfDay,
  });

  factory RuleTrigger.fromJson(Map<String, dynamic> json) {
    return RuleTrigger(
      type: TriggerType.fromString(json['type'] as String),
      aqiThreshold: json['aqi_threshold'] as int?,
      deviceId: json['device_id'] as String?,
      timeOfDay: json['time_of_day'] != null
          ? TimeOfDay(
              hour: json['time_of_day']['hour'] as int,
              minute: json['time_of_day']['minute'] as int,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'aqi_threshold': aqiThreshold,
      'device_id': deviceId,
      'time_of_day': timeOfDay != null
          ? {'hour': timeOfDay!.hour, 'minute': timeOfDay!.minute}
          : null,
    };
  }

  String getDescription() {
    switch (type) {
      case TriggerType.aqiAbove:
        return 'When AQI is above $aqiThreshold';
      case TriggerType.aqiBelow:
        return 'When AQI is below $aqiThreshold';
      case TriggerType.time:
        final h = timeOfDay!.hour.toString().padLeft(2, '0');
        final m = timeOfDay!.minute.toString().padLeft(2, '0');
        return 'At $h:$m';
      case TriggerType.deviceOffline:
        return 'When device goes offline';
    }
  }
}

/// Rule Action
class RuleAction {
  final ActionType type;
  final String deviceId;
  final bool? powerState;
  final String? mode;
  final String? notificationMessage;

  const RuleAction({
    required this.type,
    required this.deviceId,
    this.powerState,
    this.mode,
    this.notificationMessage,
  });

  factory RuleAction.fromJson(Map<String, dynamic> json) {
    return RuleAction(
      type: ActionType.fromString(json['type'] as String),
      deviceId: json['device_id'] as String,
      powerState: json['power_state'] as bool?,
      mode: json['mode'] as String?,
      notificationMessage: json['notification_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'device_id': deviceId,
      'power_state': powerState,
      'mode': mode,
      'notification_message': notificationMessage,
    };
  }

  String getDescription() {
    switch (type) {
      case ActionType.turnOn:
        return 'Turn on device';
      case ActionType.turnOff:
        return 'Turn off device';
      case ActionType.changeMode:
        return 'Change mode to $mode';
      case ActionType.sendNotification:
        return 'Send notification';
    }
  }
}

/// Trigger Type Enum
enum TriggerType {
  aqiAbove,
  aqiBelow,
  time,
  deviceOffline;

  String get displayName {
    switch (this) {
      case TriggerType.aqiAbove:
        return 'AQI Above Threshold';
      case TriggerType.aqiBelow:
        return 'AQI Below Threshold';
      case TriggerType.time:
        return 'At Specific Time';
      case TriggerType.deviceOffline:
        return 'Device Offline';
    }
  }

  static TriggerType fromString(String value) {
    switch (value) {
      case 'aqi_above':
        return TriggerType.aqiAbove;
      case 'aqi_below':
        return TriggerType.aqiBelow;
      case 'time':
        return TriggerType.time;
      case 'device_offline':
        return TriggerType.deviceOffline;
      default:
        return TriggerType.aqiAbove;
    }
  }
}

/// Action Type Enum
enum ActionType {
  turnOn,
  turnOff,
  changeMode,
  sendNotification;

  String get displayName {
    switch (this) {
      case ActionType.turnOn:
        return 'Turn On Device';
      case ActionType.turnOff:
        return 'Turn Off Device';
      case ActionType.changeMode:
        return 'Change Device Mode';
      case ActionType.sendNotification:
        return 'Send Notification';
    }
  }

  static ActionType fromString(String value) {
    switch (value) {
      case 'turn_on':
        return ActionType.turnOn;
      case 'turn_off':
        return ActionType.turnOff;
      case 'change_mode':
        return ActionType.changeMode;
      case 'send_notification':
        return ActionType.sendNotification;
      default:
        return ActionType.turnOn;
    }
  }
}
