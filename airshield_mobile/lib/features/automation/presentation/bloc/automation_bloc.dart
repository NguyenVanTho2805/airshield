import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/automation_rule.dart';
import '../../data/repositories/automation_repository.dart';

// ==================== EVENTS ====================

abstract class AutomationEvent extends Equatable {
  const AutomationEvent();

  @override
  List<Object?> get props => [];
}

/// Load all rules
class LoadRules extends AutomationEvent {
  const LoadRules();
}

/// Create new rule
class CreateRule extends AutomationEvent {
  final AutomationRule rule;

  const CreateRule(this.rule);

  @override
  List<Object?> get props => [rule];
}

/// Update existing rule
class UpdateRule extends AutomationEvent {
  final AutomationRule rule;

  const UpdateRule(this.rule);

  @override
  List<Object?> get props => [rule];
}

/// Delete rule
class DeleteRule extends AutomationEvent {
  final String ruleId;

  const DeleteRule(this.ruleId);

  @override
  List<Object?> get props => [ruleId];
}

/// Toggle rule enabled state
class ToggleRule extends AutomationEvent {
  final String ruleId;

  const ToggleRule(this.ruleId);

  @override
  List<Object?> get props => [ruleId];
}

// ==================== STATES ====================

abstract class AutomationState extends Equatable {
  const AutomationState();

  @override
  List<Object?> get props => [];
}

class AutomationInitial extends AutomationState {
  const AutomationInitial();
}

class AutomationLoading extends AutomationState {
  const AutomationLoading();
}

class AutomationLoaded extends AutomationState {
  final List<AutomationRule> rules;

  const AutomationLoaded(this.rules);

  @override
  List<Object?> get props => [rules];
}

class AutomationError extends AutomationState {
  final String message;

  const AutomationError(this.message);

  @override
  List<Object?> get props => [message];
}

class RuleCreated extends AutomationState {
  final AutomationRule rule;

  const RuleCreated(this.rule);

  @override
  List<Object?> get props => [rule];
}

class RuleUpdated extends AutomationState {
  final AutomationRule rule;

  const RuleUpdated(this.rule);

  @override
  List<Object?> get props => [rule];
}

class RuleDeleted extends AutomationState {
  const RuleDeleted();
}

// ==================== BLOC ====================

/// Automation BLoC
/// 
/// Manages automation rules state and operations
class AutomationBloc extends Bloc<AutomationEvent, AutomationState> {
  final AutomationRepository repository;

  AutomationBloc({required this.repository}) : super(const AutomationInitial()) {
    on<LoadRules>(_onLoadRules);
    on<CreateRule>(_onCreateRule);
    on<UpdateRule>(_onUpdateRule);
    on<DeleteRule>(_onDeleteRule);
    on<ToggleRule>(_onToggleRule);
  }

  Future<void> _onLoadRules(
    LoadRules event,
    Emitter<AutomationState> emit,
  ) async {
    emit(const AutomationLoading());

    try {
      final rules = await repository.getRules();
      emit(AutomationLoaded(rules));
    } catch (e) {
      emit(AutomationError('Failed to load rules: ${e.toString()}'));
    }
  }

  Future<void> _onCreateRule(
    CreateRule event,
    Emitter<AutomationState> emit,
  ) async {
    try {
      final newRule = await repository.createRule(event.rule);
      emit(RuleCreated(newRule));
      
      // Reload rules
      add(const LoadRules());
    } catch (e) {
      emit(AutomationError('Failed to create rule: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateRule(
    UpdateRule event,
    Emitter<AutomationState> emit,
  ) async {
    try {
      final updatedRule = await repository.updateRule(event.rule);
      emit(RuleUpdated(updatedRule));
      
      // Reload rules
      add(const LoadRules());
    } catch (e) {
      emit(AutomationError('Failed to update rule: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteRule(
    DeleteRule event,
    Emitter<AutomationState> emit,
  ) async {
    try {
      await repository.deleteRule(event.ruleId);
      emit(const RuleDeleted());
      
      // Reload rules
      add(const LoadRules());
    } catch (e) {
      emit(AutomationError('Failed to delete rule: ${e.toString()}'));
    }
  }

  Future<void> _onToggleRule(
    ToggleRule event,
    Emitter<AutomationState> emit,
  ) async {
    try {
      await repository.toggleRule(event.ruleId);
      
      // Reload rules
      add(const LoadRules());
    } catch (e) {
      emit(AutomationError('Failed to toggle rule: ${e.toString()}'));
    }
  }
}
