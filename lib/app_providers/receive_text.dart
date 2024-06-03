import 'package:riverpod/riverpod.dart';
import 'package:web_link_store/app_models/receive_text_model.dart';

final receiveTextProvider =
    StateNotifierProvider<ReceiveTextNotifier, ReceiveText>(
  (ref) => ReceiveTextNotifier(),
);

class ReceiveTextNotifier extends StateNotifier<ReceiveText> {
  ReceiveTextNotifier() : super(ReceiveText());

  void changeState(bool share, String text) {
    ReceiveText receiveText = ReceiveText();
    receiveText.isSharing = share;
    receiveText.receivedText = text;
    state = receiveText;
  }
}
