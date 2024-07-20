import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:link_vault/src/dashboard/data/models/shared_input_type';
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
      // Logger.printLog(
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
    // Logger.printLog('urlsshared: ${urls.length}');
    return urls;
  }

  void addUrlInput(String url) {
    final updatedInputs = List<UrlInput>.from(state.inputs)..add(UrlInput(url));
    emit(state.copyWith(inputs: updatedInputs));

    // Logger.printLog('[intents]: ${state.inputs.length.toString()}');
  }

  // Method to add a PDF input
  void addPdfInput(String filePath) {
    final updatedInputs = List<InputData>.from(state.inputs)
      ..add(PdfInput(filePath));
    // emit(state.copyWith(inputs: updatedInputs));
  }

  // Method to remove an input
  void removeUrlInput() {
    final updatedInputs = List<UrlInput>.from(state.inputs)..removeAt(0);
    emit(state.copyWith(inputs: updatedInputs));
  }
}
