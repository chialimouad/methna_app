import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/settings_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FaqScreen extends GetView<SettingsController> {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final searchQuery = ''.obs;

    // Fetch FAQ content from backend on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchFaqContent();
    });

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(LucideIcons.chevronLeft,
                          size: 16, color: textColor),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'faq'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Icon(LucideIcons.search,
                        size: 20, color: Colors.grey.shade400),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        onChanged: (val) => searchQuery.value = val,
                        style: TextStyle(
                            fontSize: 15, color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Search FAQs...',
                          hintStyle: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade400),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── FAQ list ──
            Expanded(
              child: Obx(() {
                if (controller.isLoadingFaq.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final items = controller.faqItems
                    .where((item) {
                      final q = (item['question'] ?? '').toString().toLowerCase();
                      final a = (item['answer'] ?? '').toString().toLowerCase();
                      final query = searchQuery.value.toLowerCase();
                      return q.contains(query) || a.contains(query);
                    })
                    .toList();

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.helpCircle, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No FAQs found',
                          style: TextStyle(fontSize: 16, color: secondaryColor),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _FaqTile(
                      question: item['question']?.toString() ?? '',
                      answer: item['answer']?.toString() ?? '',
                      textColor: textColor,
                      secondaryColor: secondaryColor,
                      isDark: isDark,
                      initiallyExpanded: index == 0,
                    ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideX(begin: 0.05, end: 0);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── FAQ expandable tile ────────────────────────────────────────────────────────────────
class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  final Color textColor;
  final Color secondaryColor;
  final bool isDark;
  final bool initiallyExpanded;

  const _FaqTile({
    required this.question,
    required this.answer,
    required this.textColor,
    required this.secondaryColor,
    required this.isDark,
    this.initiallyExpanded = false,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _animController;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _animController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _heightFactor = _animController.drive(CurveTween(curve: Curves.easeInOut));
    if (_expanded) _animController.value = 1.0;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _expanded
              ? AppColors.primary.withValues(alpha: 0.3)
              : (widget.isDark ? AppColors.borderDark : Colors.grey.shade200),
        ),
        boxShadow: _expanded
            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))]
            : null,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: _expanded ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      LucideIcons.helpCircle,
                      size: 18,
                      color: _expanded ? AppColors.primary : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: _expanded ? FontWeight.w700 : FontWeight.w600,
                        color: widget.textColor,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _expanded
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.chevronDown,
                        size: 16,
                        color: _expanded ? AppColors.primary : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  heightFactor: _heightFactor.value,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              );
            },
            child: widget.answer.isNotEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : AppColors.primary.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.answer,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: widget.secondaryColor,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
