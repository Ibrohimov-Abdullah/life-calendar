// lib/presentation/screens/milestones/milestones_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/milestone.dart';
import '../../../data/providers/app_providers.dart';

class MilestonesScreen extends ConsumerWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final milestones = ref.watch(milestonesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, l, ref),
            Expanded(
              child: milestones.isEmpty
                  ? _buildEmpty(context, l, ref)
                  : _buildList(context, l, milestones, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      child: Row(
        children: [
          Text(
            l.milestones,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showAddDialog(context, ref, l),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(l.addMilestone, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations l, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🏁', style: TextStyle(fontSize: 64.sp)),
            SizedBox(height: 20.h),
            Text(
              l.noMilestones,
              style: GoogleFonts.spaceGrotesk(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            SizedBox(height: 8.h),
            Text(
              l.noMilestonesDesc,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            GestureDetector(
              onTap: () => _showAddDialog(context, ref, l),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14.r)),
                child: Text(l.addMilestone, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ).animate().fadeIn().scale(),
      ),
    );
  }

  Widget _buildList(BuildContext context, AppLocalizations l, List<Milestone> milestones, WidgetRef ref) {
    final now = DateTime.now();
    final past = milestones.where((m) => m.date.isBefore(now)).toList().reversed.toList();
    final upcoming = milestones.where((m) => !m.date.isBefore(now)).toList();
    final locale = Localizations.localeOf(context);

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      children: [
        if (upcoming.isNotEmpty) ...[
          _SectionHeader(label: l.upcoming),
          SizedBox(height: 10.h),
          ...upcoming.asMap().entries.map((e) => _MilestoneCard(
            milestone: e.value,
            locale: locale,
            l: l,
            onEdit: () => _showEditDialog(context, ref, l, e.value),
            onDelete: () => _confirmDelete(context, ref, l, e.value.id),
          ).animate(delay: Duration(milliseconds: e.key * 60)).fadeIn().slideX(begin: 0.1, end: 0)),
          SizedBox(height: 20.h),
        ],
        if (past.isNotEmpty) ...[
          _SectionHeader(label: l.past),
          SizedBox(height: 10.h),
          ...past.asMap().entries.map((e) => _MilestoneCard(
            milestone: e.value,
            locale: locale,
            l: l,
            isPast: true,
            onEdit: () => _showEditDialog(context, ref, l, e.value),
            onDelete: () => _confirmDelete(context, ref, l, e.value.id),
          ).animate(delay: Duration(milliseconds: e.key * 60)).fadeIn().slideX(begin: 0.1, end: 0)),
        ],
        SizedBox(height: 24.h),
      ],
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MilestoneFormSheet(
        l: l,
        onSave: (milestone) => ref.read(milestonesProvider.notifier).addMilestone(milestone),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, AppLocalizations l, Milestone milestone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MilestoneFormSheet(
        l: l,
        existing: milestone,
        onSave: (updated) => ref.read(milestonesProvider.notifier).updateMilestone(updated),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, AppLocalizations l, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: Text(l.delete, style: TextStyle(color: AppColors.textPrimary)),
        content: Text(l.deleteConfirm, style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          TextButton(
            onPressed: () {
              ref.read(milestonesProvider.notifier).deleteMilestone(id);
              Navigator.pop(context);
            },
            child: Text(l.delete, style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

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

class _MilestoneCard extends StatelessWidget {
  final Milestone milestone;
  final Locale locale;
  final AppLocalizations l;
  final bool isPast;
  final VoidCallback onEdit, onDelete;

  const _MilestoneCard({
    required this.milestone,
    required this.locale,
    required this.l,
    required this.onEdit,
    required this.onDelete,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    final daysAbs = milestone.daysFromNow.abs();
    final daysLabel = isPast
        ? l.daysAgo.replaceAll('{days}', '$daysAbs')
        : l.daysFromNow.replaceAll('{days}', '$daysAbs');

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: isPast
                  ? AppColors.primary.withOpacity(0.12)
                  : AppColors.accentOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: Text(milestone.emoji, style: TextStyle(fontSize: 24.sp)),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: isPast ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  AppDateUtils.formatDate(milestone.date, locale),
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
                ),
                SizedBox(height: 3.h),
                Text(
                  daysLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isPast ? AppColors.textMuted : AppColors.accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: onEdit,
                child: Icon(Icons.edit_outlined, color: AppColors.textMuted, size: 18.sp),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.delete_outline_rounded, color: AppColors.accent.withOpacity(0.7), size: 18.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MilestoneFormSheet extends StatefulWidget {
  final AppLocalizations l;
  final Milestone? existing;
  final Function(Milestone) onSave;

  const _MilestoneFormSheet({required this.l, required this.onSave, this.existing});

  @override
  State<_MilestoneFormSheet> createState() => _MilestoneFormSheetState();
}

class _MilestoneFormSheetState extends State<_MilestoneFormSheet> {
  late TextEditingController _titleController;
  late DateTime _date;
  late String _emoji;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _date = widget.existing?.date ?? DateTime.now();
    _emoji = widget.existing?.emoji ?? '⭐';
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2.r)),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            widget.existing != null ? l.edit : l.addMilestone,
            style: GoogleFonts.spaceGrotesk(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          SizedBox(height: 20.h),
          // Emoji selector row
          SizedBox(
            height: 44.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: kMilestoneEmojis.map((e) {
                final isSelected = e == _emoji;
                return GestureDetector(
                  onTap: () => setState(() => _emoji = e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.only(right: 8.w),
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surfaceCard,
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(child: Text(e, style: TextStyle(fontSize: 20.sp))),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16.h),
          // Title field
          TextField(
            controller: _titleController,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15.sp),
            decoration: InputDecoration(
              labelText: l.milestoneName,
              labelStyle: TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surfaceCard,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
          SizedBox(height: 12.h),
          // Date picker
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                builder: (context, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surfaceCard),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => _date = picked);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 16.sp),
                  SizedBox(width: 10.w),
                  Text(
                    AppDateUtils.formatDate(_date, Localizations.localeOf(context)),
                    style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18.sp),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
          // Save button
          GestureDetector(
            onTap: () {
              if (_titleController.text.trim().isEmpty) return;
              final milestone = widget.existing != null
                  ? widget.existing!.copyWith(title: _titleController.text.trim(), date: _date, emoji: _emoji)
                  : Milestone.create(title: _titleController.text.trim(), date: _date, emoji: _emoji);
              widget.onSave(milestone);
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14.r)),
              child: Text(l.save, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
