import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/saved_location.dart';
import '../../data/repositories/profile_repository.dart';

/// Locations Events
abstract class LocationsEvent extends Equatable {
  const LocationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadLocations extends LocationsEvent {}

class AddLocation extends LocationsEvent {
  final SavedLocation location;
  
  const AddLocation(this.location);
  
  @override
  List<Object?> get props => [location];
}

class UpdateLocation extends LocationsEvent {
  final SavedLocation location;
  
  const UpdateLocation(this.location);
  
  @override
  List<Object?> get props => [location];
}

class DeleteLocation extends LocationsEvent {
  final String id;
  
  const DeleteLocation(this.id);
  
  @override
  List<Object?> get props => [id];
}

class SetDefaultLocation extends LocationsEvent {
  final String id;
  
  const SetDefaultLocation(this.id);
  
  @override
  List<Object?> get props => [id];
}

/// Locations States
abstract class LocationsState extends Equatable {
  const LocationsState();

  @override
  List<Object?> get props => [];
}

class LocationsInitial extends LocationsState {}

class LocationsLoading extends LocationsState {}

class LocationsLoaded extends LocationsState {
  final List<SavedLocation> locations;
  
  const LocationsLoaded(this.locations);
  
  @override
  List<Object?> get props => [locations];
  
  SavedLocation? get defaultLocation =>
      locations.where((l) => l.isDefault).firstOrNull;
}

class LocationsError extends LocationsState {
  final String message;
  
  const LocationsError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Locations BLoC
class LocationsBloc extends Bloc<LocationsEvent, LocationsState> {
  final ProfileRepository _repository;

  LocationsBloc({required ProfileRepository repository})
      : _repository = repository,
        super(LocationsInitial()) {
    on<LoadLocations>(_onLoadLocations);
    on<AddLocation>(_onAddLocation);
    on<UpdateLocation>(_onUpdateLocation);
    on<DeleteLocation>(_onDeleteLocation);
    on<SetDefaultLocation>(_onSetDefaultLocation);
  }

  Future<void> _onLoadLocations(
    LoadLocations event,
    Emitter<LocationsState> emit,
  ) async {
    emit(LocationsLoading());
    try {
      final locations = await _repository.getSavedLocations();
      emit(LocationsLoaded(locations));
    } catch (e) {
      emit(LocationsError(e.toString()));
    }
  }

  Future<void> _onAddLocation(
    AddLocation event,
    Emitter<LocationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LocationsLoaded) return;

    try {
      await _repository.addSavedLocation(event.location);
      final locations = await _repository.getSavedLocations();
      emit(LocationsLoaded(locations));
    } catch (e) {
      emit(LocationsError(e.toString()));
      emit(currentState); // Revert to previous state
    }
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<LocationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LocationsLoaded) return;

    try {
      await _repository.updateSavedLocation(event.location);
      final locations = await _repository.getSavedLocations();
      emit(LocationsLoaded(locations));
    } catch (e) {
      emit(LocationsError(e.toString()));
      emit(currentState); // Revert to previous state
    }
  }

  Future<void> _onDeleteLocation(
    DeleteLocation event,
    Emitter<LocationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LocationsLoaded) return;

    try {
      await _repository.deleteSavedLocation(event.id);
      final locations = await _repository.getSavedLocations();
      emit(LocationsLoaded(locations));
    } catch (e) {
      emit(LocationsError(e.toString()));
      emit(currentState); // Revert to previous state
    }
  }

  Future<void> _onSetDefaultLocation(
    SetDefaultLocation event,
    Emitter<LocationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LocationsLoaded) return;

    try {
      await _repository.setDefaultLocation(event.id);
      final locations = await _repository.getSavedLocations();
      emit(LocationsLoaded(locations));
    } catch (e) {
      emit(LocationsError(e.toString()));
      emit(currentState); // Revert to previous state
    }
  }
}
