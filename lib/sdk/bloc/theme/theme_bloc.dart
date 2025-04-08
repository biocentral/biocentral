import 'package:biocentral/sdk/bloc/theme/theme_event.dart';
import 'package:biocentral/sdk/bloc/theme/theme_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'isDarkMode';
  static const bool defaultDarkMode = false;

  ThemeBloc() : super(const ThemeInitial(defaultDarkMode)) {
    on<InitializeThemeEvent>(_onInitialize);
    on<ToggleThemeEvent>(_onToggleTheme);
  }

  Future<void> _onInitialize(InitializeThemeEvent event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_themeKey) ?? false;
    emit(ThemeInitial(isDarkMode));
  }

  Future<void> _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();

    final newIsDarkMode = !state.isDarkMode;
    await prefs.setBool(_themeKey, newIsDarkMode);
    emit(ThemeToggled(newIsDarkMode));
  }
}
