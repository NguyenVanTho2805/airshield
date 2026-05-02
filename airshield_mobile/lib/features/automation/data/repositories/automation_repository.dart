import 'package:flutter/material.dart';

import '../models/automation_rule.dart';

/// Automation Repository
/// 
/// Manages automation rules with mock data
class AutomationRepository {
  final List<AutomationRule> _rules = [];

  /// Get all automation rules
  Future<List<AutomationRule>> getRules() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Initialize with mock rules if empty
    if (_rules.isEmpty) {
      _initializeMockRules();
    }
    
    return List.from(_rules);
  }

  /// Get rule by ID
  Future<AutomationRule?> getRuleById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _rules.firstWhere((rule) => rule.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create new rule
  Future<AutomationRule> createRule(AutomationRule rule) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final newRule = rule.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
    );
    
    _rules.add(newRule);
    return newRule;
  }

  /// Update existing rule
  Future<AutomationRule> updateRule(AutomationRule rule) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _rules.indexWhere((r) => r.id == rule.id);
    if (index == -1) {
      throw Exception('Rule not found');
    }
    
    _rules[index] = rule;
    return rule;
  }

  /// Delete rule
  Future<void> deleteRule(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _rules.removeWhere((rule) => rule.id == id);
  }

  /// Toggle rule enabled state
  Future<AutomationRule> toggleRule(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _rules.indexWhere((r) => r.id == id);
    if (index == -1) {
      throw Exception('Rule not found');
    }
    
    final updatedRule = _rules[index].copyWith(
      isEnabled: !_rules[index].isEnabled,
    );
    
    _rules[index] = updatedRule;
    return updatedRule;
  }

  /// Initialize mock rules
  void _initializeMockRules() {
    _rules.addAll([
      AutomationRule(
        id: '1',
        name: 'High AQI Alert',
        isEnabled: true,
        trigger: const RuleTrigger(
          type: TriggerType.aqiAbove,
          aqiThreshold: 100,
        ),
        action: const RuleAction(
          type: ActionType.turnOn,
          deviceId: 'device-1',
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        lastTriggered: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AutomationRule(
        id: '2',
        name: 'Good Air - Auto Off',
        isEnabled: true,
        trigger: const RuleTrigger(
          type: TriggerType.aqiBelow,
          aqiThreshold: 50,
        ),
        action: const RuleAction(
          type: ActionType.turnOff,
          deviceId: 'device-1',
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      AutomationRule(
        id: '3',
        name: 'Morning Routine',
        isEnabled: false,
        trigger: const RuleTrigger(
          type: TriggerType.time,
          timeOfDay: TimeOfDay(hour: 7, minute: 0),
        ),
        action: const RuleAction(
          type: ActionType.changeMode,
          deviceId: 'device-1',
          mode: 'auto',
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ]);
  }

  /// Evaluate rules against current conditions (for simulation)
  Future<List<AutomationRule>> evaluateRules({
    required int currentAqi,
    required DateTime currentTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final triggeredRules = <AutomationRule>[];
    
    for (final rule in _rules) {
      if (!rule.isEnabled) continue;
      
      bool shouldTrigger = false;
      
      switch (rule.trigger.type) {
        case TriggerType.aqiAbove:
          shouldTrigger = currentAqi > (rule.trigger.aqiThreshold ?? 0);
          break;
        case TriggerType.aqiBelow:
          shouldTrigger = currentAqi < (rule.trigger.aqiThreshold ?? 999);
          break;
        case TriggerType.time:
          if (rule.trigger.timeOfDay != null) {
            shouldTrigger = currentTime.hour == rule.trigger.timeOfDay!.hour &&
                currentTime.minute == rule.trigger.timeOfDay!.minute;
          }
          break;
        case TriggerType.deviceOffline:
          // Would check device status in real implementation
          shouldTrigger = false;
          break;
      }
      
      if (shouldTrigger) {
        triggeredRules.add(rule);
      }
    }
    
    return triggeredRules;
  }
}
