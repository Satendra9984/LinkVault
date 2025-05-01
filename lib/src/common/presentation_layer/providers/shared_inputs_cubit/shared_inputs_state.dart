part of 'shared_inputs_cubit.dart';

class SharedInputsState extends Equatable {

  const SharedInputsState(this.inputs);
  final List<UrlInput> inputs;

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
