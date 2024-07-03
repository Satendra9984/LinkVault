import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'subscription_state.dart';

/// GOOGLE REWARDED ADS DOCS
// https://developers.google.com/admob/flutter/quick-start
// https://developers.google.com/admob/flutter/rewarded
// https://www.youtube.com/watch?v=QTrWKWjUA30
class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit() : super(SubscriptionInitial());
}
