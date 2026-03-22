import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/profile_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EditProfileDataScreen extends StatefulWidget {
  const EditProfileDataScreen({super.key});

  @override
  State<EditProfileDataScreen> createState() => _EditProfileDataScreenState();
}

class _EditProfileDataScreenState extends State<EditProfileDataScreen> {
  final ProfileController controller = Get.find<ProfileController>();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _jobTitleCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _countryCtrl;

  String? _gender;
  String? _maritalStatus;
  String? _education;
  String? _sect;
  String? _religiousLevel;
  String? _prayerFrequency;
  DateTime? _dateOfBirth;
  List<String> _selectedInterests = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = controller.user.value;
    _firstNameCtrl = TextEditingController(text: user?.firstName);
    _lastNameCtrl = TextEditingController(text: user?.lastName);
    _phoneCtrl = TextEditingController(text: user?.phone);
    _bioCtrl = TextEditingController(text: user?.profile?.bio);
    _heightCtrl = TextEditingController(text: user?.profile?.height?.toString());
    _jobTitleCtrl = TextEditingController(text: user?.profile?.jobTitle);
    _companyCtrl = TextEditingController(text: user?.profile?.company);
    _cityCtrl = TextEditingController(text: user?.profile?.city);
    _countryCtrl = TextEditingController(text: user?.profile?.country);
    _gender = user?.profile?.gender;
    _maritalStatus = user?.profile?.maritalStatus;
    _education = user?.profile?.education;
    _sect = user?.profile?.sect;
    _religiousLevel = user?.profile?.religiousLevel;
    _prayerFrequency = user?.profile?.prayerFrequency;
    _dateOfBirth = user?.profile?.dateOfBirth;
    _selectedInterests = List<String>.from(user?.profile?.interests ?? []);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _heightCtrl.dispose();
    _jobTitleCtrl.dispose();
    _companyCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  int _calculateCompletion() {
    int filled = 0;
    const total = 14;
    if (_bioCtrl.text.trim().isNotEmpty) filled++;
    if (_gender != null && _gender!.isNotEmpty) filled++;
    if (_maritalStatus != null && _maritalStatus!.isNotEmpty) filled++;
    if (_heightCtrl.text.isNotEmpty) filled++;
    if (_jobTitleCtrl.text.isNotEmpty) filled++;
    if (_education != null && _education!.isNotEmpty) filled++;
    if (_religiousLevel != null && _religiousLevel!.isNotEmpty) filled++;
    if (_prayerFrequency != null && _prayerFrequency!.isNotEmpty) filled++;
    if (_dateOfBirth != null) filled++;
    if (_cityCtrl.text.isNotEmpty) filled++;
    if (_countryCtrl.text.isNotEmpty) filled++;
    if (_selectedInterests.length >= 3) filled++;
    if (_firstNameCtrl.text.trim().isNotEmpty) filled++;
    if (_lastNameCtrl.text.trim().isNotEmpty) filled++;
    return ((filled / total) * 100).round().clamp(0, 100);
  }

  String _completionTip() {
    if (_bioCtrl.text.trim().isEmpty) return 'Add a bio to stand out';
    if (_gender == null || _gender!.isEmpty) return 'Select your gender';
    if (_dateOfBirth == null) return 'Add your date of birth';
    if (_selectedInterests.length < 3) return 'Add at least 3 interests';
    if (_cityCtrl.text.isEmpty) return 'Add your city';
    if (_jobTitleCtrl.text.isEmpty) return 'Add your job title';
    return 'Your profile is looking great!';
  }

