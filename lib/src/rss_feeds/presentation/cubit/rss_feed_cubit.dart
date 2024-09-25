import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'rss_feed_state.dart';

class RssFeedCubit extends Cubit<RssFeedState> {
  RssFeedCubit() : super(RssFeedInitial());
}
