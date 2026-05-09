import 'package:flutter/material.dart';

/// Centralized design tokens for Loopz.
/// Use these instead of hardcoded colors / radii / shadows.
class AppColors {
  // Background hierarchy
  static const Color background = Color(0xFF08080F);
  static const Color surface = Color(0xFF14141F);
  static const Color surfaceElevated = Color(0xFF1E1E2E);
  static const Color surfaceMuted = Color(0xFF252538);

  // Brand
  static const Color primary = Color(0xFFFF2E63);
  static const Color primaryDeep = Color(0xFFE0145A);
  static const Color secondary = Color(0xFF7B2CBF);
  static const Color tertiary = Color(0xFF00DFD8);

  // Status
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFB300);
  static const Color danger = Color(0xFFEF476F);

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textMuted = Color(0xCCFFFFFF);
  static const Color textDim = Color(0x80FFFFFF);
  static const Color textFaint = Color(0x4DFFFFFF);

  // Strokes
  static const Color border = Color(0x14FFFFFF);
  static const Color borderStrong = Color(0x29FFFFFF);
}

class AppGradients {
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF0080), Color(0xFF7928CA), Color(0xFF00DFD8)],
  );

  static const LinearGradient pinkPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF2E63), Color(0xFF7B2CBF)],
  );

  static const LinearGradient subtleSurface = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E1E2E), Color(0xFF14141F)],
  );

  static const RadialGradient backgroundGlow = RadialGradient(
    center: Alignment(0.0, -0.6),
    radius: 1.2,
    colors: [Color(0x33FF2E63), Color(0xFF08080F)],
  );
}

class AppRadii {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

class AppShadows {
  static List<BoxShadow> get pinkGlow => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.35),
          blurRadius: 24,
          spreadRadius: -2,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}

ThemeData buildAppTheme() {
  const baseTextTheme = TextTheme(
    displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.5),
    headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: AppColors.textPrimary),
    bodyMedium: TextStyle(color: AppColors.textMuted),
    bodySmall: TextStyle(color: AppColors.textDim),
    labelLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
  );

  return ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.surface,
    splashColor: AppColors.primary.withOpacity(0.15),
    highlightColor: AppColors.primary.withOpacity(0.08),
    textTheme: baseTextTheme,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      tertiary: AppColors.tertiary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      hintStyle: const TextStyle(color: AppColors.textDim),
      labelStyle: const TextStyle(color: AppColors.textMuted),
      prefixIconColor: AppColors.textDim,
      suffixIconColor: AppColors.textDim,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceElevated,
      contentTextStyle: const TextStyle(color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),
    dividerColor: AppColors.border,
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceElevated,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

/// Filled gradient button — primary CTA across the app.
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;
  final Gradient gradient;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.height = 54,
    this.gradient = AppGradients.pinkPurple,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    return AnimatedOpacity(
      opacity: disabled ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadii.md),
          boxShadow: disabled ? null : AppShadows.pinkGlow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.md),
            onTap: disabled ? null : onPressed,
            child: Center(
              child: loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glassy card surface with a subtle border.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppRadii.lg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return inner;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: inner,
      ),
    );
  }
}

/// Brand mark — gradient circle with play icon. Used in splash, login, etc.
class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.brand,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(Icons.play_arrow_rounded, size: size * 0.55, color: Colors.white),
    );
  }
}
