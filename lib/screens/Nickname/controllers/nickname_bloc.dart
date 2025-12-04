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
    emit(state.copyWith(status: NicknameStatus.loading, message: null, errorMessage: null));

    try {
      final items = await api.fetchNicknames();
      emit(state.copyWith(status: NicknameStatus.success, items: items, message: 'Nicknames loaded successfully'));
    } catch (e) {
      print('❌ Load nicknames error: $e');
      emit(state.copyWith(status: NicknameStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreate(CreateNickname event, Emitter<NicknameState> emit) async {
    emit(state.copyWith(
      status: NicknameStatus.loading,
      message: null,
      errorMessage: null,
    ));

    try {
      print('✅ Creating nickname with account ID: ${event.toAccountId}');

      await api.createNickname(toAccountId: event.toAccountId, nickname: event.nickname);

      // Reload the list to get the updated nicknames with proper IDs
      final items = await api.fetchNicknames();
      emit(state.copyWith(
        status: NicknameStatus.success, 
        items: items,
        message: 'Nickname created successfully',
        errorMessage: null,
      ));
    } catch (e) {
      print('❌ Create nickname error: $e');
      emit(state.copyWith(
        status: NicknameStatus.failure,
        errorMessage: e.toString(),
        message: null,
      ));
    }
  }

  Future<void> _onUpdate(UpdateNickname event, Emitter<NicknameState> emit) async {
    emit(state.copyWith(
      status: NicknameStatus.loading,
      message: null,
      errorMessage: null,
    ));

    try {
      await api.updateNickname(id: event.id, toAccountId: event.toAccountId, nickname: event.nickname);

      // Reload the list to get the updated nicknames
      final items = await api.fetchNicknames();
      emit(state.copyWith(
        status: NicknameStatus.success,
        items: items,
        message: 'Nickname updated successfully',
        errorMessage: null,
      ));
    } catch (e) {
      print('❌ Update nickname error: $e');
      emit(state.copyWith(
        status: NicknameStatus.failure,
        errorMessage: e.toString(),
        message: null,
      ));
    }
  }

  Future<void> _onDelete(DeleteNickname event, Emitter<NicknameState> emit) async {
    emit(state.copyWith(
      status: NicknameStatus.loading,
      message: null,
      errorMessage: null,
    ));

    try {
      await api.deleteNickname(event.id);

      // Reload the list to show updated nicknames
      final items = await api.fetchNicknames();
      emit(state.copyWith(
        status: NicknameStatus.success,
        items: items,
        message: 'Nickname deleted successfully',
        errorMessage: null,
      ));
    } catch (e) {
      print('❌ Delete nickname error: $e');
      emit(state.copyWith(
        status: NicknameStatus.failure,
        errorMessage: e.toString(),
        message: null,
      ));
    }
  }

  @override
  Future<void> close() {
    api.dispose();
    return super.close();
  }
}
