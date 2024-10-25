import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Define a base class for different types of inputs
abstract class InputData extends Equatable {
  const InputData();
}

// Define a class for URL input
class UrlInput extends InputData {
  final String url;

  const UrlInput(this.url);

  @override
  List<Object?> get props => [url];
}

// Define a class for PDF input
class PdfInput extends InputData {
  final String filePath;

  const PdfInput(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

// Define the state class
class InputState extends Equatable {
  final List<InputData> inputs;

  const InputState(this.inputs);

  @override
  List<Object?> get props => [inputs];

  // Create a copyWith method to update the state
  InputState copyWith({List<InputData>? inputs}) {
    return InputState(inputs ?? this.inputs);
  }
}