import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/common/repository_layer/enums/url_preload_methods_enum.dart';
import 'package:link_vault/core/services/custom_tabs_client_service.dart';
import 'package:link_vault/core/services/custom_tabs_service.dart';
import 'package:link_vault/core/utils/queue_manager.dart';

part 'url_preload_manager_state.dart';

class UrlPreloadManagerCubit extends Cubit<UrlPreloadManagerState> {
  UrlPreloadManagerCubit()
      : super(
          UrlPreloadManagerState.initial(),
        );

  // MAKE A QUEUE FOR EACH URL
  final AsyncQueueManager _preloadingQueue =
      AsyncQueueManager(maxConcurrentTasks: 8);

  // HANDLE ONE BY ONE EACH URL AND PERFORM A FUNCTION
  void preloadUrl(
    String url, {
    required UrlPreloadMethods urlPreloadMethod,
  }) {
    _preloadingQueue.addTask(
      () async => _preloadUrl(
        url: url,
        urlPreloadMethod: urlPreloadMethod,
      ),
    );
  }

  Future<void> _preloadUrl({
    required String url,
    required UrlPreloadMethods urlPreloadMethod,
  }) async {
    // Logger.printLog(
    //   '[customtabs] : $url _preloadUrl ',
    // );
    if (state.isUrlPreloaded(url)) return;

    switch (urlPreloadMethod) {
      case UrlPreloadMethods.httpHead:
        {
          await CustomTabsService.getUrlHeadData(url);
          break;
        }
      case UrlPreloadMethods.mayLaunchUrl:
        {
          await CustomTabsClientService.mayLaunchUrl(url);
          break;
        }
      case UrlPreloadMethods.httpGet:
        {
          await CustomTabsService.getUrlGetData(url);
          break;
        }
      case UrlPreloadMethods.none:
        {
          break;
        }
    }

    emit(
      state.copyWith(
        urlPreloadsData: {
          ...state.urlPreloadsData,
          url: true,
        },
      ),
    );
  }
}
