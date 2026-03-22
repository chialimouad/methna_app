import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lottie/lottie.dart';

class Helpers {
  Helpers._();

  /// Extract a user-friendly error message from any exception (especially Dio)
  static String extractErrorMessage(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'connection_timeout'.tr;
        case DioExceptionType.connectionError:
          return 'no_internet'.tr;
        case DioExceptionType.badResponse:
          final data = e.response?.data;
          if (data is Map && data['message'] != null) {
            final msg = data['message'];
            if (msg is List) return msg.join(', ');
            return msg.toString();
          }
          final status = e.response?.statusCode ?? 0;
          if (status == 401) return 'invalid_credentials'.tr;
          if (status == 403) return 'access_denied'.tr;
          if (status == 404) return 'not_found'.tr;
          if (status == 409) return data?['message']?.toString() ?? 'conflict_error'.tr;
          if (status == 429) return 'too_many_requests'.tr;
          if (status >= 500) return 'server_error'.tr;
          return 'something_went_wrong'.tr;
        case DioExceptionType.cancel:
          return 'request_cancelled'.tr;
        default:
          return 'no_internet'.tr;
      }
    }
    return 'something_went_wrong'.tr;
  }

  /// Format date to readable string
  static String formatDate(DateTime? date, {String pattern = 'MMM dd, yyyy'}) {
    if (date == null) return '';
    return intl.DateFormat(pattern).format(date);
  }

  /// Format time ago (e.g. "2h ago", "Just now")
  static String timeAgo(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'just_now'.tr;
    if (diff.inMinutes < 60) return 'minutes_ago'.trParams({'count': '${diff.inMinutes}'});
    if (diff.inHours < 24) return 'hours_ago'.trParams({'count': '${diff.inHours}'});
    if (diff.inDays < 7) return 'days_ago'.trParams({'count': '${diff.inDays}'});
    if (diff.inDays < 30) return 'weeks_ago'.trParams({'count': '${(diff.inDays / 7).floor()}'});
    return formatDate(date);
  }

  /// Calculate age from date of birth
  static int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Format distance (e.g. "2.5 km")
  static String formatDistance(double? km) {
    if (km == null) return '';
    if (km < 1) return 'meters_away'.trParams({'count': '${(km * 1000).round()}'});
    return 'km_away'.trParams({'distance': km.toStringAsFixed(1)});
  }

  /// Show snackbar
  static void showSnackbar({
    required String message,
    String? title,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title ?? (isError ? 'error'.tr : 'success'.tr),
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? Colors.red.shade50
          : Colors.green.shade50,
      colorText: isError ? Colors.red.shade800 : Colors.green.shade800,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: duration,
      icon: Icon(
        isError ? LucideIcons.alertCircle : LucideIcons.checkCircle2,
        color: isError ? Colors.red : Colors.green,
      ),
    );
  }

  /// Show loading dialog
  static void showLoading({String? message}) {
    final isDark = Get.isDarkMode;
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(message, style: Get.textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Hide loading dialog
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  /// Show beautiful Lottie animated dialog
  static void showLottieDialog({
    required String lottieAsset,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
    bool showCancelButton = false,
    bool barrierDismissible = true,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie Animation Container
              SizedBox(
                height: 120,
                width: 120,
                child: Lottie.asset(
                  lottieAsset,
                  fit: BoxFit.contain,
                  repeat: false,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to Icon if Lottie fails to load
                    return const Icon(
                      LucideIcons.info,
                      size: 60,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Get.theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              
              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Get.theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              
              // Action Buttons
              if (showCancelButton)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Get.theme.textTheme.bodyLarge?.color,
                          side: BorderSide(color: Get.theme.dividerColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'cancel'.tr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          if (onConfirm != null) onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.theme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          confirmText ?? 'ok'.tr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      if (onConfirm != null) onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      confirmText ?? 'ok'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  /// Truncate string
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Get initials from name
  static String getInitials(String? firstName, [String? lastName]) {
    String initials = '';
    if (firstName != null && firstName.isNotEmpty) initials += firstName[0];
    if (lastName != null && lastName.isNotEmpty) initials += lastName[0];
    return initials.toUpperCase();
  }

  /// Format time (e.g. "2:30 PM")
  static String formatTime(DateTime? date) {
    if (date == null) return '';
    return intl.DateFormat('h:mm a').format(date);
  }

  /// Format number with K/M suffix
  static String formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
