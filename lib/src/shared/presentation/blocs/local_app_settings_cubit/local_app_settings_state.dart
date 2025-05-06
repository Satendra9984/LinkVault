part of 'local_app_settings_cubit.dart';

sealed class LocalAppSettingsState extends Equatable {
  const LocalAppSettingsState();

  @override
  List<Object> get props => [];
}

final class LocalAppSettingsInitial extends LocalAppSettingsState {}
