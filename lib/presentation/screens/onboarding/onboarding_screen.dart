// lib/presentation/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/user_settings.dart';
import '../../../data/providers/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Temp state for onboarding
  DateTime? _selectedBirthDate;
  WeekStart _weekStart = WeekStart.monday;
  bool _notificationsEnabled = false;
  String _language = 'en';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.updateSettings(UserSettings(
      birthDate: _selectedBirthDate,
      weekStart: _weekStart,
      dailyReminderEnabled: _notificationsEnabled,
      languageCode: _language,
      onboardingCompleted: true,
    ));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _WelcomePage(language: _language, onLanguageChanged: (v) {
                    setState(() => _language = v);
                    // Update locale immediately so page 2+ strings reflect the chosen language
                    ref.read(localeProvider.notifier).state = Locale(v);
                  }),
                  _BirthdatePage(
                    selectedDate: _selectedBirthDate,
                    weekStart: _weekStart,
                    onDateChanged: (d) => setState(() => _selectedBirthDate = d),
                    onWeekStartChanged: (w) => setState(() => _weekStart = w),
                  ),
                  _NotificationsPage(
                    enabled: _notificationsEnabled,
                    onChanged: (v) => setState(() => _notificationsEnabled = v),
                  ),
                ],
              ),
            ),
            _buildFooter(l),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        children: [
          // Logo
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text('◈', style: TextStyle(fontSize: 18.sp, color: Colors.white)),
            ),
          ),
          const Spacer(),
          // Page indicators
          Row(
            children: List.generate(3, (i) => _buildDot(i)),
          ),
          const Spacer(),
          // Skip
          if (_currentPage < 2)
            TextButton(
              onPressed: _finish,
              child: Text(
                l.skip,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            SizedBox(width: 60.w),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      width: isActive ? 24.w : 8.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l) {
    final isLast = _currentPage == 2;
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: _PrimaryButton(
        label: isLast ? l.getStarted : l.next,
        onTap: _nextPage,
        icon: isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;

  const _WelcomePage({required this.language, required this.onLanguageChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          // Big illustration
          Container(
            height: 220.h,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(color: AppColors.border),
            ),
            child: _CalendarIllustration(),
          ),
          SizedBox(height: 36.h),
          Text(
            language == 'ru' ? 'Ваше время наглядно' : 'Your Time, Visualized',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
          SizedBox(height: 16.h),
          Text(
            language == 'ru'
                ? 'Видите точно, где вы находитесь в году, месяце, неделе — и во всей жизни.'
                : 'See exactly where you are in the year, month, week — and your entire life.',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          SizedBox(height: 36.h),
          // Language selector
          _LanguageSelector(selected: language, onChanged: onLanguageChanged),
        ],
      ),
    );
  }
}

class _CalendarIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayOfYear = AppDateUtils.dayOfYear(now);
    final totalDays = AppDateUtils.daysInYear(now.year);
    final progress = dayOfYear / totalDays;

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(1)}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 56.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  '%',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '${now.year} progress',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 20.h),
          // Progress bar
          Container(
            height: 8.h,
            decoration: BoxDecoration(
              color: AppColors.progressBackground,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Day $dayOfYear of $totalDays',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _LanguageSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LangChip(code: 'en', label: '🇺🇸  English', selected: selected == 'en', onTap: () => onChanged('en')),
        SizedBox(width: 12.w),
        _LangChip(code: 'ru', label: '🇷🇺  Русский', selected: selected == 'ru', onTap: () => onChanged('ru')),
      ],
    );
  }
}

class _LangChip extends StatelessWidget {
  final String code, label;
  final bool selected;
  final VoidCallback onTap;

  const _LangChip({required this.code, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.15) : AppColors.surfaceCard,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _BirthdatePage extends StatelessWidget {
  final DateTime? selectedDate;
  final WeekStart weekStart;
  final ValueChanged<DateTime?> onDateChanged;
  final ValueChanged<WeekStart> onWeekStartChanged;

  const _BirthdatePage({
    required this.selectedDate,
    required this.weekStart,
    required this.onDateChanged,
    required this.onWeekStartChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Text(
            l.onboardingTitle3,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
          SizedBox(height: 8.h),
          Text(
            l.onboardingSubtitle3,
            style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary, height: 1.5),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
          SizedBox(height: 32.h),

          // Birthdate selector
          _SectionLabel(label: l.enterBirthdate),
          SizedBox(height: 10.h),
          _DatePickerCard(
            selectedDate: selectedDate,
            hint: l.birthdateOptional,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime(1990, 1, 1),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) => _datePickerTheme(child),
              );
              if (picked != null) onDateChanged(picked);
            },
            onClear: selectedDate != null ? () => onDateChanged(null) : null,
          ),

          SizedBox(height: 28.h),

          // Week start
          _SectionLabel(label: l.weekStartsOn),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _SelectableCard(
                  label: l.monday,
                  selected: weekStart == WeekStart.monday,
                  onTap: () => onWeekStartChanged(WeekStart.monday),
                  icon: '🗓',
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _SelectableCard(
                  label: l.sunday,
                  selected: weekStart == WeekStart.sunday,
                  onTap: () => onWeekStartChanged(WeekStart.sunday),
                  icon: '📅',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _datePickerTheme(Widget? child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surfaceCard,
          onSurface: AppColors.textPrimary,
        ),
        dialogBackgroundColor: AppColors.surface,
      ),
      child: child!,
    );
  }
}

class _NotificationsPage extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _NotificationsPage({required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Text(
            '🔔  ' + (l.enableNotifications),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
          SizedBox(height: 8.h),
          Text(
            l.notificationDesc,
            style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary, height: 1.5),
          ).animate().fadeIn(delay: 100.ms),
          SizedBox(height: 36.h),
          _ToggleCard(
            label: l.enableNotifications,
            subtitle: l.notificationDesc,
            icon: '🔔',
            value: enabled,
            onChanged: onChanged,
          ),
          SizedBox(height: 20.h),
          // Preview notification card
          _NotificationPreview(),
        ],
      ),
    );
  }
}

class _NotificationPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayOfYear = AppDateUtils.dayOfYear(now);
    final totalDays = AppDateUtils.daysInYear(now.year);
    final daysLeft = AppDateUtils.daysLeftInYear(now);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text('◈', style: TextStyle(fontSize: 22.sp, color: Colors.white)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Life Calendar',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Today is day $dayOfYear of $totalDays. $daysLeft days left this year!',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0);
  }
}

// ---- Reusable Onboarding Widgets ----

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData icon;

  const _PrimaryButton({required this.label, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(icon, color: Colors.white, size: 18.sp),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _DatePickerCard extends StatelessWidget {
  final DateTime? selectedDate;
  final String hint;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DatePickerCard({
    required this.selectedDate,
    required this.hint,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selectedDate != null ? AppColors.primary.withOpacity(0.5) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_rounded, color: AppColors.primary, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                selectedDate != null
                    ? AppDateUtils.formatDate(selectedDate!, locale)
                    : hint,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: selectedDate != null ? AppColors.textPrimary : AppColors.textMuted,
                  fontWeight: selectedDate != null ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18.sp),
              )
            else
              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

class _SelectableCard extends StatelessWidget {
  final String label, icon;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableCard({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.12) : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(icon, style: TextStyle(fontSize: 24.sp)),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final String label, subtitle, icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(child: Text(icon, style: TextStyle(fontSize: 20.sp))),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(subtitle, style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
