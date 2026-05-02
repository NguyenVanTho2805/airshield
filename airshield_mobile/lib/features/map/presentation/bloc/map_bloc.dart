import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/station.dart';
import '../../data/repositories/map_repository.dart';

// ==================== EVENTS ====================

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

/// Load all stations for the map
class LoadStations extends MapEvent {
  const LoadStations();
}

// ==================== STATES ====================

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MapInitial extends MapState {
  const MapInitial();
}

/// Loading stations
class MapLoading extends MapState {
  const MapLoading();
}

/// Stations loaded successfully
class MapLoaded extends MapState {
  final List<AqiStation> stations;

  const MapLoaded({required this.stations});

  @override
  List<Object?> get props => [stations];
}

/// Error loading stations
class MapError extends MapState {
  final String message;

  const MapError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

/// Map BLoC
/// 
/// Manages the state of the AQI map screen
class MapBloc extends Bloc<MapEvent, MapState> {
  final MapRepository _repository;

  MapBloc({required MapRepository repository})
      : _repository = repository,
        super(const MapInitial()) {
    on<LoadStations>(_onLoadStations);
  }

  /// Handle LoadStations event
  Future<void> _onLoadStations(
    LoadStations event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());

    try {
      final stations = await _repository.getStations();
      emit(MapLoaded(stations: stations));
    } catch (e) {
      // Fallback to mock data
      emit(MapLoaded(stations: StationsMock.getMockStations()));
    }
  }
}
