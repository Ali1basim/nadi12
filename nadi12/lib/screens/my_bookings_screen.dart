import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking_model.dart';
import '../state/booking_provider.dart';
import '../state/schedule_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/booking_card.dart';
import '../widgets/state_view_handler.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  int _selectedTab = 0; // 0 = Upcoming, 1 = Past

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchMyBookings();
    });
  }

  Future<void> _handleCancelBooking(BookingModel booking) async {
    final bookingProvider = context.read<BookingProvider>();
    final scheduleProvider = context.read<ScheduleProvider>();

    final result = await bookingProvider.cancelBooking(booking);

    if (!mounted) return;

    if (result.success) {
      if (result.classId != null) {
        scheduleProvider.restoreSlotForClass(result.classId!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => bookingProvider.fetchMyBookings(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Figma Tabs (Upcoming / Past)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Upcoming',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.button.copyWith(
                              fontSize: 14,
                              color: _selectedTab == 0 ? Colors.white : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Past',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.button.copyWith(
                              fontSize: 14,
                              color: _selectedTab == 1 ? Colors.white : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Content list with 4 states
            Expanded(
              child: _selectedTab == 1
                  ? _buildPastTabEmpty()
                  : StateViewHandler(
                      status: bookingProvider.status,
                      errorMessage: bookingProvider.errorMessage,
                      emptyTitle: 'No Upcoming Bookings',
                      emptyMessage: 'You haven’t reserved any gym sessions yet. Browse the class schedule to book your spot!',
                      emptyIllustrationPath: 'assets/illustrations/empty_bookings.svg',
                      onRetry: () => bookingProvider.fetchMyBookings(),
                      onSuccess: () => ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: bookingProvider.bookings.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final booking = bookingProvider.bookings[index];
                          return BookingCard(
                            booking: booking,
                            isCancelling: bookingProvider.isCancelling(booking.id),
                            onCancel: () => _handleCancelBooking(booking),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastTabEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 38,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text('No Past Bookings', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Your previous completed sessions will appear here.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
