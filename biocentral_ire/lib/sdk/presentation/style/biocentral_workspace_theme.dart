import 'package:flutter/material.dart';

/// Semantic colors beyond Flutter's [ColorScheme] for research workspaces.
@immutable
class BiocentralWorkspaceColors extends ThemeExtension<BiocentralWorkspaceColors> {
  final Color success;
  final Color warning;
  final Color muted;

  const BiocentralWorkspaceColors({
    this.success = const Color(0xFF15803D),
    this.warning = const Color(0xFFB45309),
    this.muted = const Color(0xFF8A9490),
  });

  @override
  BiocentralWorkspaceColors copyWith({Color? success, Color? warning, Color? muted}) => BiocentralWorkspaceColors(
    success: success ?? this.success,
    warning: warning ?? this.warning,
    muted: muted ?? this.muted,
  );

  @override
  BiocentralWorkspaceColors lerp(covariant BiocentralWorkspaceColors? other, double t) => other == null
      ? this
      : BiocentralWorkspaceColors(
          success: Color.lerp(success, other.success, t)!,
          warning: Color.lerp(warning, other.warning, t)!,
          muted: Color.lerp(muted, other.muted, t)!,
        );
}

/// Applies the new workspace appearance to [child] and its modal routes.
///
/// Scope this widget around an adopting plugin. Existing plugins keep their theme.
class BiocentralWorkspaceTheme extends StatelessWidget {
  final Widget child;

  const BiocentralWorkspaceTheme({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF0E7490);
    const border = Color(0xFFE4E7E2);
    final scheme = ColorScheme.fromSeed(seedColor: accent).copyWith(
      primary: accent,
      surface: Colors.white,
      onSurface: const Color(0xFF171A1C),
      onSurfaceVariant: const Color(0xFF5B6460),
      outlineVariant: border,
      error: const Color(0xFFB91C1C),
    );
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF6F7F5),
      extensions: const [BiocentralWorkspaceColors()],
      dividerColor: border,
      inputDecorationTheme: const InputDecorationTheme(isDense: true, border: OutlineInputBorder()),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 13),
        bodySmall: TextStyle(fontSize: 12),
      ),
    );
    return Theme(data: theme, child: child);
  }
}
