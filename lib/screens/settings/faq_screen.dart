import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _purple = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final selectedTab = 0.obs;
    final tabs = ['General', 'Account', 'Dating', 'Subscription'];

    final faqItems = <_FaqData>[
      _FaqData(
        question: 'What is Datify?',
        answer:
            'Datify is a dating app designed to help you meet new people, make meaningful connections, and find potential matches based on your interests and preferences.',
      ),
      _FaqData(
        question: 'How do I create a Datify account?',
        answer: '',
      ),
      _FaqData(
        question: 'Is Datify free to use?',
        answer: '',
      ),
      _FaqData(
        question: 'How does matching work on Datify?',
        answer: '',
      ),
      _FaqData(
        question: 'Can I change my location on Datify?',
        answer: '',
      ),
      _FaqData(
        question: 'How do I report a user or profile?',
        answer: '',
      ),
    ];

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

            const SizedBox(height: 16),

            // ── Tab bar ──
            SizedBox(
              height: 36,
              child: Obx(() => ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: tabs.length,
                    separatorBuilder: (_, i) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isActive = selectedTab.value == index;
                      return GestureDetector(
                        onTap: () => selectedTab.value = index,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isActive
                                ? _purple
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            border: isActive
                                ? null
                                : Border.all(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : Colors.grey.shade300,
                                  ),
                          ),
                          child: Text(
                            tabs[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.white
                                  : textColor,
                            ),
                          ),
                        ),
                      );
                    },
                  )),
            ),

            const SizedBox(height: 16),

            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(LucideIcons.search,
                        size: 20, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                            fontSize: 14, color: textColor),
                        decoration: InputDecoration(
                          hintText: 'search'.tr,
                          hintStyle: TextStyle(
                              fontSize: 14,
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

            const SizedBox(height: 8),

            // ── FAQ list ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: faqItems.length,
                itemBuilder: (context, index) {
                  return _FaqTile(
                    data: faqItems[index],
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    isDark: isDark,
                    initiallyExpanded: index == 0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqData {
  final String question;
  final String answer;
  _FaqData({required this.question, required this.answer});
}

// ─── FAQ expandable tile ──────────────────────────────────────────────────
class _FaqTile extends StatefulWidget {
  final _FaqData data;
  final Color textColor;
  final Color secondaryColor;
  final bool isDark;
  final bool initiallyExpanded;

  const _FaqTile({
    required this.data,
    required this.textColor,
    required this.secondaryColor,
    required this.isDark,
    this.initiallyExpanded = false,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.data.question,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: widget.textColor,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    LucideIcons.chevronDown,
                    size: 22,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: widget.data.answer.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    widget.data.answer,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: widget.secondaryColor,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        Divider(
          height: 1,
          color: widget.isDark
              ? AppColors.dividerDark
              : Colors.grey.shade200,
        ),
      ],
    );
  }
}
