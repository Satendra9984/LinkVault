part of 'app_initialization_bloc.dart';

sealed class AppInitializationState extends Equatable {
  const AppInitializationState();

  @override
  List<Object> get props => [];
}

final class AppInitializationInitial extends AppInitializationState {}

final class AppInitializationLoading extends AppInitializationState {}

final class AppInitializationLoaded extends AppInitializationState {}

final class AppInitializationErrorLoading extends AppInitializationState {}
