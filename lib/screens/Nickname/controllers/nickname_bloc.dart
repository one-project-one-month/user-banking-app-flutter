import 'package:bloc/bloc.dart';
import 'nickname_event.dart';
import 'nickname_state.dart';
import '../services/nickname_api_service.dart';

class NicknameBloc extends Bloc<NicknameEvent, NicknameState> {
  final NicknameApiService api;

  NicknameBloc({NicknameApiService? apiService})
      : api = apiService ?? NicknameApiService(),
        super(const NicknameState()) {
    on<LoadNicknames>(_onLoad);
    on<CreateNickname>(_onCreate);
    on<UpdateNickname>(_onUpdate);
    on<DeleteNickname>(_onDelete);
  }

  Future<void> _onLoad(LoadNicknames event, Emitter<NicknameState> emit) async {
    emit(state.copyWith(status: NicknameStatus.loading, message: null));
    try {
      final items = await api.fetchNicknames();
      emit(state.copyWith(status: NicknameStatus.success, items: items));
    } catch (e) {
      emit(state.copyWith(status: NicknameStatus.failure, message: e.toString()));
    }
  }

  Future<void> _onCreate(CreateNickname event, Emitter<NicknameState> emit) async {
    emit(state.copyWith(status: NicknameStatus.loading));
    try {
      await api.createNickname(toaccountId: event.toaccountId, nickname: event.nickname);
      add(const LoadNicknames());
    } catch (e) {
      emit(state.copyWith(status: NicknameStatus.failure, message: e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateNickname event, Emitter<NicknameState> emit) async {
    emit(state.copyWith(status: NicknameStatus.loading));
    try {
      await api.updateNickname(id: event.id, toaccountId: event.toaccountId, nickname: event.nickname);
      add(const LoadNicknames());
    } catch (e) {
      emit(state.copyWith(status: NicknameStatus.failure, message: e.toString()));
    }
  }

  Future<void> _onDelete(DeleteNickname event, Emitter<NicknameState> emit) async {
    emit(state.copyWith(status: NicknameStatus.loading));
    try {
      await api.deleteNickname(event.id);
      add(const LoadNicknames());
    } catch (e) {
      emit(state.copyWith(status: NicknameStatus.failure, message: e.toString()));
    }
  }
}
