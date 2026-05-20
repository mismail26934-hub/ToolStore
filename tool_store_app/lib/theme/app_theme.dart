import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tool_store_app/view/var/var.dart';

class AppTheme {
  AppTheme._();

  /// Header gradient shared by dashboard and list screens (Tool, User).
  static const LinearGradient dashboardHeaderGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 255, 146, 21),
      Color.fromARGB(255, 255, 184, 76),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const BorderRadius dashboardHeaderBottomRadius = BorderRadius.only(
    bottomLeft: Radius.circular(28),
    bottomRight: Radius.circular(28),
  );

  static const Color _lightScaffold = Color(0xFFF7F8FA);
  static const Color _darkScaffold = Color(0xFF0F1117);
  static const Color _darkSurface = Color(0xFF1A1D27);
  static const Color _darkBorder = Color(0xFF2D3344);

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scaffoldBg = isDark ? _darkScaffold : _lightScaffold;
    final surface = isDark ? _darkSurface : clrWhite;
    final onSurface = isDark ? const Color(0xFFF3F4F6) : clrBlack;
    final onSurfaceVariant = isDark
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF6B7280);
    final outline = isDark ? _darkBorder : const Color(0xFFE5E7EB);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: clrOrange,
      onPrimary: clrBlack,
      secondary: clrOrange,
      onSecondary: clrBlack,
      error: clrRed,
      onError: clrWhite,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: isDark
          ? const Color(0xFF252836)
          : const Color(0xFFF9FAFB),
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
    );

    final titleStyle = GoogleFonts.robotoFlex(
      fontWeight: FontWeight.bold,
      color: onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: clrOrange,
        foregroundColor: clrBlack,
        elevation: 0,
      ),
      drawerTheme: DrawerThemeData(backgroundColor: scaffoldBg),
      dialogTheme: DialogThemeData(backgroundColor: surface),
      cardTheme: CardThemeData(
        color: surface,
        elevation: isDark ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: outline),
        ),
      ),
      dividerColor: outline,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF252836) : Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: clrOrange, width: 1.4),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return clrOrange;
          return isDark ? Colors.grey.shade400 : Colors.grey.shade300;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return clrOrange.withValues(alpha: 0.45);
          }
          return isDark ? const Color(0xFF374151) : Colors.grey.shade300;
        }),
      ),
      textTheme: TextTheme(
        titleLarge: titleStyle.copyWith(fontSize: 18),
        titleMedium: titleStyle.copyWith(fontSize: 16),
        titleSmall: titleStyle.copyWith(fontSize: 14),
        bodyLarge: GoogleFonts.robotoFlex(color: onSurface),
        bodyMedium: GoogleFonts.robotoFlex(color: onSurface),
        bodySmall: GoogleFonts.robotoFlex(color: onSurfaceVariant),
        labelLarge: GoogleFonts.robotoFlex(
          color: onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

extension ToolStoreTheme on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get pageBackground => Theme.of(this).scaffoldBackgroundColor;

  Color get cardSurface => Theme.of(this).colorScheme.surface;

  Color get cardBorder => Theme.of(this).dividerColor;

  Color get textPrimary => Theme.of(this).colorScheme.onSurface;

  Color get textSecondary => Theme.of(this).colorScheme.onSurfaceVariant;

  Color get cardGradientStart => Theme.of(this).colorScheme.surface;

  Color get cardGradientEnd =>
      Theme.of(this).colorScheme.surfaceContainerHighest;

  Color get mutedSurface => Theme.of(this).colorScheme.surfaceContainerHighest;

  Color get inputFill =>
      Theme.of(this).inputDecorationTheme.fillColor ?? cardSurface;

  Color get chipNeutralBg => isDarkMode
      ? const Color(0xFF2D3344)
      : Colors.grey.shade100;

  Color get chipNeutralFg =>
      isDarkMode ? const Color(0xFFD1D5DB) : Colors.grey.shade700;

  Color get iconMuted =>
      isDarkMode ? const Color(0xFF9CA3AF) : Colors.grey.shade500;

  Color get bodyMuted =>
      isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF1F2937);

  Color get inactiveTitle =>
      isDarkMode ? const Color(0xFFE5E7EB) : const Color(0xFF111827);

  Color get connectorMuted =>
      isDarkMode ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB);

  Color get searchAccentFill => clrOrange.withValues(
        alpha: isDarkMode ? 0.18 : 0.08,
      );

  Color get searchAccentBorder => clrOrange.withValues(
        alpha: isDarkMode ? 0.35 : 0.25,
      );

  Color get cardShadow =>
      Colors.black.withValues(alpha: isDarkMode ? 0.28 : 0.05);

  Color get appBarSurface => cardSurface;

  /// Nested detail rows (PO, SO/PR, dates) inside tool form sections.
  Color get detailSubCardBg => cardSurface;

  Color get detailSubCardBorder => cardBorder;

  Color get detailSubCardIconBg => searchAccentFill;
}
