import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'url_preload_manager_state.dart';

class UrlPreloadManagerCubit extends Cubit<UrlPreloadManagerState> {
  UrlPreloadManagerCubit()
      : super(
          UrlPreloadManagerInitial(),
        );

  // TODO : MAKE A QUEUE FOR EACH URL

  // TODO : HANDLE ONE BY ONE EACH URL AND PERFORM A FUNCTION
}
