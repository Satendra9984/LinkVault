import 'package:equatable/equatable.dart';

// Define a base class for different types of inputs
abstract class InputData extends Equatable {
  const InputData();
}

// Define a class for URL input
class UrlInput extends InputData {

  const UrlInput(this.url);
  final String url;

  @override
  List<Object?> get props => [url];
}

// Define a class for PDF input
class PdfInput extends InputData {

  const PdfInput(this.filePath);
  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

// Define the state class
class InputState extends Equatable {

  const InputState(this.inputs);
  final List<InputData> inputs;

  @override
  List<Object?> get props => [inputs];

  // Create a copyWith method to update the state
  InputState copyWith({List<InputData>? inputs}) {
    return InputState(inputs ?? this.inputs);
  }
}