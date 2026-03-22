import 'package:flutter/material.dart';

extension StringExtension on String {
  String get capitalize => isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String get capitalizeEachWord =>
      split(' ').map((w) => w.capitalize).join(' ');
  bool get isValidEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  bool get isValidPhone => RegExp(r'^\+?[0-9]{8,15}$').hasMatch(replaceAll(' ', ''));
}

extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  int get age {
    final today = DateTime.now();
    int a = today.year - year;
    if (today.month < month || (today.month == month && today.day < day)) a--;
    return a;
  }
}

extension ContextExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

extension WidgetExtension on Widget {
  Widget padAll(double p) => Padding(padding: EdgeInsets.all(p), child: this);
  Widget padH(double p) => Padding(padding: EdgeInsets.symmetric(horizontal: p), child: this);
  Widget padV(double p) => Padding(padding: EdgeInsets.symmetric(vertical: p), child: this);
  Widget centered() => Center(child: this);
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  Widget withOpacity(double opacity) => Opacity(opacity: opacity, child: this);
  Widget clipRRect(double radius) =>
      ClipRRect(borderRadius: BorderRadius.circular(radius), child: this);
}
