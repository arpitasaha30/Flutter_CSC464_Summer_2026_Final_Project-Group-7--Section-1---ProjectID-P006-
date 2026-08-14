import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AvatarUtils {
  /// Picks a consistent gradient for a given name so the same person
  /// always gets the same colored avatar across the app.
  static List<Color> gradientFor(String seed) {
    if (seed.isEmpty) return AppColors.avatarGradients.first;
    final sum = seed.codeUnits.fold<int>(0, (a, b) => a + b);
    return AppColors.avatarGradients[sum % AppColors.avatarGradients.length];
  }

  static String initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

/// A circular avatar with a colored gradient background and the person's
/// initials, used everywhere a profile picture would normally go.
class GradientAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final double fontSize;

  const GradientAvatar({
    super.key,
    required this.name,
    this.radius = 24,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AvatarUtils.gradientFor(name);
    return Container(
      width: radius * 2,
      height: radius * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        AvatarUtils.initials(name),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
