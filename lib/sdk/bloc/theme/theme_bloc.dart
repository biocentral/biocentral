import 'package:biocentral/sdk/bloc/theme/theme_event.dart';
import 'package:biocentral/sdk/bloc/theme/theme_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'isDarkMode';
  final SharedPreferences prefs;

  ThemeBloc({required this.prefs}) : super(ThemeInitial(prefs.getBool(_themeKey) ?? false)) {
    on<InitializeThemeEvent>(_onInitialize);
    on<ToggleThemeEvent>(_onToggleTheme);
  }

  Future<void> _onInitialize(InitializeThemeEvent event, Emitter<ThemeState> emit) async {
    final isDarkMode = prefs.getBool(_themeKey) ?? false;
    emit(ThemeInitial(isDarkMode));
  }

  Future<void> _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    final newIsDarkMode = !state.isDarkMode;
    await prefs.setBool(_themeKey, newIsDarkMode);
    emit(ThemeToggled(newIsDarkMode));
  }
}
