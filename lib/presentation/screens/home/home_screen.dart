// lib/presentation/screens/home/home_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/app_providers.dart';
import '../share/share_screen.dart';
import '../../widgets/common/animated_progress_bar.dart';
import '../../widgets/common/circular_progress_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final now = DateTime.now();
    final startOnMonday = settings.weekStart.index == 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, l, now)),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Streak card (only when streak >= 2)
                  if (settings.streak >= 2) ...[
                    _buildStreakCard(context, l, settings.streak),
                    SizedBox(height: 14.h),
                  ],
                  _buildYearCard(context, l, now),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(child: _buildMonthCard(context, l, now)),
                      SizedBox(width: 14.w),
                      Expanded(child: _buildWeekCard(context, l, now, startOnMonday)),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  if (settings.birthDate != null)
                    _buildLifeCard(context, l, settings.birthDate!, settings.lifeExpectancyYears),
                  SizedBox(height: 14.h),
                  _buildStatsRow(context, l, now, startOnMonday),
                  SizedBox(height: 14.h),
                  _buildQuoteCard(context, l),
                  SizedBox(height: 24.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l, DateTime now) {
    final locale = Localizations.localeOf(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.today,
                style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 2.h),
              Text(
                AppDateUtils.formatDate(now, locale),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ShareScreen()),
            ),
            child: Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(Icons.ios_share_rounded, color: AppColors.textSecondary, size: 18.sp),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildStreakCard(BuildContext context, AppLocalizations l, int streak) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF8C00), Color(0xFFFF5733)],
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8C00).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Text('🔥', style: TextStyle(fontSize: 32.sp)),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.streakDays.replaceAll('{streak}', '$streak'),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                l.streakDesc,
                style: TextStyle(fontSize: 12.sp, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 50.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildYearCard(BuildContext context, AppLocalizations l, DateTime now) {
    final dayOfYear = AppDateUtils.dayOfYear(now);
    final totalDays = AppDateUtils.daysInYear(now.year);
    final daysLeft = AppDateUtils.daysLeftInYear(now);
    final progress = AppDateUtils.yearProgress(now);
    final percent = (progress * 100);

    return _GradientCard(
      gradient: AppColors.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l.thisYear} ${now.year}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          percent.toStringAsFixed(1),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 52.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h, left: 2.w),
                          child: Text('%',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CircularProgressWidget(
                progress: progress,
                size: 72.w,
                strokeWidth: 6.w,
                progressColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$daysLeft',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    Text(
                      l.daysLeft,
                      style: TextStyle(fontSize: 8.sp, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          AnimatedProgressBar(
            progress: progress,
            backgroundColor: Colors.white.withOpacity(0.2),
            progressColor: Colors.white,
            height: 6.h,
            borderRadius: 3.r,
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day $dayOfYear of $totalDays',
                style: TextStyle(fontSize: 12.sp, color: Colors.white70),
              ),
              Text(
                '$daysLeft ${l.daysLeft}',
                style: TextStyle(fontSize: 12.sp, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildMonthCard(BuildContext context, AppLocalizations l, DateTime now) {
    final locale = Localizations.localeOf(context);
    final daysInMonth = AppDateUtils.daysInMonth(now.year, now.month);
    final daysLeft = AppDateUtils.daysLeftInMonth(now);
    final progress = AppDateUtils.monthProgress(now);

    return _StandardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardLabel(label: l.thisMonth),
          SizedBox(height: 8.h),
          Text(
            AppDateUtils.monthName(now.month, locale),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          _PercentDisplay(percent: progress * 100, color: AppColors.accentGreen),
          SizedBox(height: 12.h),
          AnimatedProgressBar(
            progress: progress,
            backgroundColor: AppColors.progressBackground,
            progressColor: AppColors.accentGreen,
            height: 5.h,
          ),
          SizedBox(height: 8.h),
          Text(
            'Day ${now.day} of $daysInMonth',
            style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildWeekCard(BuildContext context, AppLocalizations l, DateTime now, bool startOnMonday) {
    final weekNum = AppDateUtils.weekOfYear(now, startOnMonday: startOnMonday);
    final totalWeeks = AppDateUtils.weeksInYear(now.year, startOnMonday: startOnMonday);
    final daysLeft = AppDateUtils.daysLeftInWeek(now, startOnMonday: startOnMonday);
    final progress = AppDateUtils.weekProgress(now, startOnMonday: startOnMonday);

    return _StandardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardLabel(label: l.thisWeek),
          SizedBox(height: 8.h),
          Text(
            'Week $weekNum',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          _PercentDisplay(percent: progress * 100, color: AppColors.accentOrange),
          SizedBox(height: 12.h),
          AnimatedProgressBar(
            progress: progress,
            backgroundColor: AppColors.progressBackground,
            progressColor: AppColors.accentOrange,
            height: 5.h,
          ),
          SizedBox(height: 8.h),
          Text(
            '$daysLeft ${l.daysLeft}',
            style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildLifeCard(BuildContext context, AppLocalizations l, DateTime birthDate, int lifeExpectancy) {
    final weeksLived = AppDateUtils.weeksLived(birthDate);
    final totalWeeks = AppDateUtils.totalLifeWeeks(lifeExpectancy);
    final weeksLeft = totalWeeks - weeksLived;
    final progress = AppDateUtils.lifeProgress(birthDate, lifeExpectancy);
    final age = AppDateUtils.ageInYears(birthDate);

    return _GradientCard(
      gradient: AppColors.accentGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.lifeProgress,
                      style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          (progress * 100).toStringAsFixed(1),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 42.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 6.h, left: 2.w),
                          child: Text('%', style: GoogleFonts.spaceGrotesk(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white70)),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '$age ${l.years} old',
                      style: TextStyle(fontSize: 13.sp, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatBadge(value: '$weeksLived', label: l.weeksLived, color: Colors.white),
                  SizedBox(height: 8.h),
                  _StatBadge(value: '$weeksLeft', label: l.weeksLeft, color: Colors.white70),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          AnimatedProgressBar(
            progress: progress,
            backgroundColor: Colors.white.withOpacity(0.2),
            progressColor: Colors.white,
            height: 6.h,
          ),
          SizedBox(height: 8.h),
          Text(
            '$weeksLived of $totalWeeks ${l.weeks}',
            style: TextStyle(fontSize: 12.sp, color: Colors.white70),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatsRow(BuildContext context, AppLocalizations l, DateTime now, bool startOnMonday) {
    final dayOfYear = AppDateUtils.dayOfYear(now);
    final totalDays = AppDateUtils.daysInYear(now.year);
    final weekNum = AppDateUtils.weekOfYear(now, startOnMonday: startOnMonday);
    final totalWeeks = AppDateUtils.weeksInYear(now.year, startOnMonday: startOnMonday);

    return Row(
      children: [
        Expanded(child: _MiniStat(
          icon: '📅',
          value: '$dayOfYear/$totalDays',
          label: l.thisYear,
        )),
        SizedBox(width: 10.w),
        Expanded(child: _MiniStat(
          icon: '📆',
          value: '${now.day}/${AppDateUtils.daysInMonth(now.year, now.month)}',
          label: l.thisMonth,
        )),
        SizedBox(width: 10.w),
        Expanded(child: _MiniStat(
          icon: '🗓',
          value: '$weekNum/$totalWeeks',
          label: l.thisWeek,
        )),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildQuoteCard(BuildContext context, AppLocalizations l) {
    final quotes = l.locale.languageCode == 'ru'
        ? AppConstants.motivationalQuotesRu
        : AppConstants.motivationalQuotesEn;
    // Pick a quote deterministically by day of year so it changes daily
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final quote = quotes[dayOfYear % quotes.length];

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('💭', style: TextStyle(fontSize: 14.sp)),
              SizedBox(width: 6.w),
              Text(
                l.quoteOfDay,
                style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '"$quote"',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}

// ---- Card Widgets ----

class _GradientCard extends StatelessWidget {
  final LinearGradient gradient;
  final Widget child;

  const _GradientCard({required this.gradient, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StandardCard extends StatelessWidget {
  final Widget child;
  const _StandardCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _CardLabel extends StatelessWidget {
  final String label;
  const _CardLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 1,
      ),
    );
  }
}

class _PercentDisplay extends StatelessWidget {
  final double percent;
  final Color color;
  const _PercentDisplay({required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          percent.toStringAsFixed(1),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 30.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 4.h, left: 1.w),
          child: Text(
            '%',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatBadge({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 18.sp, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: TextStyle(fontSize: 10.sp, color: color.withOpacity(0.7))),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String icon, value, label;
  const _MiniStat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(icon, style: TextStyle(fontSize: 20.sp)),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          SizedBox(height: 2.h),
          Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
