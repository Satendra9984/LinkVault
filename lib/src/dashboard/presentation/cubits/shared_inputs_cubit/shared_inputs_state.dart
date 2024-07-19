part of 'shared_inputs_cubit.dart';

class SharedInputsState extends Equatable {
  final List<UrlInput> inputs;

  const SharedInputsState(this.inputs);

  @override
  List<Object?> get props => [inputs];

  // Create a copyWith method to update the state
  SharedInputsState copyWith({
    List<UrlInput>? inputs,
  }) {
    return SharedInputsState(
      inputs ?? this.inputs,
    );
  }
}
