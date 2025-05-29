import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:link_vault/src/common/repository_layer/models/shared_input_models.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

part 'shared_inputs_state.dart';

class SharedInputsCubit extends Cubit<SharedInputsState> {
  SharedInputsCubit()
      : super(
          const SharedInputsState(
            [],
          ),
        );

  void addInputFiles(List<SharedMediaFile> files) {
    for (final file in files) {
      // // Logger.printLog(
      //     'filetype: ${file.type.toString()}, message: ${file.path}');
      if (file.type == SharedMediaType.url ||
          file.type == SharedMediaType.text) {
        addUrlInput(file.path);
      }
    }
  }

  List<String> getUrlsList() {
    final urls = <String>[];
    for (final input in state.inputs) {
      urls.add(input.url);
    }
    // // Logger.printLog('urlsshared: ${urls.length}');
    return urls;
  }

  void addUrlInput(String url) {
    final updatedInputs = List<UrlInput>.from(state.inputs)
      ..insert(0, UrlInput(url));
    emit(state.copyWith(inputs: updatedInputs));
  }

  String? getTopUrl() {
    final urls = state.inputs;

    return urls.firstOrNull?.url;
  }

  // Method to add a PDF input
  void addPdfInput(String filePath) {
    final updatedInputs = List<InputData>.from(state.inputs)
      ..add(PdfInput(filePath));
    // emit(state.copyWith(inputs: updatedInputs));
  }

  // Method to remove an input
  void removeUrlInput(String? url) {
    if (url == null) return;
    try {
      final updatedInputs = List<UrlInput>.from(state.inputs)
        ..removeWhere(
          (element) => element.url == url,
        );
      emit(state.copyWith(inputs: updatedInputs));
    } catch (e) {
      // Logger.printLog('Error removing sharedurl from $e');
    }
  }
}
