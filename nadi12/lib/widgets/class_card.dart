import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gym_class_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ClassCard extends StatelessWidget {
  final GymClassModel gymClass;
  final bool isBooking;
  final VoidCallback onBook;

  const ClassCard({
    super.key,
    required this.gymClass,
    required this.isBooking,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final startTimeStr = DateFormat('hh:mm a').format(gymClass.startsAt);
    final endTimeStr = DateFormat('hh:mm a').format(gymClass.endsAt);
    final isFull = gymClass.isFull;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class Icon / Graphic
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Class Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gymClass.name,
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 15,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$startTimeStr - $endTimeStr',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Capacity Badge
              _buildCapacityBadge(isFull),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 12),
          // Bottom row: slots info and Book button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 16,
                    color: isFull ? AppColors.error : AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isFull
                        ? 'Capacity full (${gymClass.capacity} max)'
                        : '${gymClass.freePlaces} of ${gymClass.capacity} spots left',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isFull ? AppColors.error : AppColors.textSecondary,
                      fontWeight: isFull ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
              // Book button
              SizedBox(
                height: 38,
                child: ElevatedButton(
                  onPressed: isFull || isBooking ? null : onBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.surfaceLight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isBooking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isFull ? 'Full' : 'Book',
                          style: AppTextStyles.badge.copyWith(
                            color: isFull ? AppColors.textDisabled : Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityBadge(bool isFull) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isFull ? AppColors.errorBg : AppColors.successBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFull
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFull ? AppColors.error : AppColors.success,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isFull ? 'Full' : 'Available',
            style: AppTextStyles.badge.copyWith(
              fontSize: 11,
              color: isFull ? AppColors.error : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
