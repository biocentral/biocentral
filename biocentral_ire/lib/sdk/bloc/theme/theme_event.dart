abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {
  final bool isDarkMode;

  ToggleThemeEvent(this.isDarkMode);
}

class InitializeThemeEvent extends ThemeEvent {}
