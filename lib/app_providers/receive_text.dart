import 'package:link_vault/app_models/receive_text_model.dart';
import 'package:riverpod/riverpod.dart';

final receiveTextProvider =
    StateNotifierProvider<ReceiveTextNotifier, ReceiveText>(
  (ref) => ReceiveTextNotifier(),
);

class ReceiveTextNotifier extends StateNotifier<ReceiveText> {
  ReceiveTextNotifier() : super(ReceiveText());

  void changeState(bool share, String text) {
    final receiveText = ReceiveText();
    receiveText.isSharing = share;
    receiveText.receivedText = text;
    state = receiveText;
  }
}
