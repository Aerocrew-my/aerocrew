import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AeroPalette {
  static const primary = Color(0xFF2563EB);
  static const deepBlue = Color(0xFF1E3A8A);
  static const skyBlue = Color(0xFF0EA5E9);
  static const lightCanvas = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSecondarySurface = Color(0xFFEEF2F7);
  static const lightBlueSurface = Color(0xFFF0F6FF);
  static const darkCanvas = Color(0xFF08111F);
  static const darkSurface = Color(0xFF101C2D);
  static const darkElevatedSurface = Color(0xFF17263A);
  static const darkSecondarySurface = Color(0xFF21324A);
  static const lightTextPrimary = Color(0xFF101828);
  static const lightTextSecondary = Color(0xFF667085);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFFA8B3C5);
  static const lightBorder = Color(0xFFE2E8F0);
  static const darkBorder = Color(0xFF2B3E57);
  static const success = Color(0xFF109B81);
  static const warning = Color(0xFFE5A12A);
  static const danger = Color(0xFFE5484D);
  static const information = Color(0xFF0EA5E9);
}

abstract final class AeroSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const screen = 20.0;
  static const section = 24.0;
  static const lg = 32.0;
}

abstract final class AeroRadius {
  static const card = 16.0;
  static const button = 14.0;
  static const input = 12.0;
  static const chip = 999.0;
}

abstract final class AeroSizes {
  static const touchTarget = 48.0;
  static const icon = 22.0;
  static const smallIcon = 18.0;
}

abstract final class AeroMotion {
  static const quick = Duration(milliseconds: 160);
  static const standard = Duration(milliseconds: 240);
}

@immutable
class AeroSemanticColors extends ThemeExtension<AeroSemanticColors> {
  const AeroSemanticColors({
    required this.canvas,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceSecondary,
    required this.blueSurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.success,
    required this.warning,
    required this.danger,
    required this.information,
  });

  final Color canvas;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceSecondary;
  final Color blueSurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color success;
  final Color warning;
  final Color danger;
  final Color information;

  @override
  AeroSemanticColors copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceSecondary,
    Color? blueSurface,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? success,
    Color? warning,
    Color? danger,
    Color? information,
  }) {
    return AeroSemanticColors(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      blueSurface: blueSurface ?? this.blueSurface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      information: information ?? this.information,
    );
  }

  @override
  AeroSemanticColors lerp(covariant AeroSemanticColors? other, double t) {
    if (other == null) return this;
    return AeroSemanticColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceSecondary: Color.lerp(
        surfaceSecondary,
        other.surfaceSecondary,
        t,
      )!,
      blueSurface: Color.lerp(blueSurface, other.blueSurface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      information: Color.lerp(information, other.information, t)!,
    );
  }
}

extension AeroThemeContext on BuildContext {
  AeroSemanticColors get aero =>
      Theme.of(this).extension<AeroSemanticColors>()!;
}

