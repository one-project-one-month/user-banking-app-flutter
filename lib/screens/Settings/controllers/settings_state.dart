import 'package:equatable/equatable.dart';
import '../models/user_profile.dart';

class SettingsState extends Equatable {
  final bool darkMode;
  final bool autoSave;
  final UserProfile user;
  final bool loading;

  const SettingsState({
    required this.darkMode,
    required this.autoSave,
    required this.user,
    this.loading = false,
  });

  factory SettingsState.initial() => SettingsState(
        darkMode: true,
        autoSave: true,
        user: const UserProfile(name: 'Ms. Sam', phone: '0652165910'),
        loading: false,
      );

  SettingsState copyWith({
    bool? darkMode,
    bool? autoSave,
    UserProfile? user,
    bool? loading,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      autoSave: autoSave ?? this.autoSave,
      user: user ?? this.user,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [darkMode, autoSave, user, loading];
}
