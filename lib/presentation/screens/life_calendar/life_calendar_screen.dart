// lib/presentation/screens/life_calendar/life_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/providers/app_providers.dart';

class LifeCalendarScreen extends ConsumerWidget {
  const LifeCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, l),
            Expanded(
              child: settings.birthDate == null
                  ? _buildNoBirthdate(context, l, ref)
                  : _buildCalendar(
                  context, l, settings.birthDate!, settings.lifeExpectancyYears),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      child: Row(
        children: [
          Text(
            l.lifeCalendarTitle,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          _LegendDot(color: AppColors.weekLived, label: l.livedWeeks),
          SizedBox(width: 10.w),
          _LegendDot(color: AppColors.weekCurrent, label: l.currentWeek),
          SizedBox(width: 10.w),
          _LegendDot(color: AppColors.weekFuture, label: l.futureWeeks, bordered: true),
        ],
      ),
    );
  }

  Widget _buildNoBirthdate(BuildContext context, AppLocalizations l, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📅', style: TextStyle(fontSize: 64.sp)),
            SizedBox(height: 20.h),
            Text(
              l.noBirthdateSet,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              l.setBirthdate,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(1990, 1, 1),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (context, child) => Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: AppColors.primary,
                        surface: AppColors.surfaceCard,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  ref.read(settingsProvider.notifier).setBirthDate(picked);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Text(
                  l.setBirthdate,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ).animate().fadeIn().scale(),
      ),
    );
  }

  Widget _buildCalendar(
      BuildContext context,
      AppLocalizations l,
      DateTime birthDate,
      int lifeExpectancy,
      ) {
    final weeksLived = AppDateUtils.weeksLived(birthDate).clamp(0, 99999);
    final totalWeeks = AppDateUtils.totalLifeWeeks(lifeExpectancy);
    final progress = AppDateUtils.lifeProgress(birthDate, lifeExpectancy);
    final age = AppDateUtils.ageInYears(birthDate);
    final weeksLeft = (totalWeeks - weeksLived).clamp(0, 99999);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: _StatsBar(
            age: age,
            weeksLived: weeksLived,
            totalWeeks: totalWeeks,
            weeksLeft: weeksLeft,
            progress: progress,
            l: l,
          ),
        ),
        SizedBox(height: 12.h),
        Expanded(
          child: _WeeksGridPainter(
            weeksLived: weeksLived,
            totalWeeks: totalWeeks,
            lifeExpectancy: lifeExpectancy,
          ),
        ),
      ],
    );
  }
}

// ── CustomPainter grid — replaces 4000+ widgets with one canvas draw call ──

class _WeeksGridPainter extends StatelessWidget {
  final int weeksLived, totalWeeks, lifeExpectancy;

  const _WeeksGridPainter({
    required this.weeksLived,
    required this.totalWeeks,
    required this.lifeExpectancy,
  });

  @override
  Widget build(BuildContext context) {
    const weeksPerRow = 52;
    final rows = (totalWeeks / weeksPerRow).ceil();
    const labelWidth = 28.0;
    const horizontalPadding = 20.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final gridWidth =
            constraints.maxWidth - horizontalPadding * 2 - labelWidth;
        final cellSize = (gridWidth / weeksPerRow).clamp(4.0, 11.0);
        final gap = (cellSize * 0.2).clamp(0.8, 2.0);
        final rowHeight = cellSize + gap;
        final totalHeight = rows * rowHeight + 8;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: horizontalPadding, vertical: 4),
          child: SizedBox(
            width: constraints.maxWidth - horizontalPadding * 2,
            height: totalHeight,
            child: CustomPaint(
              painter: _LifeGridCanvasPainter(
                weeksLived: weeksLived,
                totalWeeks: totalWeeks,
                weeksPerRow: weeksPerRow,
                rows: rows,
                cellSize: cellSize,
                gap: gap,
                labelWidth: labelWidth,
                colorLived: AppColors.weekLived.withOpacity(0.85),
                colorCurrent: AppColors.weekCurrent,
                colorFuture: AppColors.weekFuture,
                colorBorder: AppColors.border.withOpacity(0.5),
                colorLabel: AppColors.textMuted,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LifeGridCanvasPainter extends CustomPainter {
  final int weeksLived, totalWeeks, weeksPerRow, rows;
  final double cellSize, gap, labelWidth;
  final Color colorLived, colorCurrent, colorFuture, colorBorder, colorLabel;

  const _LifeGridCanvasPainter({
    required this.weeksLived,
    required this.totalWeeks,
    required this.weeksPerRow,
    required this.rows,
    required this.cellSize,
    required this.gap,
    required this.labelWidth,
    required this.colorLived,
    required this.colorCurrent,
    required this.colorFuture,
    required this.colorBorder,
    required this.colorLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintLived = Paint()..color = colorLived;
    final paintCurrent = Paint()..color = colorCurrent;
    final paintFuture = Paint()..color = colorFuture;
    final paintBorder = Paint()
      ..color = colorBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    final paintGlow = Paint()
      ..color = colorCurrent.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final radius = Radius.circular(cellSize * 0.22);
    final rowHeight = cellSize + gap;

    final labelPainterCache = <int, TextPainter>{};

    for (int row = 0; row < rows; row++) {
      final y = row * rowHeight;

      // Year label every 5 years
      if (row % 5 == 0) {
        final tp = labelPainterCache.putIfAbsent(row, () {
          return TextPainter(
            text: TextSpan(
              text: '$row',
              style: TextStyle(
                color: colorLabel,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
        });
        tp.paint(canvas, Offset(0, y + (cellSize - tp.height) / 2));
      }

      for (int col = 0; col < weeksPerRow; col++) {
        final weekIndex = row * weeksPerRow + col;
        if (weekIndex >= totalWeeks) break;

        final x = labelWidth + col * (cellSize + gap);
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, cellSize, cellSize),
          radius,
        );

        if (weekIndex == weeksLived) {
          canvas.drawRRect(rect, paintGlow);
          canvas.drawRRect(rect, paintCurrent);
        } else if (weekIndex < weeksLived) {
          canvas.drawRRect(rect, paintLived);
        } else {
          canvas.drawRRect(rect, paintFuture);
          canvas.drawRRect(rect, paintBorder);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_LifeGridCanvasPainter old) =>
      old.weeksLived != weeksLived ||
          old.totalWeeks != totalWeeks ||
          old.cellSize != cellSize;
}

// ── Supporting widgets ──

class _StatsBar extends StatelessWidget {
  final int age, weeksLived, totalWeeks, weeksLeft;
  final double progress;
  final AppLocalizations l;

  const _StatsBar({
    required this.age,
    required this.weeksLived,
    required this.totalWeeks,
    required this.weeksLeft,
    required this.progress,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(value: '$age', label: l.age),
              _VerticalDivider(),
              _StatItem(value: '$weeksLived', label: l.livedWeeks),
              _VerticalDivider(),
              _StatItem(value: '$weeksLeft', label: l.futureWeeks),
              _VerticalDivider(),
              _StatItem(
                value: '${(progress * 100).toStringAsFixed(1)}%',
                label: l.lifeProgress,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: AppColors.progressBackground,
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 2.h),
        Text(label,
            style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted)),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28.h, color: AppColors.border);
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool bordered;

  const _LegendDot(
      {required this.color, required this.label, this.bordered = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: bordered ? Colors.transparent : color,
            border: bordered ? Border.all(color: AppColors.border) : null,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 4.w),
        Text(label,
            style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted)),
      ],
    );
  }
}