  Map<String, dynamic> _collectData() {
    return {
      if (_firstNameCtrl.text.trim().isNotEmpty) 'firstName': _firstNameCtrl.text.trim(),
      if (_lastNameCtrl.text.trim().isNotEmpty) 'lastName': _lastNameCtrl.text.trim(),
      if (_bioCtrl.text.trim().isNotEmpty) 'bio': _bioCtrl.text.trim(),
      if (_gender != null) 'gender': _gender,
      if (_maritalStatus != null) 'maritalStatus': _maritalStatus,
      if (_heightCtrl.text.isNotEmpty) 'height': int.tryParse(_heightCtrl.text),
      if (_jobTitleCtrl.text.isNotEmpty) 'jobTitle': _jobTitleCtrl.text.trim(),
      if (_companyCtrl.text.isNotEmpty) 'company': _companyCtrl.text.trim(),
      if (_education != null) 'education': _education,
      if (_sect != null) 'sect': _sect,
      if (_religiousLevel != null) 'religiousLevel': _religiousLevel,
      if (_prayerFrequency != null) 'prayerFrequency': _prayerFrequency,
      if (_dateOfBirth != null) 'dateOfBirth': _dateOfBirth!.toIso8601String().split('T')[0],
      if (_cityCtrl.text.isNotEmpty) 'city': _cityCtrl.text.trim(),
      if (_countryCtrl.text.isNotEmpty) 'country': _countryCtrl.text.trim(),
      'interests': _selectedInterests,
    };
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final success = await controller.updateProfile(_collectData());
    if (mounted) {
      setState(() => _saving = false);
      if (success) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : const Color(0xFFF8F5FA);
    final cardBg = isDark ? AppColors.cardDark : Colors.white;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final hintColor = isDark ? AppColors.textHintDark : AppColors.textHintLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  _CircleBtn(
                    icon: LucideIcons.chevronLeft,
                    isDark: isDark,
                    onTap: () => Get.back(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor),
                    ),
                  ),
                  _saving
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : GestureDetector(
                          onTap: _save,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Body ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: [
                  // ── Completion Card ──
                  _CompletionCard(completion: _calculateCompletion(), tip: _completionTip(), isDark: isDark),
                  const SizedBox(height: 20),

                  // ── About Me ──
                  _SectionCard(
                    title: 'About Me',
                    icon: LucideIcons.sparkles,
                    isDark: isDark,
                    cardBg: cardBg,
                    children: [
                      _ModernField(label: 'First Name', controller: _firstNameCtrl, icon: LucideIcons.user, isDark: isDark, borderColor: borderColor, hintColor: hintColor),
                      _ModernField(label: 'Last Name', controller: _lastNameCtrl, icon: LucideIcons.user, isDark: isDark, borderColor: borderColor, hintColor: hintColor),
                      _ModernField(label: 'Bio', controller: _bioCtrl, icon: LucideIcons.alignLeft, isDark: isDark, borderColor: borderColor, hintColor: hintColor, maxLines: 3),
                      _DateField(
                        label: 'Date of Birth',
                        value: _dateOfBirth,
                        isDark: isDark,
                        borderColor: borderColor,
                        hintColor: hintColor,
                        onPick: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _dateOfBirth ?? DateTime(2000),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                          );
                          if (d != null) setState(() => _dateOfBirth = d);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Personal Details ──
                  _SectionCard(
                    title: 'Personal Details',
                    icon: LucideIcons.clipboardList,
                    isDark: isDark,
                    cardBg: cardBg,
                    children: [
                      _ChipSelector(
                        label: 'Gender',
                        options: const ['male', 'female'],
                        displayLabels: const ['Male', 'Female'],
                        selected: _gender,
                        onSelect: (v) => setState(() => _gender = v),
                        isDark: isDark,
                      ),
                      _ChipSelector(
                        label: 'Marital Status',
                        options: const ['single', 'divorced', 'widowed'],
                        displayLabels: const ['Single', 'Divorced', 'Widowed'],
                        selected: _maritalStatus,
                        onSelect: (v) => setState(() => _maritalStatus = v),
                        isDark: isDark,
                      ),
                      _ModernField(label: 'Height (cm)', controller: _heightCtrl, icon: LucideIcons.ruler, isDark: isDark, borderColor: borderColor, hintColor: hintColor, keyboard: TextInputType.number),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Career & Education ──
                  _SectionCard(
                    title: 'Career & Education',
                    icon: LucideIcons.briefcase,
                    isDark: isDark,
                    cardBg: cardBg,
                    children: [
                      _ModernField(label: 'Job Title', controller: _jobTitleCtrl, icon: LucideIcons.briefcase, isDark: isDark, borderColor: borderColor, hintColor: hintColor),
                      _ModernField(label: 'Company', controller: _companyCtrl, icon: LucideIcons.building, isDark: isDark, borderColor: borderColor, hintColor: hintColor),
                      _ChipSelector(
                        label: 'Education',
                        options: const ['high_school', 'bachelors', 'masters', 'phd', 'other'],
                        displayLabels: const ['High School', "Bachelor's", "Master's", 'PhD', 'Other'],
                        selected: _education,
                        onSelect: (v) => setState(() => _education = v),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Faith & Religion ──
                  _SectionCard(
                    title: 'Faith & Religion',
                    icon: LucideIcons.moon,
                    isDark: isDark,
                    cardBg: cardBg,
                    children: [
                      _ChipSelector(
                        label: 'Sect',
                        options: const ['sunni', 'shia', 'ibadi', 'other'],
                        displayLabels: const ['Sunni', 'Shia', 'Ibadi', 'Other'],
                        selected: _sect,
                        onSelect: (v) => setState(() => _sect = v),
                        isDark: isDark,
                      ),
                      _ChipSelector(
                        label: 'Religious Level',
                        options: const ['very_religious', 'religious', 'moderate', 'not_religious'],
                        displayLabels: const ['Very Religious', 'Religious', 'Moderate', 'Not Religious'],
                        selected: _religiousLevel,
                        onSelect: (v) => setState(() => _religiousLevel = v),
                        isDark: isDark,
                      ),
                      _ChipSelector(
                        label: 'Prayer Frequency',
                        options: const ['always', 'mostly', 'sometimes', 'rarely', 'never'],
                        displayLabels: const ['Always', 'Mostly', 'Sometimes', 'Rarely', 'Never'],
                        selected: _prayerFrequency,
                        onSelect: (v) => setState(() => _prayerFrequency = v),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Interests ──
                  _SectionCard(
                    title: 'Interests',
                    icon: LucideIcons.heart,
                    isDark: isDark,
                    cardBg: cardBg,
                    children: [
                      _InterestsGrid(
                        selected: _selectedInterests,
                        isDark: isDark,
                        onToggle: (i) {
                          setState(() {
                            if (_selectedInterests.contains(i)) {
                              _selectedInterests.remove(i);
                            } else {
                              _selectedInterests.add(i);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Location ──
                  _SectionCard(
                    title: 'Location',
                    icon: LucideIcons.mapPin,
                    isDark: isDark,
                    cardBg: cardBg,
                    children: [
                      _ModernField(label: 'City', controller: _cityCtrl, icon: LucideIcons.building, isDark: isDark, borderColor: borderColor, hintColor: hintColor),
                      _ModernField(label: 'Country', controller: _countryCtrl, icon: LucideIcons.globe, isDark: isDark, borderColor: borderColor, hintColor: hintColor),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Save button ──
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: _saving
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Card ──────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final Color cardBg;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.icon, required this.isDark, required this.cardBg, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// ─── Modern Field ──────────────────────────────────────────────────────────
class _ModernField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isDark;
  final Color borderColor;
  final Color hintColor;
  final int maxLines;
  final TextInputType keyboard;

  const _ModernField({required this.label, required this.controller, required this.icon, required this.isDark, required this.borderColor, required this.hintColor, this.maxLines = 1, this.keyboard = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 12, color: hintColor),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        ),
      ),
    );
  }
}

// ─── Date Field ────────────────────────────────────────────────────────────
class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final bool isDark;
  final Color borderColor;
  final Color hintColor;
  final VoidCallback onPick;

  const _DateField({required this.label, this.value, required this.isDark, required this.borderColor, required this.hintColor, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final display = value != null ? '${value!.day}/${value!.month}/${value!.year}' : 'Select date';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onPick,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontSize: 12, color: hintColor),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            prefixIcon: const Icon(LucideIcons.calendar, size: 18, color: AppColors.primary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
          ),
          child: Text(
            display,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: value != null
                  ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                  : hintColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Chip Selector (replaces broken DropdownButtonFormField) ───────────────
class _ChipSelector extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> displayLabels;
  final String? selected;
  final ValueChanged<String> onSelect;
  final bool isDark;

  const _ChipSelector({required this.label, required this.options, required this.displayLabels, this.selected, required this.onSelect, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(options.length, (i) {
              final isActive = selected == options[i];
              return GestureDetector(
                onTap: () => onSelect(options[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : (isDark ? AppColors.surfaceDark : AppColors.dividerLight),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isActive ? AppColors.primary : Colors.transparent),
                  ),
                  child: Text(
                    displayLabels[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Completion Card ───────────────────────────────────────────────────────
class _CompletionCard extends StatelessWidget {
  final int completion;
  final String tip;
  final bool isDark;
  const _CompletionCard({required this.completion, required this.tip, required this.isDark});

  Color get _color {
    if (completion >= 80) return const Color(0xFF2ECC71);
    if (completion >= 50) return const Color(0xFFF39C12);
    return const Color(0xFFE74C3C);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.08), AppColors.primaryLight.withValues(alpha: 0.04)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52, height: 52,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: completion / 100),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, val, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(value: val, strokeWidth: 5, backgroundColor: isDark ? AppColors.borderDark : Colors.grey.shade200, valueColor: AlwaysStoppedAnimation(_color)),
                    Text('$completion%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _color)),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile Completion', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                const SizedBox(height: 3),
                Text(tip, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Interests Grid ────────────────────────────────────────────────────────
class _InterestsGrid extends StatelessWidget {
  final List<String> selected;
  final bool isDark;
  final ValueChanged<String> onToggle;
  const _InterestsGrid({required this.selected, required this.isDark, required this.onToggle});

  static const _all = [
    'Travel', 'Reading', 'Cooking', 'Fitness', 'Photography', 'Music',
    'Movies', 'Art', 'Gaming', 'Hiking', 'Swimming', 'Yoga', 'Fashion',
    'Technology', 'Writing', 'Dancing', 'Volunteering', 'Sports',
    'Coffee', 'Nature', 'Pets', 'Cars', 'Gardening', 'DIY',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select at least 3', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _all.map((interest) {
            final active = selected.contains(interest);
            return GestureDetector(
              onTap: () => onToggle(interest),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary.withValues(alpha: 0.12) : (isDark ? AppColors.surfaceDark : AppColors.dividerLight),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: active ? AppColors.primary : Colors.transparent, width: 1.5),
                ),
                child: Text(interest, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? AppColors.primary : null)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Circle Button ─────────────────────────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Icon(icon, size: 18, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      ),
    );
  }
}
