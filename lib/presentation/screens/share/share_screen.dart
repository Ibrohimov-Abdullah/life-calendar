// lib/presentation/screens/share/share_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/app_providers.dart';

enum _CardStyle { card, story }

class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isSharing = false;
  _CardStyle _cardStyle = _CardStyle.card;

  String _getDailyQuote(AppLocalizations l) {
    final quotes = l.locale.languageCode == 'ru'
        ? AppConstants.motivationalQuotesRu
        : AppConstants.motivationalQuotesEn;
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return quotes[dayOfYear % quotes.length];
  }

  Future<void> _shareCard(AppLocalizations l) async {
    setState(() => _isSharing = true);
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/life_calendar_share.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'My Life Calendar Progress 📊');
    } catch (e) {
      debugPrint('Share error: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final now = DateTime.now();
    final locale = Localizations.localeOf(context);

    final dayOfYear = AppDateUtils.dayOfYear(now);
    final totalDays = AppDateUtils.daysInYear(now.year);
    final daysLeft = AppDateUtils.daysLeftInYear(now);
    final yearProgress = AppDateUtils.yearProgress(now);
    final monthProgress = AppDateUtils.monthProgress(now);
    final weekProgress = AppDateUtils.weekProgress(now, startOnMonday: settings.weekStart.index == 0);
    final quote = _getDailyQuote(l);

    double? lifeProgress;
    int? ageYears;
    if (settings.birthDate != null) {
      lifeProgress = AppDateUtils.lifeProgress(settings.birthDate!, settings.lifeExpectancyYears);
      ageYears = AppDateUtils.ageInYears(settings.birthDate!);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.shareTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              // Style toggle
              _buildStyleToggle(l),
              SizedBox(height: 20.h),

              // Card preview
              Expanded(
                child: Center(
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: _cardStyle == _CardStyle.card
                        ? _SquareCard(
                            year: now.year,
                            dayOfYear: dayOfYear,
                            totalDays: totalDays,
                            daysLeft: daysLeft,
                            yearProgress: yearProgress,
                            monthProgress: monthProgress,
                            quote: quote,
                            monthName: AppDateUtils.monthName(now.month, locale),
                          )
                        : _StoryCard(
                            year: now.year,
                            dayOfYear: dayOfYear,
                            totalDays: totalDays,
                            daysLeft: daysLeft,
                            yearProgress: yearProgress,
                            monthProgress: monthProgress,
                            weekProgress: weekProgress,
                            quote: quote,
                            monthName: AppDateUtils.monthName(now.month, locale),
                            lifeProgress: lifeProgress,
                            ageYears: ageYears,
                          ),
                  ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
                ),
              ),
              SizedBox(height: 20.h),

              // Share button
              GestureDetector(
                onTap: _isSharing ? null : () => _shareCard(l),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 56.h,
                  decoration: BoxDecoration(
                    gradient: _isSharing ? null : AppColors.primaryGradient,
                    color: _isSharing ? AppColors.surfaceCard : null,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: _isSharing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 18.w, height: 18.w, child: const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
                              SizedBox(width: 10.w),
                              Text(l.saving, style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp)),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.ios_share_rounded, color: Colors.white, size: 18.sp),
                              SizedBox(width: 8.w),
                              Text(l.shareCard, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleToggle(AppLocalizations l) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: _StyleTab(
            label: l.cardStyleSquare,
            icon: Icons.crop_square_rounded,
            isSelected: _cardStyle == _CardStyle.card,
            onTap: () => setState(() => _cardStyle = _CardStyle.card),
          )),
          Expanded(child: _StyleTab(
            label: l.cardStyleStory,
            icon: Icons.stay_current_portrait_rounded,
            isSelected: _cardStyle == _CardStyle.story,
            onTap: () => setState(() => _cardStyle = _CardStyle.story),
          )),
        ],
      ),
    );
  }
}

