import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/aqi_history.dart';
import '../../data/models/dashboard_data.dart';
import '../../data/repositories/dashboard_repository.dart';

import '../../data/models/aqi_forecast.dart';

// ==================== EVENTS ====================

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load dashboard data
class LoadDashboardData extends DashboardEvent {
  const LoadDashboardData();
}

/// Event to refresh dashboard data
class RefreshDashboardData extends DashboardEvent {
  const RefreshDashboardData();
}

// ==================== STATES ====================

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state while fetching data
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Success state with dashboard data
class DashboardLoaded extends DashboardState {
  final DashboardData data;
  final AqiHistoryResponse historyData;
  final AqiForecastResponse forecastData;

  const DashboardLoaded({
    required this.data,
    required this.historyData,
    required this.forecastData,
  });

  @override
  List<Object?> get props => [data, historyData, forecastData];
}

/// Error state when data fetch fails
class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

/// Dashboard BLoC
/// 
/// Manages the state of the dashboard screen
/// Handles loading and refreshing AQI data
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;

  DashboardBloc({required DashboardRepository repository})
      : _repository = repository,
        super(const DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
  }

  /// Handle LoadDashboardData event.
  /// Falls back to mock data on any error/timeout so the screen
  /// never gets stuck in loading or crashes to the error state.
  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    try {
      final results = await Future.wait([
        _repository.getDashboardData(),
        _repository.getAqiForecast(),
      ]).timeout(const Duration(seconds: 5));

      emit(DashboardLoaded(
        data: results[0] as DashboardData,
        historyData: AqiHistoryMock.getMockHistory(),
        forecastData: results[1] as AqiForecastResponse,
      ));
    } catch (_) {
      // API unavailable or location timed out — show mock data immediately
      emit(DashboardLoaded(
        data: DashboardRepository.getMockData(),
        historyData: AqiHistoryMock.getMockHistory(),
        forecastData: AqiForecastMock.getMockForecast(),
      ));
    }
  }

  /// Handle RefreshDashboardData event
  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    // Keep current data while refreshing (don't show loading)
    final currentState = state;

    try {
      final data = await _repository.getDashboardData();
      final historyData = AqiHistoryMock.getMockHistory();
      final forecastData = await _repository.getAqiForecast();
      emit(DashboardLoaded(data: data, historyData: historyData, forecastData: forecastData));
    } catch (e) {
      // If refresh fails, keep current state if available
      if (currentState is DashboardLoaded) {
        emit(currentState);
      } else {
        emit(DashboardLoaded(
          data: DashboardRepository.getMockData(),
          historyData: AqiHistoryMock.getMockHistory(),
          forecastData: AqiForecastMock.getMockForecast(),
        ));
      }
    }
  }
}
