import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ViewStatus { initial, loading, success, empty, error }

class StateViewHandler extends StatelessWidget {
  final ViewStatus status;
  final Widget Function() onSuccess;
  final Widget Function()? onLoading;
  final Widget Function()? onEmpty;
  final Widget Function(String message)? onError;
  final String? errorMessage;
  final String? emptyTitle;
  final String? emptyMessage;
  final String? emptyIllustrationPath;
  final VoidCallback? onRetry;
  final String retryButtonText;

  const StateViewHandler({
    super.key,
    required this.status,
    required this.onSuccess,
    this.onLoading,
    this.onEmpty,
    this.onError,
    this.errorMessage,
    this.emptyTitle,
    this.emptyMessage,
    this.emptyIllustrationPath,
    this.onRetry,
    this.retryButtonText = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ViewStatus.loading:
      case ViewStatus.initial:
        return onLoading != null ? onLoading!() : _defaultLoadingView();

      case ViewStatus.empty:
        return onEmpty != null ? onEmpty!() : _defaultEmptyView(context);

      case ViewStatus.error:
        return onError != null
            ? onError!(errorMessage ?? 'An unexpected error occurred.')
            : _defaultErrorView(context);

      case ViewStatus.success:
        return onSuccess();
    }
  }

  Widget _defaultLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _defaultEmptyView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emptyIllustrationPath != null)
              SvgPicture.asset(
                emptyIllustrationPath!,
                width: 140,
                height: 140,
              )
            else
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.inbox_outlined,
                  size: 40,
                  color: AppColors.textMuted,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              emptyTitle ?? 'No Items Found',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              emptyMessage ?? 'There is currently no data to display.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(retryButtonText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _defaultErrorView(BuildContext context) {
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
                color: AppColors.errorBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something Went Wrong',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage ?? 'Unable to connect to the server. Please check your connection and try again.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(retryButtonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
