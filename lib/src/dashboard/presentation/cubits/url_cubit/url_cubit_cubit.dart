import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'url_cubit_state.dart';

class UrlCubitCubit extends Cubit<UrlCubitState> {
  UrlCubitCubit()
      : super(
          UrlCubitState(),
        );
}
