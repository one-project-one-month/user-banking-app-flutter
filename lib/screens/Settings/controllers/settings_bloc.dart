import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const _kDark = 'settings_dark_mode';
  static const _kAuto = 'settings_auto_save';

  SettingsBloc() : super(SettingsState.initial()) {
    on<LoadSettings>(_onLoad);
    on<ToggleDarkMode>(_onToggleDark);
    on<ToggleAutoSave>(_onToggleAuto);
    on<LogoutPressed>(_onLogout);
  }

  Future<void> _onLoad(LoadSettings event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool(_kDark) ?? state.darkMode;
    final auto = prefs.getBool(_kAuto) ?? state.autoSave;
    emit(state.copyWith(darkMode: dark, autoSave: auto));
  }

  Future<void> _onToggleDark(ToggleDarkMode event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDark, event.enabled);
    emit(state.copyWith(darkMode: event.enabled));
  }

  Future<void> _onToggleAuto(ToggleAutoSave event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAuto, event.enabled);
    emit(state.copyWith(autoSave: event.enabled));
  }

  Future<void> _onLogout(LogoutPressed event, Emitter<SettingsState> emit) async {
    // Add real logout logic here. For now, clear saved flags and emit defaults.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDark);
    await prefs.remove(_kAuto);
    emit(SettingsState.initial());
  }
}
