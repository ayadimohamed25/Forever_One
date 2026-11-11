import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Shape and spacing scale.
class AppRadius {
  AppRadius._();
  static const double card = 12;
  static const double control = 10; // inputs and buttons
  static const double chip = 6;
}

class AppSpacing {
  AppSpacing._();
  static const double page = 16;
  static const double gap = 12;
}

class AppTheme {
  AppTheme._();

  /// Money and KPI figures use tabular numerals so columns line up.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  /// An Inter style. google_fonts loads one file per weight, so asking for
  /// the weight here gets the real face instead of a faked bold.
  static TextStyle font({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
    bool tabularFigures = false,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontFeatures: tabularFigures ? tabular : null,
    );
  }

  // ── Type scale: page title 20, section 15, body 14, caption 12 ──

  static TextStyle get pageTitle =>
      font(size: 20, weight: FontWeight.w600, letterSpacing: -0.2, height: 1.2);

  /// Kept name: the dashboard greeting is now a page-title-sized line.
  static TextStyle get greeting => pageTitle;

  /// Large KPI figure on a card.
  static TextStyle get kpi => font(
      size: 22,
      weight: FontWeight.w600,
      letterSpacing: -0.3,
      height: 1.15,
      tabularFigures: true);

  static TextStyle get sectionTitle =>
      font(size: 15, weight: FontWeight.w600, height: 1.3);

  /// Caption / secondary line.
  static TextStyle get label =>
      font(size: 12, color: AppColors.textSecondary, height: 1.35);

  static TextStyle get caption => label;

  /// Field label, above the field.
  static TextStyle get fieldLabel =>
      font(size: 13, weight: FontWeight.w500, color: AppColors.textLabel);

  static TextStyle get body => font(size: 14, height: 1.45);

  static TextStyle get rowTitle =>
      font(size: 14, weight: FontWeight.w500, height: 1.3);

  static TextStyle get money =>
      font(size: 14, weight: FontWeight.w600, tabularFigures: true);

  static OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: BorderSide(color: color, width: width),
      );

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.primary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.fieldBorder,
      outlineVariant: AppColors.border,
      error: AppColors.danger,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.control),
    );
    final buttonText = font(size: 14, weight: FontWeight.w600);

    final textTheme = TextTheme(
      displaySmall: font(size: 28, weight: FontWeight.w600),
      headlineLarge: kpi,
      headlineMedium: pageTitle,
      headlineSmall: font(size: 18, weight: FontWeight.w600),
      titleLarge: pageTitle,
      titleMedium: rowTitle,
      titleSmall: font(size: 13, weight: FontWeight.w600),
      bodyLarge: body,
      bodyMedium: font(size: 14),
      bodySmall: label,
      labelLarge: buttonText,
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
      // Keyboard focus is drawn by AppPressable / AppIconButton as a 2px
      // ring; a theme focus fill on top would double it.
      focusColor: Colors.transparent,
      hoverColor: AppColors.surfaceAlt,
      dividerColor: AppColors.border,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: pageTitle,
        iconTheme: const IconThemeData(color: AppColors.icon, size: 22),
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      iconTheme: const IconThemeData(color: AppColors.icon, size: 22),

      // Primary: filled blue, white text, 48 high. Disabled is clearly
      // disabled: light grey with grey text.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textMuted,
          minimumSize: const Size(88, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          elevation: 0,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textMuted,
          minimumSize: const Size(88, 48),
          elevation: 0,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),

      // Secondary: white with a border.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textLabel,
          backgroundColor: AppColors.surface,
          disabledForegroundColor: AppColors.textMuted,
          minimumSize: const Size(88, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          side: const BorderSide(color: AppColors.fieldBorder),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(48, 44),
          shape: buttonShape,
          textStyle: font(size: 14, weight: FontWeight.w600),
        ),
      ),

      // Fields: white, 1px grey border, 48 high, primary border on focus,
      // red border + message on error. Labels sit ABOVE the field (see
      // AppTextField / AppLabeledField), never floating on the border.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        constraints: const BoxConstraints(minHeight: 48),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: _border(AppColors.fieldBorder),
        enabledBorder: _border(AppColors.fieldBorder),
        disabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.primary, 2),
        errorBorder: _border(AppColors.danger),
        focusedErrorBorder: _border(AppColors.danger, 2),
        labelStyle: font(size: 14, color: AppColors.textSecondary),
        hintStyle: font(size: 14, color: AppColors.textMuted),
        errorStyle: font(size: 12, color: AppColors.dangerText),
        prefixIconColor: AppColors.iconMuted,
        suffixIconColor: AppColors.iconMuted,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 3,
        highlightElevation: 2,
        extendedTextStyle: buttonText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primarySoft,
        disabledColor: AppColors.fill,
        side: const BorderSide(color: AppColors.fieldBorder),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        labelStyle: font(size: 13, weight: FontWeight.w500, color: AppColors.textLabel),
        secondaryLabelStyle:
            font(size: 13, weight: FontWeight.w600, color: AppColors.primary),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        titleTextStyle: font(size: 18, weight: FontWeight.w600),
        contentTextStyle:
            font(size: 14, height: 1.45, color: AppColors.textSecondary),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.black,
        contentTextStyle:
            font(size: 14, weight: FontWeight.w500, color: Colors.white),
        behavior: SnackBarBehavior.floating,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
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
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          side: const BorderSide(color: AppColors.border),
        ),
        textStyle: font(size: 14),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        textStyle: font(size: 12, color: Colors.white),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.track,
        circularTrackColor: AppColors.track,
        linearMinHeight: 6,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.fieldBorder),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: AppColors.fieldBorder, width: 1.5),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.border,
        labelStyle: font(size: 14, weight: FontWeight.w600),
        unselectedLabelStyle: font(size: 14, weight: FontWeight.w500),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: AppColors.primarySoft,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => font(
              size: 11,
              weight: s.contains(WidgetState.selected)
                  ? FontWeight.w600
                  : FontWeight.w500,
              color: s.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.textSecondary,
            )),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              size: 22,
              color: s.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.iconMuted,
            )),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.icon,
        textColor: AppColors.textPrimary,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
