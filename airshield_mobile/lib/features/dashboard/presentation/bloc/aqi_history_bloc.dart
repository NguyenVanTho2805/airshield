import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/aqi_data_point.dart';
import '../../data/repositories/dashboard_repository.dart';

// ==================== EVENTS ====================

abstract class AQIHistoryEvent extends Equatable {
  const AQIHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load AQI history for a time range
class LoadAQIHistory extends AQIHistoryEvent {
  final TimeRange timeRange;

  const LoadAQIHistory(this.timeRange);

  @override
  List<Object?> get props => [timeRange];
}

/// Change time range
class ChangeTimeRange extends AQIHistoryEvent {
  final TimeRange timeRange;

  const ChangeTimeRange(this.timeRange);

  @override
  List<Object?> get props => [timeRange];
}

// ==================== STATES ====================

abstract class AQIHistoryState extends Equatable {
  const AQIHistoryState();

  @override
  List<Object?> get props => [];
}

class AQIHistoryInitial extends AQIHistoryState {
  const AQIHistoryInitial();
}

class AQIHistoryLoading extends AQIHistoryState {
  const AQIHistoryLoading();
}

class AQIHistoryLoaded extends AQIHistoryState {
  final List<AQIDataPoint> dataPoints;
  final TimeRange timeRange;

  const AQIHistoryLoaded({
    required this.dataPoints,
    required this.timeRange,
  });

  @override
  List<Object?> get props => [dataPoints, timeRange];
}

class AQIHistoryError extends AQIHistoryState {
  final String message;

  const AQIHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

/// AQI History BLoC
/// 
/// Manages AQI historical data and time range selection
class AQIHistoryBloc extends Bloc<AQIHistoryEvent, AQIHistoryState> {
  final DashboardRepository repository;

  AQIHistoryBloc({required this.repository}) : super(const AQIHistoryInitial()) {
    on<LoadAQIHistory>(_onLoadAQIHistory);
    on<ChangeTimeRange>(_onChangeTimeRange);
  }

  Future<void> _onLoadAQIHistory(
    LoadAQIHistory event,
    Emitter<AQIHistoryState> emit,
  ) async {
    emit(const AQIHistoryLoading());

    try {
      final dataPoints = await repository.getAQIHistory(event.timeRange);
      emit(AQIHistoryLoaded(
        dataPoints: dataPoints,
        timeRange: event.timeRange,
      ));
    } catch (e) {
      emit(AQIHistoryError('Failed to load AQI history: ${e.toString()}'));
    }
  }

  Future<void> _onChangeTimeRange(
    ChangeTimeRange event,
    Emitter<AQIHistoryState> emit,
  ) async {
    // Trigger reload with new time range
    add(LoadAQIHistory(event.timeRange));
  }
}
