import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Utility for triggering haptic feedback on user interactions.
class HapticHelper {
  HapticHelper._();

  /// Light tap feedback (button presses, selections).
  static Future<void> lightTap() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact feedback (swipe actions, toggles).
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact feedback (super-like, match found).
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection click feedback (radio buttons, checkboxes).
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Custom vibration pattern for match found celebration.
  static Future<void> matchVibration() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      // Short-long-short pattern
      Vibration.vibrate(pattern: [0, 50, 100, 150, 100, 50]);
    } else {
      await HapticFeedback.heavyImpact();
    }
  }

  /// Subtle vibration for swipe feedback.
  static Future<void> swipeFeedback() async {
    final hasAmplitude = await Vibration.hasAmplitudeControl();
    if (hasAmplitude) {
      Vibration.vibrate(duration: 20, amplitude: 60);
    } else {
      await HapticFeedback.lightImpact();
    }
  }
}
