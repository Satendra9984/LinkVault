import 'package:equatable/equatable.dart';
import 'package:link_vault/core/common/repository_layer/enums/loading_states.dart';
import 'package:link_vault/core/common/repository_layer/models/url_model.dart';

class UrlFetchStateModel extends Equatable {
  const UrlFetchStateModel({
    required this.collectionId,
    required this.loadingStates,
    this.urlModel,
    this.urlModelId,
  });
  final String collectionId;
  final String? urlModelId;
  final UrlModel? urlModel;
  final LoadingStates loadingStates;

  @override
  List<Object?> get props => [
        collectionId,
        urlModel,
        urlModelId,
        loadingStates,
      ];

  UrlFetchStateModel copyWith({
    String? collectionId,
    UrlModel? urlModel,
    String? urlModelId,
    LoadingStates? loadingStates,
  }) {
    return UrlFetchStateModel(
      collectionId: collectionId ?? this.collectionId,
      urlModel: urlModel ?? this.urlModel,
      urlModelId: urlModelId ?? this.urlModelId,
      loadingStates: loadingStates ?? this.loadingStates,
    );
  }
}
