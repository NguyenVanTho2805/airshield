import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/notification.dart';
import '../../data/services/notification_service.dart';

// ==================== EVENTS ====================

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

/// Load notifications
class LoadNotifications extends NotificationsEvent {
  const LoadNotifications();
}

/// Mark notification as read
class MarkAsRead extends NotificationsEvent {
  final String notificationId;

  const MarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all as read
class MarkAllAsRead extends NotificationsEvent {
  const MarkAllAsRead();
}

/// Delete notification
class DeleteNotification extends NotificationsEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Clear all notifications
class ClearAll extends NotificationsEvent {
  const ClearAll();
}

/// Simulate notification (for testing)
class SimulateNotification extends NotificationsEvent {
  final NotificationType type;

  const SimulateNotification(this.type);

  @override
  List<Object?> get props => [type];
}

// ==================== STATES ====================

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> notifications;
  final int unreadCount;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

/// Notifications BLoC
/// 
/// Manages notification state and operations
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationService service;

  NotificationsBloc({required this.service}) : super(const NotificationsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<ClearAll>(_onClearAll);
    on<SimulateNotification>(_onSimulateNotification);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());

    try {
      final notifications = await service.getNotifications();
      final unreadCount = await service.getUnreadCount();
      
      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationsError('Failed to load notifications: ${e.toString()}'));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await service.markAsRead(event.notificationId);
      add(const LoadNotifications());
    } catch (e) {
      emit(NotificationsError('Failed to mark as read: ${e.toString()}'));
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await service.markAllAsRead();
      add(const LoadNotifications());
    } catch (e) {
      emit(NotificationsError('Failed to mark all as read: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await service.deleteNotification(event.notificationId);
      add(const LoadNotifications());
    } catch (e) {
      emit(NotificationsError('Failed to delete notification: ${e.toString()}'));
    }
  }

  Future<void> _onClearAll(
    ClearAll event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await service.clearAll();
      add(const LoadNotifications());
    } catch (e) {
      emit(NotificationsError('Failed to clear notifications: ${e.toString()}'));
    }
  }

  Future<void> _onSimulateNotification(
    SimulateNotification event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await service.simulateNotification(event.type);
      add(const LoadNotifications());
    } catch (e) {
      emit(NotificationsError('Failed to simulate notification: ${e.toString()}'));
    }
  }
}
