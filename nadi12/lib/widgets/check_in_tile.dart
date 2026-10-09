import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/check_in_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CheckInTile extends StatelessWidget {
  final CheckInModel checkIn;

  const CheckInTile({
    super.key,
    required this.checkIn,
  });

  @override
  Widget build(BuildContext context) {
    final isQr = checkIn.method.toLowerCase() == 'qr';
    final dateStr = DateFormat('EEE, MMM d, yyyy').format(checkIn.checkedInAt);
    final timeStr = DateFormat('hh:mm a').format(checkIn.checkedInAt);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isQr
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isQr
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.border,
              ),
            ),
            child: Icon(
              isQr ? Icons.qr_code_scanner_rounded : Icons.dialpad_rounded,
              color: isQr ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Check-in info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: AppTextStyles.titleLarge.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Method Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isQr ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isQr ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isQr ? Icons.qr_code_2_rounded : Icons.pin_rounded,
                  size: 13,
                  color: isQr ? AppColors.primaryLight : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  isQr ? 'QR Scan' : 'Front Desk Code',
                  style: AppTextStyles.badge.copyWith(
                    fontSize: 11,
                    color: isQr ? AppColors.primaryLight : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
