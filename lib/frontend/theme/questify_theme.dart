import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestifyTheme {
  const QuestifyTheme._();

  static const Color obsidian = Color(0xFF0F0E17);
  static const Color midnight = Color(0xFF161320);
  static const Color panel = Color(0xFF1D1A2B);
  static const Color panelRaised = Color(0xFF252235);
  static const Color panelStrong = Color(0xFF2E2942);
  static const Color border = Color(0xFF36324D);
  static const Color violet = Color(0xFF6C63FF);
  static const Color violetGlow = Color(0xFF8B85FF);
  static const Color lilac = Color(0xFFC5C0FF);
  static const Color gold = Color(0xFFFFD54A);
  static const Color cyan = Color(0xFF2DE2E6);
  static const Color emerald = Color(0xFF34D399);
  static const Color coral = Color(0xFFFF7A90);

  static const Color dawn = Color(0xFFF7F5FF);
  static const Color dawnPanel = Color(0xFFFFFFFF);
  static const Color dawnBorder = Color(0xFFD8D2F4);
  static const Color dawnInk = Color(0xFF221B43);
  static const Color dawnMuted = Color(0xFF6A6485);

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: violet,
    onPrimary: Colors.white,
    secondary: gold,
    onSecondary: Color(0xFF382B00),
    error: coral,
    onError: Colors.white,
    surface: dawn,
    onSurface: dawnInk,
    primaryContainer: Color(0xFFE8E5FF),
    onPrimaryContainer: Color(0xFF2D215F),
    secondaryContainer: Color(0xFFFFF1BF),
    onSecondaryContainer: Color(0xFF493500),
    tertiary: emerald,
    onTertiary: Color(0xFF03251A),
    tertiaryContainer: Color(0xFFD8F7EA),
    onTertiaryContainer: Color(0xFF0A3B2A),
    outline: dawnBorder,
    surfaceContainerHighest: Color(0xFFF0ECFF),
    onSurfaceVariant: dawnMuted,
    inverseSurface: midnight,
    onInverseSurface: Color(0xFFF7F5FF),
    inversePrimary: lilac,
    shadow: Color(0x1A1C1438),
    scrim: Color(0x33000000),
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: violet,
    onPrimary: Colors.white,
    secondary: gold,
    onSecondary: Color(0xFF382B00),
    error: coral,
    onError: Colors.white,
    surface: obsidian,
    onSurface: Color(0xFFF7F5FF),
    primaryContainer: Color(0xFF241D52),
    onPrimaryContainer: lilac,
    secondaryContainer: Color(0xFF403408),
    onSecondaryContainer: Color(0xFFFFF0B3),
    tertiary: emerald,
    onTertiary: Color(0xFF06291D),
    tertiaryContainer: Color(0xFF0F3C2E),
    onTertiaryContainer: Color(0xFFD7FBEA),
    outline: border,
    surfaceContainerHighest: panelRaised,
    onSurfaceVariant: Color(0xFFB4ADD6),
    inverseSurface: dawn,
    onInverseSurface: dawnInk,
    inversePrimary: violetGlow,
    shadow: Color(0x66000000),
    scrim: Color(0x66000000),
  );

  static ThemeData get lightTheme => _buildTheme(_lightScheme);
  static ThemeData get darkTheme => _buildTheme(_darkScheme);

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      brightness: colorScheme.brightness,
    );

    final textTheme = GoogleFonts.lexendTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        height: 0.96,
        color: colorScheme.onSurface,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.02,
        color: colorScheme.onSurface,
      ),
      displaySmall: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.04,
        color: colorScheme.onSurface,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      bodyLarge: GoogleFonts.lexend(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: colorScheme.onSurface,
      ),
      bodyMedium: GoogleFonts.lexend(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: colorScheme.onSurface,
      ),
      bodySmall: GoogleFonts.lexend(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: colorScheme.onSurface,
      ),
      labelMedium: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: colorScheme.onSurfaceVariant,
      ),
    );

    final cardColor = isDark ? panel : dawnPanel;
    final raisedColor = isDark ? panelRaised : Colors.white;
    final inputColor = isDark ? panelRaised : Colors.white;

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? panelStrong : dawnInk,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? colorScheme.onSurface : Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: colorScheme.outline, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: colorScheme.outline, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: colorScheme.outline, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: colorScheme.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: colorScheme.error, width: 1.8),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: raisedColor,
        selectedColor: colorScheme.primaryContainer,
        disabledColor: raisedColor,
        side: BorderSide(color: colorScheme.outline, width: 1.1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        labelStyle: textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(color: colorScheme.outline, width: 1.4),
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: colorScheme.primary, width: 1.2),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: colorScheme.outline, width: 1.2),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: violetGlow.withValues(alpha: 0.7), width: 1),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return colorScheme.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: colorScheme.outline, width: 1.2),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: colorScheme.outline,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colorScheme.primary, width: 3),
          borderRadius: BorderRadius.circular(999),
        ),
        indicatorSize: TabBarIndicatorSize.label,
      ),
      listTileTheme: ListTileThemeData(
        textColor: colorScheme.onSurface,
        iconColor: colorScheme.onSurfaceVariant,
        tileColor: raisedColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }
}
