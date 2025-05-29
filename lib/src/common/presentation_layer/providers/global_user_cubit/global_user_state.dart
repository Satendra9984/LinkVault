// ignore_for_file: public_member_api_docs

part of 'global_user_cubit.dart';

class GlobalUserState extends Equatable {
  const GlobalUserState({
    required this.globalUser,
  });

  final GlobalUser? globalUser;
  GlobalUserState copyWith({
    GlobalUser? globalUser,
  }) {
    return GlobalUserState(
      globalUser: globalUser ?? this.globalUser,
    );
  }

  @override
  List<Object?> get props => [globalUser];
}
