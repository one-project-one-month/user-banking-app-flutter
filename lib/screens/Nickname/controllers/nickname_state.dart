import 'package:equatable/equatable.dart';
import '../models/nickname.dart';

enum NicknameStatus { initial, loading, success, failure }

class NicknameState extends Equatable {
  final NicknameStatus status;
  final List<NicknameOption> items;
  final String? message;
  final String? errorMessage;

  const NicknameState({this.status = NicknameStatus.initial, this.items = const [], this.message, this.errorMessage});

  NicknameState copyWith({NicknameStatus? status, List<NicknameOption>? items, String? message, String? errorMessage}) {
    return NicknameState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == NicknameStatus.loading;
  bool get isSuccess => status == NicknameStatus.success;
  bool get hasError => status == NicknameStatus.failure;

  @override
  List<Object?> get props => [status, items, message, errorMessage];
}
