import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:methna_app/app/controllers/profile_controller.dart';
import 'package:methna_app/app/theme/app_colors.dart';
import 'package:methna_app/core/utils/helpers.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Enhanced Complete Profile Screen with Modern UX
/// Step-by-step profile completion with better visual hierarchy
class EnhancedEditProfileScreen extends StatefulWidget {
  const EnhancedEditProfileScreen({super.key});

  @override
  State<EnhancedEditProfileScreen> createState() => _EnhancedEditProfileScreenState();
}

class _EnhancedEditProfileScreenState extends State<EnhancedEditProfileScreen> 
    with TickerProviderStateMixin {
  final ProfileController controller = Get.find<ProfileController>();
  late TabController _tabController;
  int _currentStep = 0;
  
  final List<ProfileStep> _steps = [
    ProfileStep(
      title: 'Basic Info',
      subtitle: 'Name, age, location',
      icon: LucideIcons.user,
      isCompleted: false,
    ),
    ProfileStep(
      title: 'Photos',
      subtitle: 'Add your best photos',
      icon: LucideIcons.image,
      isCompleted: false,
    ),
    ProfileStep(
      title: 'About You',
      subtitle: 'Bio and interests',
      icon: LucideIcons.fileText,
      isCompleted: false,
    ),
    ProfileStep(
      title: 'Lifestyle',
      subtitle: 'Values and preferences',
      icon: LucideIcons.heart,
      isCompleted: false,
    ),
    ProfileStep(
      title: 'Faith',
      subtitle: 'Religious commitment',
      icon: LucideIcons.moon,
      isCompleted: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _steps.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentStep = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : const Color(0xFFF8F5FA);
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final cardBg = isDark ? AppColors.cardDark : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress
            _buildHeader(textColor, cardBg),
            
            // Step indicator
            _buildStepIndicator(textColor),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _BasicInfoStep(),
                  _PhotosStep(),
                  _AboutStep(),
                  _LifestyleStep(),
                  _FaithStep(),
                ],
              ),
            ),
            
            // Bottom navigation
            _buildBottomNavigation(textColor, cardBg),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color cardBg) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(LucideIcons.chevronLeft, color: textColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Your Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Step ${_currentStep + 1} of ${_steps.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_currentStep + 1) / _steps.length,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(Color textColor) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(_steps.length, (index) {
          final step = _steps[index];
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(index),
              child: Column(
                children: [
                  // Step circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isActive 
                          ? AppColors.primary
                          : isCompleted
                              ? AppColors.success
                              : textColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive 
                            ? AppColors.primary
                            : textColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isCompleted ? LucideIcons.check : step.icon,
                      color: isActive || isCompleted ? Colors.white : textColor.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Step title
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive 
                          ? AppColors.primary
                          : isCompleted
                              ? AppColors.success
                              : textColor.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Connector line
                  if (index < _steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: isCompleted 
                            ? AppColors.success
                            : textColor.withValues(alpha: 0.2),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomNavigation(Color textColor, Color cardBg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(
          top: BorderSide(color: textColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          // Previous button
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _tabController.animateTo(_currentStep - 1),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('Previous', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            )
          else
            const Expanded(child: SizedBox()),
          
          const SizedBox(width: 12),
          
          // Next/Save button
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleNext(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentStep == _steps.length - 1 ? 'Complete' : 'Next',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (_currentStep < _steps.length - 1) ...[
                    const SizedBox(width: 8),
                    Icon(LucideIcons.chevronRight, size: 18),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    if (_currentStep < _steps.length - 1) {
      _tabController.animateTo(_currentStep + 1);
    } else {
      // Complete profile
      Get.back();
      Helpers.showSnackbar(message: 'Profile completed successfully!');
    }
  }
}

// Step content widgets
class _BasicInfoStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _SectionCard(
            title: 'Personal Information',
            children: [
              _TextField(label: 'First Name', hint: 'Enter your first name'),
              _TextField(label: 'Last Name', hint: 'Enter your last name'),
              _TextField(label: 'Age', hint: 'Enter your age', keyboardType: TextInputType.number),
              _TextField(label: 'City', hint: 'Enter your city'),
              _TextField(label: 'Country', hint: 'Enter your country'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotosStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _SectionCard(
            title: 'Profile Photos',
            subtitle: 'Add at least 2 photos to get started',
            children: [
              _PhotoUploadGrid(),
            ],
          ),
        ],
      ),
    );
  }
}

class _AboutStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _SectionCard(
            title: 'About You',
            children: [
              _TextAreaField(
                label: 'Bio',
                hint: 'Tell us about yourself, your interests, and what you\'re looking for...',
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              Text(
                'Interests',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              _InterestChips(),
            ],
          ),
        ],
      ),
    );
  }
}

class _LifestyleStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _SectionCard(
            title: 'Lifestyle & Preferences',
            children: [
              _DropdownField(label: 'Education', hint: 'Select education level'),
              _DropdownField(label: 'Job Title', hint: 'Enter your job title'),
              _DropdownField(label: 'Height', hint: 'Select height'),
              _DropdownField(label: 'Marital Status', hint: 'Select marital status'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FaithStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _SectionCard(
            title: 'Faith & Values',
            subtitle: 'Help us find compatible matches',
            children: [
              _DropdownField(label: 'Religious Level', hint: 'How religious are you?'),
              _DropdownField(label: 'Prayer Frequency', hint: 'How often do you pray?'),
              _DropdownField(label: 'Sect', hint: 'Select your sect'),
              _DropdownField(label: 'Dietary Preferences', hint: 'Halal, etc.'),
              _TextAreaField(
                label: 'What\'s important to you in a partner?',
                hint: 'Share your values and expectations...',
                maxLines: 3,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper widgets
class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : Colors.white;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextInputType? keyboardType;

  const _TextField({
    required this.label,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextAreaField extends StatelessWidget {
  final String label;
  final String hint;
  final int maxLines;

  const _TextAreaField({
    required this.label,
    required this.hint,
    this.maxLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String hint;

  const _DropdownField({
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            items: const [],
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}

class _PhotoUploadGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: index == 0
              ? const Center(
                  child: Icon(
                    LucideIcons.plus,
                    color: AppColors.primary,
                    size: 32,
                  ),
                )
              : const SizedBox(),
        );
      },
    );
  }
}

class _InterestChips extends StatelessWidget {
  final List<String> interests = [
    'Reading', 'Travel', 'Cooking', 'Sports', 'Music',
    'Art', 'Gaming', 'Fitness', 'Nature', 'Photography',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: interests.map((interest) {
        return FilterChip(
          label: Text(interest),
          onSelected: (bool selected) {},
          backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          selectedColor: AppColors.primary.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        );
      }).toList(),
    );
  }
}

class ProfileStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isCompleted;

  ProfileStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isCompleted,
  });
}
