import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'collection_crud_state.dart';

class CollectionCrudCubit extends Cubit<CollectionCrudState> {
  CollectionCrudCubit() : super(CollectionCrudInitial());
}
