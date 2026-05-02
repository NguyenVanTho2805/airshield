import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/device.dart';
import '../../data/repositories/smart_home_repository.dart';

// ==================== EVENTS ====================

abstract class SmartHomeEvent extends Equatable {
  const SmartHomeEvent();

  @override
  List<Object?> get props => [];
}

/// Load all devices
class LoadDevices extends SmartHomeEvent {
  const LoadDevices();
}

/// Toggle device power on/off
class TogglePower extends SmartHomeEvent {
  final String deviceId;

  const TogglePower({required this.deviceId});

  @override
  List<Object?> get props => [deviceId];
}

/// Change device operating mode
class ChangeMode extends SmartHomeEvent {
  final String deviceId;
  final DeviceMode mode;

  const ChangeMode({required this.deviceId, required this.mode});

  @override
  List<Object?> get props => [deviceId, mode];
}

/// Add a new device
class AddDevice extends SmartHomeEvent {
  final String deviceName;
  final String provider;

  const AddDevice({required this.deviceName, required this.provider});

  @override
  List<Object?> get props => [deviceName, provider];
}

/// Rename an existing device
class RenameDevice extends SmartHomeEvent {
  final String deviceId;
  final String newName;

  const RenameDevice({required this.deviceId, required this.newName});

  @override
  List<Object?> get props => [deviceId, newName];
}

// ==================== STATES ====================

abstract class SmartHomeState extends Equatable {
  const SmartHomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SmartHomeInitial extends SmartHomeState {
  const SmartHomeInitial();
}

/// Loading devices
class SmartHomeLoading extends SmartHomeState {
  const SmartHomeLoading();
}

/// Devices loaded successfully
class SmartHomeLoaded extends SmartHomeState {
  final List<SmartDevice> devices;

  const SmartHomeLoaded({required this.devices});

  @override
  List<Object?> get props => [devices];
}

/// Error loading devices
class SmartHomeError extends SmartHomeState {
  final String message;

  const SmartHomeError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

/// Smart Home BLoC
/// 
/// Manages the state of smart home devices
class SmartHomeBloc extends Bloc<SmartHomeEvent, SmartHomeState> {
  final SmartHomeRepository _repository;

  SmartHomeBloc({required SmartHomeRepository repository})
      : _repository = repository,
        super(const SmartHomeInitial()) {
    on<LoadDevices>(_onLoadDevices);
    on<TogglePower>(_onTogglePower);
    on<ChangeMode>(_onChangeMode);
    on<AddDevice>(_onAddDevice);
    on<RenameDevice>(_onRenameDevice);
  }

  /// Handle LoadDevices event
  Future<void> _onLoadDevices(
    LoadDevices event,
    Emitter<SmartHomeState> emit,
  ) async {
    emit(const SmartHomeLoading());

    try {
      final devices = await _repository.getDevices();
      emit(SmartHomeLoaded(devices: devices));
    } catch (e) {
      emit(SmartHomeError(message: e.toString()));
    }
  }

  /// Handle TogglePower event
  Future<void> _onTogglePower(
    TogglePower event,
    Emitter<SmartHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SmartHomeLoaded) return;

    try {
      final updatedDevice = await _repository.togglePower(event.deviceId);
      
      final updatedDevices = currentState.devices.map((device) {
        if (device.deviceId == event.deviceId) {
          return updatedDevice;
        }
        return device;
      }).toList();

      emit(SmartHomeLoaded(devices: updatedDevices));
    } catch (e) {
      // Revert to current state on error
      emit(currentState);
    }
  }

  /// Handle ChangeMode event
  Future<void> _onChangeMode(
    ChangeMode event,
    Emitter<SmartHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SmartHomeLoaded) return;

    try {
      final updatedDevice = await _repository.changeMode(event.deviceId, event.mode);

      final updatedDevices = currentState.devices.map((device) {
        if (device.deviceId == event.deviceId) return updatedDevice;
        return device;
      }).toList();

      emit(SmartHomeLoaded(devices: updatedDevices));
    } catch (e) {
      emit(currentState);
    }
  }

  /// Handle AddDevice event
  Future<void> _onAddDevice(
    AddDevice event,
    Emitter<SmartHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SmartHomeLoaded) return;

    try {
      final newDevice = await _repository.addDevice(
        deviceName: event.deviceName,
        provider: event.provider,
      );
      emit(SmartHomeLoaded(devices: [...currentState.devices, newDevice]));
    } catch (e) {
      emit(currentState);
    }
  }

  /// Handle RenameDevice event
  Future<void> _onRenameDevice(
    RenameDevice event,
    Emitter<SmartHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SmartHomeLoaded) return;

    try {
      final updatedDevice = await _repository.renameDevice(event.deviceId, event.newName);

      final updatedDevices = currentState.devices.map((device) {
        if (device.deviceId == event.deviceId) return updatedDevice;
        return device;
      }).toList();

      emit(SmartHomeLoaded(devices: updatedDevices));
    } catch (e) {
      emit(currentState);
    }
  }
}
