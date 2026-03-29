import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/profile_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:methna_app/app/controllers/signup_data.dart';

/// Beautiful Edit Profile Screen with Modern Design
/// Features: Glass morphism, smooth animations, elegant UI
class BeautifulEditProfileScreen extends StatefulWidget {
  const BeautifulEditProfileScreen({super.key});

  @override
  State<BeautifulEditProfileScreen> createState() => _BeautifulEditProfileScreenState();
}

class _BeautifulEditProfileScreenState extends State<BeautifulEditProfileScreen>
    with TickerProviderStateMixin {
  final ProfileController controller = Get.find<ProfileController>();
  late TabController _tabController;
  late PageController _pageController;
  
  // Form controllers
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _jobTitleCtrl;
  late final TextEditingController _companyCtrl;
  
  // State variables for dropdowns
  String? _country;
  String? _city;

  // Form state
  String? _gender;
  String? _maritalStatus;
  String? _education;
  String? _sect;
  String? _religiousLevel;
  String? _prayerFrequency;
  String? _dietary;
  String? _alcohol;
  DateTime? _dateOfBirth;
  List<String> _selectedInterests = [];
  bool _isSaving = false;
  int _completionPercentage = 0;

  final List<String> _interests = [
    'interest_reading', 'interest_travel', 'interest_cooking', 'interest_sports', 'interest_music', 'interest_art',
    'interest_gaming', 'interest_fitness', 'interest_nature', 'interest_photography', 'interest_writing',
    'interest_movies', 'interest_technology', 'interest_fashion', 'interest_volunteering', 'interest_dancing'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
    _initializeFormData();
    _calculateCompletion();
  }

  void _initializeFormData() {
    final user = controller.user.value;
    final profile = user?.profile;
    
    _firstNameCtrl = TextEditingController(text: user?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: user?.lastName ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _bioCtrl = TextEditingController(text: profile?.bio ?? '');
    _heightCtrl = TextEditingController(text: profile?.height?.toString() ?? '');
    _jobTitleCtrl = TextEditingController(text: profile?.jobTitle ?? '');
    _companyCtrl = TextEditingController(text: profile?.company ?? '');
    _country = profile?.country;
    _city = profile?.city;
    
    _gender = profile?.gender;
    _maritalStatus = profile?.maritalStatus;
    _education = profile?.education;
    _sect = profile?.sect;
    _religiousLevel = profile?.religiousLevel;
    _prayerFrequency = profile?.prayerFrequency;
    _dietary = profile?.dietary;
    _alcohol = profile?.alcohol;
    _dateOfBirth = profile?.dateOfBirth;
    _selectedInterests = List.from(profile?.interests ?? []);
  }

  void _calculateCompletion() {
    int filled = 0;
    int total = 15;
    
    if (_firstNameCtrl.text.isNotEmpty) filled++;
    if (_lastNameCtrl.text.isNotEmpty) filled++;
    if (_bioCtrl.text.isNotEmpty) filled++;
    if (_gender != null) filled++;
    if (_dateOfBirth != null) filled++;
    if (_maritalStatus != null) filled++;
    if (_education != null) filled++;
    if (_jobTitleCtrl.text.isNotEmpty) filled++;
    if (_heightCtrl.text.isNotEmpty) filled++;
    if (_country != null) filled++;
    if (_city != null) filled++;
    if (_religiousLevel != null) filled++;
    if (_prayerFrequency != null) filled++;
    if (_sect != null) filled++;
    if (_dietary != null) filled++;
    
    // Check for photos vs interests
    final hasPhotos = controller.user.value?.photos?.isNotEmpty == true;
    if (hasPhotos) filled++;
    
    setState(() {
      _completionPercentage = ((filled / total) * 100).round();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _heightCtrl.dispose();
    _jobTitleCtrl.dispose();
    _companyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0F1E) : const Color(0xFFF8FAFF);
    final textColor = isDark ? const Color(0xFFE4E4E7) : const Color(0xFF1E1E2E);

    return Scaffold(
      backgroundColor: bgColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                      const Color(0xFF9B59FF).withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'edit_profile'.tr,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'edit_profile_desc'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Helpers.backIcon, color: Colors.white, size: 20),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: _isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(LucideIcons.check, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          
          // Progress & Tabs area in header to keep them pinned below app bar
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProgressIndicator(textColor),
                _buildBeautifulTabBar(textColor),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(textColor),
            _buildLifestyleTab(textColor),
            _buildFaithTab(textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(Color textColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.sparkles, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'profile_mastery'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_completionPercentage%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.05),
              ),
              child: Stack(
                children: [
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutExpo,
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: _completionPercentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF6B4EE6)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeautifulTabBar(Color textColor) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          padding: const EdgeInsets.all(6),
          child: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: textColor.withValues(alpha: 0.5),
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: [
              Tab(text: 'profile_tab'.tr),
              Tab(text: 'lifestyle_tab'.tr),
              Tab(text: 'faith_tab'.tr),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoTab(Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          _BeautifulSectionCard(
            title: 'personal_details_title'.tr,
            icon: LucideIcons.user,
            children: [
              _BeautifulTextField(
                controller: _firstNameCtrl,
                label: 'first_name_label'.tr,
                hint: 'first_name_hint'.tr,
                icon: LucideIcons.user,
                onChanged: _calculateCompletion,
              ),
              _BeautifulTextField(
                controller: _lastNameCtrl,
                label: 'last_name_label'.tr,
                hint: 'last_name_hint'.tr,
                icon: LucideIcons.user,
                onChanged: _calculateCompletion,
              ),
              _BeautifulDateField(
                label: 'birthday_label'.tr,
                hint: 'birthday_hint'.tr,
                icon: LucideIcons.calendar,
                date: _dateOfBirth,
                onChanged: (date) {
                  setState(() {
                    _dateOfBirth = date;
                    _calculateCompletion();
                  });
                },
              ),
              _BeautifulDropdownField(
                value: _gender,
                label: 'gender_label'.tr,
                hint: 'gender_hint'.tr,
                icon: LucideIcons.users,
                items: ['male', 'female'],
                onChanged: (value) {
                  setState(() => _gender = value);
                  _calculateCompletion();
                },
              ),
              _BeautifulTextField(
                controller: _phoneCtrl,
                label: 'phone_label'.tr,
                hint: 'phone_hint'.tr,
                icon: LucideIcons.phone,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _BeautifulSectionCard(
            title: 'about_you_title'.tr,
            icon: LucideIcons.fileText,
            children: [
              _BeautifulTextAreaField(
                controller: _bioCtrl,
                label: 'bio_label'.tr,
                hint: 'bio_hint'.tr,
                icon: LucideIcons.edit,
                maxLines: 4,
                onChanged: _calculateCompletion,
              ),
              _BeautifulInterestSelector(),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _BeautifulSectionCard(
            title: 'professional_life_title'.tr,
            icon: LucideIcons.briefcase,
            children: [
              _BeautifulTextField(
                controller: _jobTitleCtrl,
                label: 'job_title_label'.tr,
                hint: 'job_title_hint'.tr,
                icon: LucideIcons.briefcase,
                onChanged: _calculateCompletion,
              ),
              _BeautifulTextField(
                controller: _companyCtrl,
                label: 'company_label'.tr,
                hint: 'company_hint'.tr,
                icon: LucideIcons.building,
              ),
              _BeautifulDropdownField(
                value: _education,
                label: 'education_label'.tr,
                hint: 'education_hint'.tr,
                icon: LucideIcons.graduationCap,
                items: ['high_school', 'bachelors', 'masters', 'phd'],
                onChanged: (value) {
                  setState(() => _education = value);
                  _calculateCompletion();
                },
              ),
            ],
          ),
          const SizedBox(height: 100), // Extra space for scrolling comfort
        ],
      ),
    );
  }

  Widget _buildLifestyleTab(Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          _BeautifulSectionCard(
            title: 'location_title'.tr,
            icon: LucideIcons.mapPin,
            children: [
              _BeautifulDropdownField(
                value: _country,
                label: 'country_label'.tr,
                hint: 'country_hint'.tr,
                icon: LucideIcons.globe,
                items: SignupData.arabicCountries,
                onChanged: (value) {
                  setState(() {
                    _country = value;
                    _city = null; // Reset city when country changes
                    _calculateCompletion();
                  });
                },
              ),
              if (_country != null)
                _BeautifulDropdownField(
                  value: _city,
                  label: 'city_label'.tr,
                  hint: 'city_hint'.tr,
                  icon: LucideIcons.mapPin,
                  items: SignupData.countryCities[_country!] ?? [],
                  onChanged: (value) {
                    setState(() {
                      _city = value;
                      _calculateCompletion();
                    });
                  },
                ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _BeautifulSectionCard(
            title: 'physical_attributes_title'.tr,
            icon: LucideIcons.user,
            children: [
              _BeautifulTextField(
                controller: _heightCtrl,
                label: 'height_label'.tr,
                hint: 'height_hint'.tr,
                icon: LucideIcons.ruler,
                keyboardType: TextInputType.number,
                onChanged: _calculateCompletion,
              ),
              _BeautifulDropdownField(
                value: _maritalStatus,
                label: 'marital_status_label'.tr,
                hint: 'marital_status_hint'.tr,
                icon: LucideIcons.heart,
                items: ['never_married', 'divorced', 'widowed', 'married'],
                onChanged: (value) {
                  setState(() => _maritalStatus = value);
                  _calculateCompletion();
                },
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _BeautifulSectionCard(
            title: 'lifestyle_habits_title'.tr,
            icon: LucideIcons.sparkles,
            children: [
              _BeautifulDropdownField(
                value: _dietary,
                label: 'dietary_label'.tr,
                hint: 'dietary_hint'.tr,
                icon: LucideIcons.utensils,
                items: ['halal', 'mostly_halal', 'sometimes_halal', 'non_halal'],
                onChanged: (value) {
                  setState(() => _dietary = value);
                  _calculateCompletion();
                },
              ),
              _BeautifulDropdownField(
                value: _alcohol,
                label: 'alcohol_label'.tr,
                hint: 'alcohol_hint'.tr,
                icon: LucideIcons.wine,
                items: ['never', 'rarely', 'occasionally', 'frequently'],
                onChanged: (value) {
                  setState(() => _alcohol = value);
                  _calculateCompletion();
                },
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFaithTab(Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          _BeautifulSectionCard(
            title: 'religious_foundation_title'.tr,
            icon: LucideIcons.moon,
            children: [
              _BeautifulDropdownField(
                value: _religiousLevel,
                label: 'religiousity_label'.tr,
                hint: 'religiousity_hint'.tr,
                icon: LucideIcons.star,
                items: ['very_practicing', 'practicing', 'moderate', 'liberal'],
                onChanged: (value) {
                  setState(() => _religiousLevel = value);
                  _calculateCompletion();
                },
              ),
              _BeautifulDropdownField(
                value: _prayerFrequency,
                label: 'prayer_label'.tr,
                hint: 'prayer_hint'.tr,
                icon: LucideIcons.clock,
                items: ['actively_practicing', 'occasionally', 'not_practicing'],
                onChanged: (value) {
                  setState(() => _prayerFrequency = value);
                  _calculateCompletion();
                },
              ),
              _BeautifulDropdownField(
                value: _sect,
                label: 'sect_label'.tr,
                hint: 'sect_hint'.tr,
                icon: LucideIcons.users,
                items: ['sunni', 'shia', 'other'],
                onChanged: (value) {
                  setState(() => _sect = value);
                  _calculateCompletion();
                },
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final profileData = {
        'bio': _bioCtrl.text.trim(),
        'gender': _gender,
        'dateOfBirth': _dateOfBirth?.toIso8601String(),
        'maritalStatus': _maritalStatus,
        'education': _education,
        'jobTitle': _jobTitleCtrl.text.trim(),
        'company': _companyCtrl.text.trim(),
        'city': _city,
        'country': _country,
        'height': int.tryParse(_heightCtrl.text),
        'religiousLevel': _religiousLevel,
        'prayerFrequency': _prayerFrequency,
        'sect': _sect,
        'dietary': _dietary,
        'alcohol': _alcohol,
        'interests': _selectedInterests,
      };

      final userData = {
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      };

      debugPrint('[BeautifulEditProfile] Saving userData: $userData');
      debugPrint('[BeautifulEditProfile] Saving profileData: $profileData');

      // Update profile
      final success = await controller.updateProfile({...userData, ...profileData});
      
      debugPrint('[BeautifulEditProfile] Save success: $success');
      
      if (success) {
        Get.back();
        Helpers.showSnackbar(message: 'profile_updated_success'.tr);
      } else {
        Helpers.showSnackbar(message: 'profile_update_failed'.tr, isError: true);
      }
    } catch (e) {
      debugPrint('[BeautifulEditProfile] Error saving: $e');
      Helpers.showSnackbar(message: 'Failed to save profile: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // Premium helper widgets
  Widget _BeautifulTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    VoidCallback? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.titleSmall?.color?.withValues(alpha: 0.8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              onChanged: (_) => onChanged?.call(),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: Icon(icon, color: AppColors.primary.withValues(alpha: 0.6), size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintStyle: TextStyle(color: Theme.of(context).hintColor.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _BeautifulTextAreaField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required int maxLines,
    VoidCallback? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.titleSmall?.color?.withValues(alpha: 0.8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              onChanged: (_) => onChanged?.call(),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  child: Icon(icon, color: AppColors.primary.withValues(alpha: 0.6), size: 18),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintStyle: TextStyle(color: Theme.of(context).hintColor.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _BeautifulDropdownField({
    required String? value,
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.titleSmall?.color?.withValues(alpha: 0.8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: DropdownButtonFormField<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                hint, 
                style: TextStyle(color: Theme.of(context).hintColor.withValues(alpha: 0.5)),
                overflow: TextOverflow.ellipsis,
              ),
              icon: Icon(LucideIcons.chevronDown, color: AppColors.primary.withValues(alpha: 0.6), size: 18),
              dropdownColor: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item.tr,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColors.primary.withValues(alpha: 0.6), size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _BeautifulDateField({
    required String label,
    required String hint,
    required IconData icon,
    required DateTime? date,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.titleSmall?.color?.withValues(alpha: 0.8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primary.withValues(alpha: 0.6), size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      date != null ? Helpers.formatDate(date) : hint,
                      style: TextStyle(
                        color: date != null ? null : Theme.of(context).hintColor.withValues(alpha: 0.5),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(LucideIcons.calendar, color: AppColors.primary.withValues(alpha: 0.6), size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _BeautifulInterestSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
          child: Text(
            'interests_selection_title'.tr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).textTheme.titleSmall?.color?.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _interests.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedInterests.remove(interest);
                  } else {
                    _selectedInterests.add(interest);
                  }
                  _calculateCompletion();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.1),
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ] : [],
                ),
                child: Text(
                  interest.tr,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 80)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      setState(() {
        _dateOfBirth = date;
        _calculateCompletion();
      });
    }
  }
}

class _BeautifulSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _BeautifulSectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E).withValues(alpha: 0.6) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          ...children,
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
