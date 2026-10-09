import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/gym_class_model.dart';
import '../state/booking_provider.dart';
import '../state/schedule_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/class_card.dart';
import '../widgets/date_selector_strip.dart';
import '../widgets/state_view_handler.dart';

class ClassScheduleScreen extends StatefulWidget {
  const ClassScheduleScreen({super.key});

  @override
  State<ClassScheduleScreen> createState() => _ClassScheduleScreenState();
}

class _ClassScheduleScreenState extends State<ClassScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().fetchClasses();
    });
  }

  Future<void> _handleBookClass(GymClassModel gymClass) async {
    final scheduleProvider = context.read<ScheduleProvider>();
    final bookingProvider = context.read<BookingProvider>();

    final result = await scheduleProvider.bookClass(gymClass);

    if (!mounted) return;

    if (result.success) {
      if (result.booking != null) {
        bookingProvider.addBooking(result.booking!);
      }
      _showBookingSuccessDialog(context, gymClass);
    } else {
      _showBookingErrorDialog(context, result.message);
    }
  }

  void _showBookingSuccessDialog(BuildContext context, GymClassModel gymClass) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            SizedBox(width: 10),
            Text('Class Booked!'),
          ],
        ),
        content: Text(
          'Your spot for "${gymClass.name}" on ${DateFormat('EEE, MMM d').format(gymClass.startsAt)} at ${DateFormat('hh:mm a').format(gymClass.startsAt)} is confirmed.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('View in My Bookings'),
          ),
        ],
      ),
    );
  }

  void _showBookingErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.error_outline_rounded, color: AppColors.error, size: 28),
            SizedBox(width: 10),
            Text('Booking Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.surfaceElevated),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Class Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => scheduleProvider.fetchClasses(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Date Selector Strip
            DateSelectorStrip(
              selectedDate: scheduleProvider.selectedDate,
              onDateSelected: (date) => scheduleProvider.selectDate(date),
            ),
            const SizedBox(height: 16),

            // Date Headline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d').format(scheduleProvider.selectedDate),
                    style: AppTextStyles.titleLarge,
                  ),
                  Text(
                    '${scheduleProvider.classes.length} Classes',
                    style: AppTextStyles.caption.copyWith(color: AppColors.primaryLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Classes list handled through 4-state handler
            Expanded(
              child: StateViewHandler(
                status: scheduleProvider.status,
                errorMessage: scheduleProvider.errorMessage,
                emptyTitle: 'No Classes Scheduled',
                emptyMessage: 'There are no gym classes scheduled for this date. Please pick another day.',
                emptyIllustrationPath: 'assets/illustrations/empty_schedule.svg',
                onRetry: () => scheduleProvider.fetchClasses(),
                onSuccess: () => ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: scheduleProvider.classes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final gymClass = scheduleProvider.classes[index];
                    return ClassCard(
                      gymClass: gymClass,
                      isBooking: scheduleProvider.isBooking(gymClass.id),
                      onBook: () => _handleBookClass(gymClass),
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
}
