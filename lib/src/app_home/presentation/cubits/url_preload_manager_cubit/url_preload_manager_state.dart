part of 'url_preload_manager_cubit.dart';

sealed class UrlPreloadManagerState extends Equatable {
  const UrlPreloadManagerState();

  @override
  List<Object> get props => [];
}

final class UrlPreloadManagerInitial extends UrlPreloadManagerState {}
