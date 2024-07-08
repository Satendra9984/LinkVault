part of 'shared_data_cubit.dart';


class SharedDataState extends Equatable {
  final List<SharedMediaFile> sharedData;

  SharedDataState({required this.sharedData});

  @override
  List<Object> get props => [sharedData];
}