class _StyleTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleTab({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14.sp, color: isSelected ? Colors.white : AppColors.textMuted),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Square Card (existing style) ----

class _SquareCard extends StatelessWidget {
  final int year, dayOfYear, totalDays, daysLeft;
  final double yearProgress, monthProgress;
  final String quote, monthName;

  const _SquareCard({
    required this.year,
    required this.dayOfYear,
    required this.totalDays,
    required this.daysLeft,
    required this.yearProgress,
    required this.monthProgress,
    required this.quote,
    required this.monthName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF12102A), Color(0xFF1A1535), Color(0xFF0F1020)],
        ),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(26.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(child: Text('◈', style: TextStyle(fontSize: 16.sp, color: Colors.white))),
                ),
                SizedBox(width: 8.w),
                Text('Life Calendar', style: GoogleFonts.spaceGrotesk(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ],
            ),
            SizedBox(height: 22.h),

            // Year %
            Text('Year $year', style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
            SizedBox(height: 3.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (yearProgress * 100).toStringAsFixed(1),
                  style: GoogleFonts.spaceGrotesk(fontSize: 52.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h, left: 2.w),
                  child: Text('%', style: GoogleFonts.spaceGrotesk(fontSize: 22.sp, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            _ProgressBar(progress: yearProgress, color: AppColors.primary),
            SizedBox(height: 7.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Day $dayOfYear of $totalDays', style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted)),
                Text('$daysLeft days left', style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted)),
              ],
            ),
            SizedBox(height: 18.h),
            Container(height: 1, color: AppColors.border),
            SizedBox(height: 14.h),

            // Month
            Text(monthName.toUpperCase(), style: TextStyle(fontSize: 9.sp, color: AppColors.textMuted, letterSpacing: 1)),
            SizedBox(height: 4.h),
            Text('${(monthProgress * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.spaceGrotesk(fontSize: 20.sp, fontWeight: FontWeight.w800, color: AppColors.accentGreen)),
            SizedBox(height: 6.h),
            _ProgressBar(progress: monthProgress, color: AppColors.accentGreen),

            SizedBox(height: 18.h),
            Text('"$quote"',
                style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, fontStyle: FontStyle.italic, height: 1.4)),
            SizedBox(height: 10.h),
            Text('lifecalendar.app', style: TextStyle(fontSize: 9.sp, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

// ---- Story Card (9:16 Instagram Story format) ----

class _StoryCard extends StatelessWidget {
  final int year, dayOfYear, totalDays, daysLeft;
  final double yearProgress, monthProgress, weekProgress;
  final String quote, monthName;
  final double? lifeProgress;
  final int? ageYears;

  const _StoryCard({
    required this.year,
    required this.dayOfYear,
    required this.totalDays,
    required this.daysLeft,
    required this.yearProgress,
    required this.monthProgress,
    required this.weekProgress,
    required this.quote,
    required this.monthName,
    this.lifeProgress,
    this.ageYears,
  });

  @override
  Widget build(BuildContext context) {
    // 9:16 aspect ratio for Instagram Stories
    final cardWidth = 220.w;
    final cardHeight = cardWidth * (16 / 9);

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D0B1F), Color(0xFF12102A), Color(0xFF0A0A14)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(7.r)),
                  child: Center(child: Text('◈', style: TextStyle(fontSize: 14.sp, color: Colors.white))),
                ),
                SizedBox(width: 7.w),
                Text('Life Calendar', style: GoogleFonts.spaceGrotesk(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ],
            ),
            SizedBox(height: 20.h),

            // Big year %
            Text('${year}', style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 2)),
            SizedBox(height: 2.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (yearProgress * 100).toStringAsFixed(1),
                  style: GoogleFonts.spaceGrotesk(fontSize: 44.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 6.h, left: 1.w),
                  child: Text('%', style: GoogleFonts.spaceGrotesk(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ],
            ),
            Text('of this year is gone', style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted)),
            SizedBox(height: 8.h),
            _ProgressBar(progress: yearProgress, color: AppColors.primary),
            SizedBox(height: 3.h),
            Text('Day $dayOfYear · $daysLeft days left', style: TextStyle(fontSize: 9.sp, color: AppColors.textMuted)),

            SizedBox(height: 16.h),
            Container(height: 1, color: AppColors.border.withOpacity(0.5)),
            SizedBox(height: 14.h),

            // Month + Week row
            Row(
              children: [
                Expanded(child: _MiniStatCard(
                  label: monthName,
                  percent: monthProgress,
                  color: AppColors.accentGreen,
                )),
                SizedBox(width: 8.w),
                Expanded(child: _MiniStatCard(
                  label: 'Week',
                  percent: weekProgress,
                  color: AppColors.accentOrange,
                )),
              ],
            ),

            if (lifeProgress != null) ...[
              SizedBox(height: 10.h),
              _MiniStatCard(
                label: 'Life ($ageYears yrs)',
                percent: lifeProgress!,
                color: AppColors.accentPink,
                fullWidth: true,
              ),
            ],

            const Spacer(),

            // Quote
            Text(
              '"$quote"',
              style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary, fontStyle: FontStyle.italic, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('lifecalendar.app', style: TextStyle(fontSize: 8.sp, color: AppColors.textMuted)),
                Text('📲 Download the app', style: TextStyle(fontSize: 8.sp, color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final Color color;

  const _ProgressBar({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5.h,
      decoration: BoxDecoration(color: AppColors.progressBackground, borderRadius: BorderRadius.circular(3.r)),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  final bool fullWidth;

  const _MiniStatCard({
    required this.label,
    required this.percent,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 7.sp, color: color.withOpacity(0.7), fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          SizedBox(height: 3.h),
          Text(
            '${(percent * 100).toStringAsFixed(0)}%',
            style: GoogleFonts.spaceGrotesk(fontSize: 16.sp, fontWeight: FontWeight.w800, color: color),
          ),
          SizedBox(height: 4.h),
          _ProgressBar(progress: percent, color: color),
        ],
      ),
    );
  }
}
