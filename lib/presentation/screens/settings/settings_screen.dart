// lib/presentation/screens/settings/settings_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/notification_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_sync_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../data/models/user_settings.dart';
import '../../../data/providers/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isSyncing = false;
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final locale = Localizations.localeOf(context);
    final authUserAsync = ref.watch(authUserProvider);
    final currentUser = authUserAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
                child: Text(
                  l.settingsTitle,
                  style: GoogleFonts.spaceGrotesk(fontSize: 22.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Personal
                  _SectionHeader(label: l.personalInfo),
                  SizedBox(height: 10.h),
                  _SettingsCard(children: [
                    _SettingsRow(
                      icon: '🎂',
                      label: l.birthdateLabel,
                      value: settings.birthDate != null
                          ? AppDateUtils.formatDate(settings.birthDate!, locale)
                          : l.notSet,
                      onTap: () => _pickBirthdate(context, settings),
                      trailing: settings.birthDate != null
                          ? GestureDetector(
                              onTap: () => ref.read(settingsProvider.notifier).setBirthDate(null),
                              child: Icon(Icons.close_rounded, color: AppColors.textMuted, size: 16.sp),
                            )
                          : null,
                    ),
                    _Divider(),
                    _LifeExpectancyRow(settings: settings, ref: ref, l: l),
                  ]),
                  SizedBox(height: 20.h),

                  // Account / Cloud Backup
                  if (FirebaseService.isAvailable) ...[
                    _SectionHeader(label: l.account),
                    SizedBox(height: 10.h),
                    _SettingsCard(children: [
                      if (currentUser == null)
                        _GoogleSignInButton(
                          l: l,
                          isLoading: _isSigningIn,
                          onTap: () => _signInWithGoogle(l),
                        )
                      else ...[
                        _UserRow(user: currentUser),
                        _Divider(),
                        _SyncRow(
                          l: l,
                          isSyncing: _isSyncing,
                          onTap: () => _syncToCloud(l),
                        ),
                        _Divider(),
                        _SettingsRow(
                          icon: '🚪',
                          label: l.signOut,
                          value: '',
                          onTap: () => _signOut(l),
                        ),
                      ],
                    ]),
                    SizedBox(height: 20.h),
                  ],

                  // General
                  _SectionHeader(label: l.general),
                  SizedBox(height: 10.h),
                  _SettingsCard(children: [
                    _SettingsRow(
                      icon: '🗓',
                      label: l.weekStartsOn,
                      value: settings.weekStart == WeekStart.monday ? l.monday : l.sunday,
                      onTap: () => _pickWeekStart(context, settings, l),
                    ),
                    _Divider(),
                    _SettingsRow(
                      icon: '🌐',
                      label: l.language,
                      value: settings.languageCode == 'ru' ? '🇷🇺 Русский' : '🇺🇸 English',
                      onTap: () => _pickLanguage(context, settings, l),
                    ),
                  ]),
                  SizedBox(height: 20.h),

                  // Notifications
                  _SectionHeader(label: l.notifications),
                  SizedBox(height: 10.h),
                  _SettingsCard(children: [
                    _SwitchRow(
                      icon: '🔔',
                      label: l.dailyReminder,
                      subtitle: l.notificationDesc,
                      value: settings.dailyReminderEnabled,
                      onChanged: (v) => _toggleNotification(context, v, settings),
                    ),
                    if (settings.dailyReminderEnabled) ...[
                      _Divider(),
                      _SettingsRow(
                        icon: '⏰',
                        label: l.reminderTime,
                        value: _formatTime(settings.reminderHour, settings.reminderMinute),
                        onTap: () => _pickTime(context, settings),
                      ),
                    ],
                  ]),
                  SizedBox(height: 20.h),

                  // About
                  _SectionHeader(label: l.about),
                  SizedBox(height: 10.h),
                  _SettingsCard(children: [
                    _SettingsRow(
                      icon: '◈',
                      label: l.appName,
                      value: '${l.version} 1.2.0',
                      onTap: () {},
                    ),
                  ]),
                  SizedBox(height: 32.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickBirthdate(BuildContext context, UserSettings settings) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: settings.birthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surfaceCard),
        ),
        child: child!,
      ),
    );
    if (picked != null) ref.read(settingsProvider.notifier).setBirthDate(picked);
  }

  void _pickWeekStart(BuildContext context, UserSettings settings, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.weekStartsOn, style: GoogleFonts.spaceGrotesk(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            SizedBox(height: 16.h),
            _PickerOption(
              label: l.monday,
              selected: settings.weekStart == WeekStart.monday,
              onTap: () {
                ref.read(settingsProvider.notifier).setWeekStart(WeekStart.monday);
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 10.h),
            _PickerOption(
              label: l.sunday,
              selected: settings.weekStart == WeekStart.sunday,
              onTap: () {
                ref.read(settingsProvider.notifier).setWeekStart(WeekStart.sunday);
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _pickLanguage(BuildContext context, UserSettings settings, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.language, style: GoogleFonts.spaceGrotesk(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            SizedBox(height: 16.h),
            _PickerOption(
              label: '🇺🇸  English',
              selected: settings.languageCode == 'en',
              onTap: () {
                ref.read(settingsProvider.notifier).setLanguage('en');
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 10.h),
            _PickerOption(
              label: '🇷🇺  Русский',
              selected: settings.languageCode == 'ru',
              onTap: () {
                ref.read(settingsProvider.notifier).setLanguage('ru');
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleNotification(BuildContext context, bool value, UserSettings settings) async {
    if (value) {
      final granted = await NotificationService().requestPermissions();
      if (!granted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Notification permission required'), backgroundColor: AppColors.surfaceCard),
          );
        }
        return;
      }
      await NotificationService().scheduleDailyNotification(
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
        title: 'Life Calendar',
        body: _buildNotificationBody(settings),
      );
    } else {
      await NotificationService().cancelNotification();
    }
    ref.read(settingsProvider.notifier).setDailyReminder(value);
  }

  Future<void> _pickTime(BuildContext context, UserSettings settings) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: settings.reminderTime,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surfaceCard),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      await ref.read(settingsProvider.notifier).setReminderTime(picked.hour, picked.minute);
      if (settings.dailyReminderEnabled) {
        await NotificationService().scheduleDailyNotification(
          hour: picked.hour,
          minute: picked.minute,
          title: 'Life Calendar',
          body: _buildNotificationBody(settings),
        );
      }
    }
  }

  String _buildNotificationBody(UserSettings settings) {
    final now = DateTime.now();
    final dayOfYear = AppDateUtils.dayOfYear(now);
    final totalDays = AppDateUtils.daysInYear(now.year);
    final daysLeft = AppDateUtils.daysLeftInYear(now);
    return settings.languageCode == 'ru'
        ? 'Сегодня день $dayOfYear из $totalDays. Осталось $daysLeft дней!'
        : 'Today is day $dayOfYear of $totalDays. $daysLeft days left this year!';
  }

  Future<void> _signInWithGoogle(AppLocalizations l) async {
    if (_isSigningIn) return;
    setState(() => _isSigningIn = true);
    try {
      await AuthService().signInWithGoogle();
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  Future<void> _signOut(AppLocalizations l) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: Text(l.signOut, style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Are you sure?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.signOut, style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await AuthService().signOut();
    }
  }

  Future<void> _syncToCloud(AppLocalizations l) async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      final milestones = ref.read(milestonesProvider);
      final goals = ref.read(goalsProvider);
      final settings = ref.read(settingsProvider);

      final result = await FirestoreSyncService().uploadAll(
        milestones: milestones,
        goals: goals,
        settings: settings,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.success ? l.syncSuccess : l.syncError),
            backgroundColor: result.success ? AppColors.accentGreen : AppColors.accent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }
}

// ---- Settings Widgets ----

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.2),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _SettingsRow extends StatelessWidget {
  final String icon, label, value;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsRow({required this.icon, required this.label, required this.value, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Text(icon, style: TextStyle(fontSize: 18.sp)),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ),
            if (trailing != null) ...[trailing!, SizedBox(width: 8.w)],
            if (value.isNotEmpty) ...[
              Text(value, style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted)),
              SizedBox(width: 4.w),
            ],
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 16.sp),
          ],
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final AppLocalizations l;
  final bool isLoading;
  final VoidCallback onTap;

  const _GoogleSignInButton({required this.l, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Text('☁️', style: TextStyle(fontSize: 18.sp)),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.cloudBackup, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text(l.notSignedIn, style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted)),
                ],
              ),
            ),
            if (isLoading)
              SizedBox(width: 18.w, height: 18.w, child: const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
            else
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  l.signInWithGoogle,
                  style: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final User user;
  const _UserRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (user.displayName?.isNotEmpty == true ? user.displayName![0] : user.email?[0] ?? '?').toUpperCase(),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user.displayName?.isNotEmpty == true)
                  Text(user.displayName!, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                if (user.email?.isNotEmpty == true)
                  Text(user.email!, style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text('Signed in', style: TextStyle(fontSize: 10.sp, color: AppColors.accentGreen, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SyncRow extends StatelessWidget {
  final AppLocalizations l;
  final bool isSyncing;
  final VoidCallback onTap;

  const _SyncRow({required this.l, required this.isSyncing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSyncing ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Text('☁️', style: TextStyle(fontSize: 18.sp)),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                isSyncing ? l.syncing : l.syncToCloud,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ),
            if (isSyncing)
              SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
            else
              Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String icon, label, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({required this.icon, required this.label, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 18.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(subtitle, style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 1, margin: EdgeInsets.only(left: 46.w), color: AppColors.border);
  }
}

class _PickerOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PickerOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.12) : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: selected ? AppColors.primary : AppColors.textPrimary)),
            const Spacer(),
            if (selected) Icon(Icons.check_rounded, color: AppColors.primary, size: 18.sp),
          ],
        ),
      ),
    );
  }
}

class _LifeExpectancyRow extends StatelessWidget {
  final UserSettings settings;
  final WidgetRef ref;
  final AppLocalizations l;

  const _LifeExpectancyRow({required this.settings, required this.ref, required this.l});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('⏳', style: TextStyle(fontSize: 18.sp)),
              SizedBox(width: 12.w),
              Expanded(child: Text(l.lifeExpectancyLabel, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
              Text('${settings.lifeExpectancyYears} ${l.years}', style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 12.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4.h,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.1),
            ),
            child: Slider(
              value: settings.lifeExpectancyYears.toDouble(),
              min: AppConstants.minLifeExpectancy,
              max: AppConstants.maxLifeExpectancy,
              divisions: (AppConstants.maxLifeExpectancy - AppConstants.minLifeExpectancy).toInt(),
              onChanged: (v) => ref.read(settingsProvider.notifier).setLifeExpectancy(v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${AppConstants.minLifeExpectancy.toInt()} ${l.years}', style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted)),
              Text('${AppConstants.maxLifeExpectancy.toInt()} ${l.years}', style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
