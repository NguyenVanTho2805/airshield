import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/health_condition.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../auth/data/models/user.dart';

/// Profile Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final User user;
  
  const LoadProfile(this.user);
  
  @override
  List<Object?> get props => [user];
}

class UpdateProfile extends ProfileEvent {
  final User user;
  
  const UpdateProfile(this.user);
  
  @override
  List<Object?> get props => [user];
}

class UploadAvatar extends ProfileEvent {
  final String imagePath;
  
  const UploadAvatar(this.imagePath);
  
  @override
  List<Object?> get props => [imagePath];
}

class LoadHealthConditions extends ProfileEvent {}

class UpdateHealthConditions extends ProfileEvent {
  final List<HealthCondition> conditions;
  
  const UpdateHealthConditions(this.conditions);
  
  @override
  List<Object?> get props => [conditions];
}

/// Profile States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;
  final List<HealthCondition> healthConditions;
  
  const ProfileLoaded({
    required this.user,
    this.healthConditions = const [],
  });
  
  @override
  List<Object?> get props => [user, healthConditions];
}

class ProfileUpdating extends ProfileState {}

class ProfileUpdated extends ProfileState {
  final User user;
  
  const ProfileUpdated(this.user);
  
  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;
  
  const ProfileError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Profile BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadAvatar>(_onUploadAvatar);
    on<LoadHealthConditions>(_onLoadHealthConditions);
    on<UpdateHealthConditions>(_onUpdateHealthConditions);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final healthConditions = await _repository.getHealthConditions();
      emit(ProfileLoaded(
        user: event.user,
        healthConditions: healthConditions,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdating());
    try {
      final updatedUser = await _repository.updateProfile(event.user);
      emit(ProfileUpdated(updatedUser));
      
      // Reload profile
      final healthConditions = await _repository.getHealthConditions();
      emit(ProfileLoaded(
        user: updatedUser,
        healthConditions: healthConditions,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUploadAvatar(
    UploadAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdating());
    try {
      final avatarUrl = await _repository.uploadAvatar(event.imagePath);
      final updatedUser = currentState.user.copyWith(avatarUrl: avatarUrl);
      final finalUser = await _repository.updateProfile(updatedUser);
      
      emit(ProfileLoaded(
        user: finalUser,
        healthConditions: currentState.healthConditions,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
      emit(currentState); // Revert to previous state
    }
  }

  Future<void> _onLoadHealthConditions(
    LoadHealthConditions event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    try {
      final healthConditions = await _repository.getHealthConditions();
      emit(ProfileLoaded(
        user: currentState.user,
        healthConditions: healthConditions,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateHealthConditions(
    UpdateHealthConditions event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdating());
    try {
      await _repository.updateHealthConditions(event.conditions);
      emit(ProfileLoaded(
        user: currentState.user,
        healthConditions: event.conditions,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
      emit(currentState); // Revert to previous state
    }
  }
}
