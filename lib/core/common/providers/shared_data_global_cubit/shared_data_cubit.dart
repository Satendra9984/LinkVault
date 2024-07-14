import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/utils/logger.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
part 'shared_data_state.dart';

class SharedDataCubit extends Cubit<SharedDataState> {
  SharedDataCubit()
      : super(
          SharedDataState(
            sharedData: const [],
          ),
        );

  late final StreamSubscription _intentDataStreamSubscription;

  void init() {
    // Listen to shared data stream
    _intentDataStreamSubscription =
        ReceiveSharingIntent.instance.getMediaStream().listen(
      _processSharedData,
      onError: (err) {
        Logger.printLog('getIntentDataStream error: $err');
      },
    );

    // Get the initial shared data
    ReceiveSharingIntent.instance.getInitialMedia().then(_processSharedData);
  }

  void _processSharedData(List<SharedMediaFile> sharedData) {
    emit(SharedDataState(sharedData: sharedData));
  }

  @override
  Future<void> close() {
    _intentDataStreamSubscription.cancel();
    return super.close();
  }
}
