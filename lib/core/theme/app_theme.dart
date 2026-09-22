import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// Money and KPI figures use tabular numerals so columns line up.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  /// A Plus Jakarta Sans style. google_fonts loads one file per weight, so
  /// asking for the weight here gets the real face instead of a faked bold.
  static TextStyle font({
    double size = 15,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
    bool tabularFigures = false,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontFeatures: tabularFigures ? tabular : null,
    );
  }

  static TextStyle get greeting => font(
      size: 28, weight: FontWeight.w600, letterSpacing: -0.6, height: 1.15);

  static TextStyle get kpi => font(
      size: 36,
      weight: FontWeight.w700,
      letterSpacing: -1.2,
      height: 1.05,
      tabularFigures: true);

  static TextStyle get sectionTitle =>
      font(size: 20, weight: FontWeight.w600, letterSpacing: -0.4);

  static TextStyle get label =>
      font(size: 13, color: AppColors.textSecondary);

  static TextStyle get body => font(size: 15, height: 1.4);

  static TextStyle get rowTitle =>
      font(size: 15, weight: FontWeight.w500, height: 1.3);

  static TextStyle get money =>
      font(size: 15, weight: FontWeight.w600, tabularFigures: true);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.black,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      secondary: AppColors.accent,
    );

    final textTheme = TextTheme(
      displaySmall:
      font(size: 32, weight: FontWeight.w700, letterSpacing: -1),
      headlineLarge: kpi,
      headlineMedium: greeting,
      headlineSmall:
      font(size: 24, weight: FontWeight.w600, letterSpacing: -0.5),
      titleLarge: sectionTitle,
      titleMedium: rowTitle,
      titleSmall: font(size: 14, weight: FontWeight.w600),
      bodyLarge: body,
      bodyMedium: font(size: 15),
      bodySmall: label,
      labelLarge: font(size: 15, weight: FontWeight.w600),
      labelMedium: label,
      labelSmall: font(size: 12, color: AppColors.textSecondary),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.canvas,
      splashFactory: InkRipple.splashFactory,
      highlightColor: Colors.transparent,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle:
        font(size: 20, weight: FontWeight.w600, letterSpacing: -0.4),
        iconTheme: const IconThemeData(color: AppColors.icon, size: 22),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      iconTheme: const IconThemeData(color: AppColors.icon, size: 22),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textMuted,
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: font(
              size: 16, weight: FontWeight.w600, letterSpacing: -0.2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: font(size: 16, weight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surface,
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: font(size: 16, weight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          textStyle: font(size: 14, weight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fill,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.black, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        labelStyle: font(size: 14, color: AppColors.textSecondary),
        floatingLabelStyle: font(size: 13, color: AppColors.textSecondary),
        hintStyle: font(size: 15, color: AppColors.textMuted),
        prefixIconColor: AppColors.iconMuted,
        suffixIconColor: AppColors.iconMuted,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        extendedTextStyle: font(size: 15, weight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.fill,
        selectedColor: AppColors.accentSoft,
        disabledColor: AppColors.fill,
        side: BorderSide.none,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        labelStyle: font(size: 13, weight: FontWeight.w500),
        secondaryLabelStyle: font(
            size: 13, weight: FontWeight.w600, color: AppColors.accent),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle:
        font(size: 20, weight: FontWeight.w600, letterSpacing: -0.4),
        contentTextStyle:
        font(size: 15, height: 1.4, color: AppColors.textSecondary),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.black,
        contentTextStyle:
        font(size: 15, weight: FontWeight.w500, color: Colors.white),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: font(size: 15),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.black,
        linearTrackColor: AppColors.fill,
        circularTrackColor: AppColors.fill,
        linearMinHeight: 6,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected)
            ? AppColors.black
            : AppColors.border),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        dividerColor: Colors.transparent,
        labelStyle: font(size: 14, weight: FontWeight.w600),
        unselectedLabelStyle: font(size: 14),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.icon,
        textColor: AppColors.textPrimary,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}