import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NadiLogo extends StatelessWidget {
  final double scale;
  final bool showText;
  final Color? color;

  const NadiLogo({
    super.key,
    this.scale = 1.0,
    this.showText = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPlates(isLeft: true),
        const SizedBox(width: 8),
        if (showText)
          Text(
            'NADI',
            style: AppTextStyles.logoText.copyWith(
              fontSize: 24 * scale,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        const SizedBox(width: 8),
        _buildPlates(isLeft: false),
      ],
    );
  }

  Widget _buildPlates({required bool isLeft}) {
    final plate1 = Container(
      width: 4 * scale,
      height: 16 * scale,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(2),
      ),
    );
    final plate2 = Container(
      width: 5 * scale,
      height: 24 * scale,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(3),
      ),
    );
    final plate3 = Container(
      width: 4 * scale,
      height: 18 * scale,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(2),
      ),
    );

    final plates = isLeft ? [plate1, plate2, plate3] : [plate3, plate2, plate1];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < plates.length; i++) ...[
          plates[i],
          if (i < plates.length - 1) SizedBox(width: 2.5 * scale),
        ],
      ],
    );
  }
}
