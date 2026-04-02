// lib/presentation/screens/home/app_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../home/home_screen.dart';
import '../life_calendar/life_calendar_screen.dart';
import '../milestones/milestones_screen.dart';
import '../goals/goals_screen.dart';
import '../settings/settings_screen.dart';

final _shellIndexProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(_shellIndexProvider);
    final l = AppLocalizations.of(context);

    final screens = [
      const HomeScreen(),
      const LifeCalendarScreen(),
      const MilestonesScreen(),
      const GoalsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: index,
        children: screens,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: index,
        onTap: (i) => ref.read(_shellIndexProvider.notifier).state = i,
        l: l,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppLocalizations l;

  const _BottomNav({required this.currentIndex, required this.onTap, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: l.home, index: 0, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.grid_view_rounded, label: l.lifeCalendar, index: 1, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.flag_rounded, label: l.milestones, index: 2, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.rocket_launch_rounded, label: l.goals, index: 3, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.settings_rounded, label: l.settings, index: 4, current: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final ValueChanged<int> onTap;

  const _NavItem({required this.icon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textMuted,
              size: 22.sp,
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
