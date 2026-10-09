import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../state/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common_button.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isActive = user?.isSubscriptionActive ?? true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Member Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 44,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(user?.name ?? 'Rana Samir', style: AppTextStyles.h2),
                    const SizedBox(height: 4),
                    Text(user?.email ?? 'rana.samir@example.com', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 12),
                    // Member ID badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'MEMBER ID: ${user?.memberId ?? "NADI-84920"}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Membership Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Plan', style: AppTextStyles.caption),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.successBg : AppColors.errorBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.success.withValues(alpha: 0.3)
                                  : AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            isActive ? 'ACTIVE MEMBERSHIP' : 'EXPIRED',
                            style: AppTextStyles.badge.copyWith(
                              fontSize: 11,
                              color: isActive ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(user?.planName ?? 'All Access Pass', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      'Valid until: ${DateFormat('MMMM d, yyyy').format(user?.subscriptionExpiry ?? DateTime.now().add(const Duration(days: 30)))}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Business Rules & QA Testing Panel
              Text(
                'SYSTEM & RULE TESTING CONTROLS',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 10),

              // Rule 1 toggle
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: SwitchListTile(
                  title: const Text('Rule 1: Active Subscription'),
                  subtitle: Text(
                    isActive
                        ? 'Active — Booking and QR check-in permitted'
                        : 'Expired — Bookings and QR check-in blocked by backend',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isActive ? AppColors.success : AppColors.error,
                    ),
                  ),
                  value: isActive,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    authProvider.toggleSubscriptionStatus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          val
                              ? 'Subscription marked ACTIVE'
                              : 'Subscription marked EXPIRED (Rule 1 test mode)',
                        ),
                        backgroundColor: val ? AppColors.success : AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Test Global 401 Interceptor
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  leading: const Icon(Icons.security_update_warning_rounded, color: AppColors.warning),
                  title: const Text('Test Global 401 Interceptor'),
                  subtitle: Text(
                    'Simulates 401 Unauthorized response to verify auto-logout and redirect.',
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: OutlinedButton(
                    onPressed: () {
                      authProvider.triggerSimulated401();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Next API call will return 401 to test interceptor.'),
                          backgroundColor: AppColors.warning,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      side: const BorderSide(color: AppColors.warning),
                    ),
                    child: const Text('Arm 401', style: TextStyle(color: AppColors.warning)),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Logout Button
              CommonButton(
                label: 'Log Out',
                icon: Icons.logout_rounded,
                isDestructive: true,
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