abstract final class AeroTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final semantic = AeroSemanticColors(
      canvas: dark ? AeroPalette.darkCanvas : AeroPalette.lightCanvas,
      surface: dark ? AeroPalette.darkSurface : AeroPalette.lightSurface,
      surfaceElevated: dark
          ? AeroPalette.darkElevatedSurface
          : AeroPalette.lightSurface,
      surfaceSecondary: dark
          ? AeroPalette.darkSecondarySurface
          : AeroPalette.lightSecondarySurface,
      blueSurface: dark
          ? AeroPalette.primary.withValues(alpha: 0.16)
          : AeroPalette.lightBlueSurface,
      textPrimary: dark
          ? AeroPalette.darkTextPrimary
          : AeroPalette.lightTextPrimary,
      textSecondary: dark
          ? AeroPalette.darkTextSecondary
          : AeroPalette.lightTextSecondary,
      border: dark ? AeroPalette.darkBorder : AeroPalette.lightBorder,
      success: AeroPalette.success,
      warning: AeroPalette.warning,
      danger: AeroPalette.danger,
      information: AeroPalette.information,
    );
    final scheme = ColorScheme(
      brightness: brightness,
      primary: AeroPalette.primary,
      onPrimary: Colors.white,
      primaryContainer: semantic.blueSurface,
      onPrimaryContainer: dark ? const Color(0xFFD9E7FF) : AeroPalette.deepBlue,
      secondary: AeroPalette.skyBlue,
      onSecondary: Colors.white,
      secondaryContainer: semantic.blueSurface,
      onSecondaryContainer: semantic.textPrimary,
      tertiary: AeroPalette.success,
      onTertiary: Colors.white,
      error: AeroPalette.danger,
      onError: Colors.white,
      surface: semantic.surface,
      onSurface: semantic.textPrimary,
      outline: semantic.border,
      outlineVariant: semantic.border,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: dark ? AeroPalette.lightSurface : AeroPalette.darkSurface,
      onInverseSurface: dark
          ? AeroPalette.lightTextPrimary
          : AeroPalette.darkTextPrimary,
      inversePrimary: const Color(0xFF8EB4FF),
    );
    final baseText = Typography.material2021().black.apply(
      bodyColor: semantic.textPrimary,
      displayColor: semantic.textPrimary,
      fontFamily: 'Inter',
      fontFamilyFallback: const ['Roboto', 'Arial', 'sans-serif'],
    );
    final textTheme = baseText.copyWith(
      displaySmall: baseText.displaySmall?.copyWith(
        fontSize: 32,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      headlineSmall: baseText.headlineSmall?.copyWith(
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseText.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
      bodyMedium: baseText.bodyMedium?.copyWith(fontSize: 14, height: 1.45),
      bodySmall: baseText.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.4,
        color: semantic.textSecondary,
      ),
      labelLarge: baseText.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: baseText.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: semantic.textSecondary,
      ),
    );

    final overlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: semantic.surface,
      systemNavigationBarIconBrightness: dark
          ? Brightness.light
          : Brightness.dark,
      systemNavigationBarDividerColor: semantic.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: semantic.canvas,
      canvasColor: semantic.canvas,
      fontFamily: 'Inter',
      fontFamilyFallback: const ['Roboto', 'Arial', 'sans-serif'],
      textTheme: textTheme,
      extensions: [semantic],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: semantic.canvas,
        foregroundColor: semantic.textPrimary,
        centerTitle: false,
        systemOverlayStyle: overlay,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: semantic.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AeroRadius.card),
          side: BorderSide(color: semantic.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: semantic.surface,
        indicatorColor: semantic.blueSurface,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: AeroSizes.icon,
            color: states.contains(WidgetState.selected)
                ? AeroPalette.primary
                : semantic.textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AeroPalette.primary
                : semantic.textSecondary,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: semantic.surface,
        indicatorColor: semantic.blueSurface,
        selectedIconTheme: const IconThemeData(color: AeroPalette.primary),
        unselectedIconTheme: IconThemeData(color: semantic.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(AeroSizes.touchTarget, AeroSizes.touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          backgroundColor: AeroPalette.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: semantic.surfaceSecondary,
          disabledForegroundColor: semantic.textSecondary,
          elevation: 0,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AeroRadius.button),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(AeroSizes.touchTarget, AeroSizes.touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          foregroundColor: AeroPalette.primary,
          side: BorderSide(color: semantic.border),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AeroRadius.button),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AeroSizes.touchTarget, AeroSizes.touchTarget),
          foregroundColor: AeroPalette.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: semantic.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: _inputBorder(semantic.border),
        enabledBorder: _inputBorder(semantic.border),
        focusedBorder: _inputBorder(AeroPalette.primary, width: 1.5),
        errorBorder: _inputBorder(AeroPalette.danger),
        labelStyle: TextStyle(color: semantic.textSecondary),
        hintStyle: TextStyle(color: semantic.textSecondary),
      ),
      dividerTheme: DividerThemeData(color: semantic.border, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: semantic.surfaceSecondary,
        selectedColor: semantic.blueSurface,
        side: BorderSide(color: semantic.border),
        shape: const StadiumBorder(),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: semantic.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AeroRadius.card),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: semantic.surfaceElevated,
        modalBackgroundColor: semantic.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark
            ? AeroPalette.darkSecondarySurface
            : AeroPalette.lightTextPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AeroPalette.primary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : semantic.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AeroPalette.primary
              : semantic.surfaceSecondary,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: semantic.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AeroPalette.primary,
        headerForegroundColor: Colors.white,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AeroRadius.input),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
