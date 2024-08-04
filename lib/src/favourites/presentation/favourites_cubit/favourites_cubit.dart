import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'favourites_state.dart';

class FavouritesCubit extends Cubit<FavouritesState> {
  FavouritesCubit() : super(FavouritesInitial());
}
