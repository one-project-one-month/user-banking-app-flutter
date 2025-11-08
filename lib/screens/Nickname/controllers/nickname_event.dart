import 'package:equatable/equatable.dart';

abstract class NicknameEvent extends Equatable {
  const NicknameEvent();
  @override
  List<Object?> get props => [];
}

class LoadNicknames extends NicknameEvent {
  const LoadNicknames();
}

class CreateNickname extends NicknameEvent {
  final String toaccountId;
  final String nickname;
  const CreateNickname({required this.toaccountId, required this.nickname});
  @override
  List<Object?> get props => [toaccountId, nickname];
}

class UpdateNickname extends NicknameEvent {
  final String id;
  final String toaccountId;
  final String nickname;
  const UpdateNickname({required this.id, required this.toaccountId, required this.nickname});
  @override
  List<Object?> get props => [id, toaccountId, nickname];
}

class DeleteNickname extends NicknameEvent {
  final String id;
  const DeleteNickname(this.id);
  @override
  List<Object?> get props => [id];
}
