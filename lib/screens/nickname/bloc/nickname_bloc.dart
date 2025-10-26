import 'package:flutter_bloc/flutter_bloc.dart';
import 'nickname_event.dart';
import 'nickname_state.dart';

class NicknameBloc extends Bloc<NicknameEvent, NicknameState> {
  NicknameBloc() : super(const NicknameState()) {
    on<NicknameChanged>((event, emit) {
      final nickname = event.nickname.trim();
      final accountNumber = event.accountNumber.trim();
      
      final isButtonEnabled = nickname.isNotEmpty && accountNumber.isNotEmpty && accountNumber.length >= 7;

      emit(state.copyWith(
        nickname: nickname,
        accountNumber: accountNumber,
        isButtonEnabled: isButtonEnabled,
      ));
    });
  }
}
