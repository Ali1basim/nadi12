import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/attendance_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/check_in_tile.dart';
import '../widgets/state_view_handler.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().fetchCheckIns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => attendanceProvider.fetchCheckIns(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Metrics Banner matching Figma layout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TOTAL VISITS', style: AppTextStyles.caption),
                          const SizedBox(height: 4),
                          Text(
                            '${attendanceProvider.totalCheckIns}',
                            style: AppTextStyles.h1.copyWith(
                              fontSize: 32,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 45,
                      color: AppColors.divider,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BY METHOD', style: AppTextStyles.caption),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.qr_code_2, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                '${attendanceProvider.qrCheckInsCount} QR',
                                style: AppTextStyles.badge.copyWith(color: AppColors.textPrimary),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.pin, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '${attendanceProvider.codeCheckInsCount} Code',
                                style: AppTextStyles.badge.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Recent Check-ins', style: AppTextStyles.titleLarge),
              ),
            ),
            const SizedBox(height: 12),

            // List of Check-ins with 4-state handler
            Expanded(
              child: StateViewHandler(
                status: attendanceProvider.status,
                errorMessage: attendanceProvider.errorMessage,
                emptyTitle: 'No Check-ins Yet',
                emptyMessage: 'You haven’t checked into the gym yet. Visit the front desk and scan your dynamic QR code to log your first session!',
                emptyIllustrationPath: 'assets/illustrations/empty_history.svg',
                onRetry: () => attendanceProvider.fetchCheckIns(),
                onSuccess: () => ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  itemCount: attendanceProvider.checkIns.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final checkIn = attendanceProvider.checkIns[index];
                    return CheckInTile(checkIn: checkIn);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
