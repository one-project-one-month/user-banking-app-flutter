import 'package:equatable/equatable.dart';
import '../models/nickname.dart';

enum NicknameStatus { initial, loading, success, failure }

class NicknameState extends Equatable {
  final NicknameStatus status;
  final List<NicknameOption> items;
  final String? message;

  const NicknameState({this.status = NicknameStatus.initial, this.items = const [], this.message});

  NicknameState copyWith({NicknameStatus? status, List<NicknameOption>? items, String? message}) {
    return NicknameState(status: status ?? this.status, items: items ?? this.items, message: message ?? this.message);
  }

  @override
  List<Object?> get props => [status, items, message];
}
