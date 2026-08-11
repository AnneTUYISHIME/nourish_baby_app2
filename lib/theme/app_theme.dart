import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared "fun" visual language for the whole app: playful rounded font,
/// bright color palette, and small reusable building blocks so every
/// screen feels like part of the same friendly app.

class AppColors {
  static const pink = Color(0xFFFF6FA5);
  static const blue = Color(0xFF4DA6FF);
  static const purple = Color(0xFFA06BFF);
  static const orange = Color(0xFFFFA552);
  static const teal = Color(0xFF3DCBB1);
  static const yellow = Color(0xFFFFCB47);
  static const bg = Color(0xFFFFF3F8);

  static const palette = [pink, blue, purple, orange, teal, yellow];

  static Color forIndex(int i) => palette[i % palette.length];
}

ThemeData buildAppTheme() {
  final base = ThemeData(useMaterial3: true);
  final headingFont = GoogleFonts.baloo2TextTheme(base.textTheme);
  final bodyFont = GoogleFonts.nunitoTextTheme(base.textTheme);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    primaryColor: AppColors.pink,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.pink,
      secondary: AppColors.blue,
      tertiary: AppColors.purple,
    ),
    textTheme: bodyFont.copyWith(
      headlineLarge: headingFont.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: headingFont.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: headingFont.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: headingFont.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: headingFont.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: headingFont.titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.pink,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: headingFont.titleMedium?.copyWith(color: Colors.white),
        elevation: 2,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

/// A cheerful section title with an emoji/icon accent, used across screens.
class FunSectionTitle extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;

  const FunSectionTitle({
    super.key,
    required this.emoji,
    required this.title,
    this.color = AppColors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// A bright, rounded stat/feature card with a colored icon badge.
class FunCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const FunCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded colorful chip-pill, used for badges/labels.
class FunPill extends StatelessWidget {
  final String label;
  final Color color;
  const FunPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
