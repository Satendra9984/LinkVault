import 'package:equatable/equatable.dart';
import 'package:link_vault/core/enums/loading_states.dart';
import 'package:link_vault/src/dashboard/data/models/url_model.dart';

class UrlFetchStateModel extends Equatable {

  const UrlFetchStateModel({
    required this.collectionId,
    required this.loadingStates, this.urlModel,
  });
  final String collectionId;
  final UrlModel? urlModel;
  final LoadingStates loadingStates;

  @override
  List<Object?> get props => [
        collectionId,
        urlModel,
        loadingStates,
      ];

  UrlFetchStateModel copyWith({
    String? collectionId,
    UrlModel? urlModel,
    LoadingStates? loadingStates,
  }) {
    return UrlFetchStateModel(
      collectionId: collectionId ?? this.collectionId,
      urlModel: urlModel ?? this.urlModel,
      loadingStates: loadingStates ?? this.loadingStates,
    );
  }
}
