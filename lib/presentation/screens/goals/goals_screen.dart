// lib/presentation/screens/goals/goals_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/goal.dart';
import '../../../data/providers/app_providers.dart';

// Filter state provider
final _goalFilterProvider = StateProvider<GoalCategory?>((ref) => null);

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final goals = ref.watch(goalsProvider);
    final filter = ref.watch(_goalFilterProvider);

    final filtered = filter == null
        ? goals
        : goals.where((g) => g.category == filter).toList();

    final active = filtered.where((g) => !g.isCompleted).toList();
    final completed = filtered.where((g) => g.isCompleted).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, l, ref),
            _buildCategoryFilter(context, l, ref),
            Expanded(
              child: goals.isEmpty
                  ? _buildEmpty(context, l, ref)
                  : filtered.isEmpty
                      ? _buildFilterEmpty(context, l)
                      : _buildList(context, l, active, completed, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final completedCount = goals.where((g) => g.isCompleted).length;
    final total = goals.length;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.bucketList,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (total > 0)
                Text(
                  '$completedCount / $total completed',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
                ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showAddSheet(context, ref, l),
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
                  Text(l.addGoal, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildCategoryFilter(BuildContext context, AppLocalizations l, WidgetRef ref) {
    final filter = ref.watch(_goalFilterProvider);

    final categories = [
      (null, l.allCategories, '✨'),
      (GoalCategory.health, l.categoryHealth, '💪'),
      (GoalCategory.career, l.categoryCareer, '💼'),
      (GoalCategory.travel, l.categoryTravel, '✈️'),
      (GoalCategory.learning, l.categoryLearning, '📚'),
      (GoalCategory.relationships, l.categoryRelationships, '❤️'),
      (GoalCategory.finance, l.categoryFinance, '💰'),
      (GoalCategory.personal, l.categoryPersonal, '⭐'),
    ];

    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final (cat, label, emoji) = categories[i];
          final isSelected = filter == cat;
          return GestureDetector(
            onTap: () => ref.read(_goalFilterProvider.notifier).state = cat,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 0 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: TextStyle(fontSize: 12.sp)),
                  SizedBox(width: 4.w),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
            Text('🎯', style: TextStyle(fontSize: 64.sp)),
            SizedBox(height: 20.h),
            Text(
              l.noGoals,
              style: GoogleFonts.spaceGrotesk(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            SizedBox(height: 8.h),
            Text(
              l.noGoalsDesc,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            GestureDetector(
              onTap: () => _showAddSheet(context, ref, l),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14.r)),
                child: Text(l.addGoal, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ).animate().fadeIn().scale(),
      ),
    );
  }

  Widget _buildFilterEmpty(BuildContext context, AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🔍', style: TextStyle(fontSize: 48.sp)),
          SizedBox(height: 16.h),
          Text(
            'No goals in this category',
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, AppLocalizations l, List<Goal> active, List<Goal> completed, WidgetRef ref) {
    final locale = Localizations.localeOf(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      children: [
        if (active.isNotEmpty) ...[
          _SectionLabel(label: l.activeGoals),
          SizedBox(height: 10.h),
          ...active.asMap().entries.map((e) => _GoalCard(
            goal: e.value,
            locale: locale,
            l: l,
            onTap: () => _showEditSheet(context, ref, l, e.value),
            onToggle: () => ref.read(goalsProvider.notifier).toggleComplete(e.value),
            onDelete: () => _confirmDelete(context, ref, l, e.value.id),
          ).animate(delay: Duration(milliseconds: e.key * 50)).fadeIn().slideX(begin: 0.1, end: 0)),
          SizedBox(height: 20.h),
        ],
        if (completed.isNotEmpty) ...[
          _SectionLabel(label: l.completedGoals),
          SizedBox(height: 10.h),
          ...completed.asMap().entries.map((e) => _GoalCard(
            goal: e.value,
            locale: locale,
            l: l,
            isCompleted: true,
            onTap: () => _showEditSheet(context, ref, l, e.value),
            onToggle: () => ref.read(goalsProvider.notifier).toggleComplete(e.value),
            onDelete: () => _confirmDelete(context, ref, l, e.value.id),
          ).animate(delay: Duration(milliseconds: e.key * 50)).fadeIn()),
        ],
      ],
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalFormSheet(
        l: l,
        onSave: (goal) => ref.read(goalsProvider.notifier).addGoal(goal),
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, AppLocalizations l, Goal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalFormSheet(
        l: l,
        existing: goal,
        onSave: (updated) => ref.read(goalsProvider.notifier).updateGoal(updated),
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
              ref.read(goalsProvider.notifier).deleteGoal(id);
              Navigator.pop(context);
            },
            child: Text(l.delete, style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

// ---- Inner Widgets ----

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.2),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final Locale locale;
  final AppLocalizations l;
  final bool isCompleted;
  final VoidCallback onTap, onToggle, onDelete;

  const _GoalCard({
    required this.goal,
    required this.locale,
    required this.l,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final langCode = locale.languageCode;
    final catLabel = langCode == 'ru' ? goal.category.labelRu : goal.category.labelEn;

    String? dateLabel;
    if (goal.targetDate != null && !isCompleted) {
      final days = goal.daysUntilTarget!;
      if (days < 0) {
        dateLabel = l.overdue;
      } else {
        dateLabel = l.daysLeft2.replaceAll('{days}', '$days');
      }
    } else if (isCompleted && goal.completedAt != null) {
      dateLabel = AppDateUtils.formatDate(goal.completedAt!, locale);
    }

    final isOverdue = goal.targetDate != null &&
        !isCompleted &&
        goal.daysUntilTarget! < 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.surfaceCard.withOpacity(0.5)
              : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isCompleted ? AppColors.border.withOpacity(0.5) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // Emoji + check overlay
            Stack(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.accentGreen.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: Text(
                      goal.emoji,
                      style: TextStyle(
                        fontSize: 22.sp,
                        color: isCompleted ? null : null,
                      ),
                    ),
                  ),
                ),
                if (isCompleted)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: const BoxDecoration(
                        color: AppColors.accentGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded, color: Colors.white, size: 10.sp),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '${goal.category.emoji} $catLabel',
                          style: TextStyle(fontSize: 10.sp, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (dateLabel != null) ...[
                        SizedBox(width: 6.w),
                        Text(
                          dateLabel,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: isOverdue ? AppColors.accent : AppColors.textMuted,
                            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (goal.description != null && goal.description!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      goal.description!,
                      style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.accentGreen.withOpacity(0.15)
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isCompleted ? AppColors.accentGreen : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: isCompleted
                        ? Icon(Icons.check_rounded, color: AppColors.accentGreen, size: 14.sp)
                        : null,
                  ),
                ),
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.delete_outline_rounded, color: AppColors.accent.withOpacity(0.6), size: 16.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Goal Form Bottom Sheet ----

class _GoalFormSheet extends StatefulWidget {
  final AppLocalizations l;
  final Goal? existing;
  final Function(Goal) onSave;

  const _GoalFormSheet({required this.l, required this.onSave, this.existing});

  @override
  State<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends State<_GoalFormSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _emoji;
  late GoalCategory _category;
  late GoalStatus _status;
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    _titleController = TextEditingController(text: g?.title ?? '');
    _descController = TextEditingController(text: g?.description ?? '');
    _emoji = g?.emoji ?? '🎯';
    _category = g?.category ?? GoalCategory.personal;
    _status = g?.status ?? GoalStatus.todo;
    _targetDate = g?.targetDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final locale = Localizations.localeOf(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: SingleChildScrollView(
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
              widget.existing != null ? l.edit : l.addGoal,
              style: GoogleFonts.spaceGrotesk(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            SizedBox(height: 16.h),

            // Emoji row
            SizedBox(
              height: 44.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: kGoalEmojis.map((e) {
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
            SizedBox(height: 14.h),

            // Title
            _buildTextField(_titleController, l.goalName),
            SizedBox(height: 10.h),

            // Description
            _buildTextField(_descController, l.goalDescription, maxLines: 2),
            SizedBox(height: 14.h),

            // Category
            Text(l.goalCategory, style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: GoalCategory.values.map((cat) {
                final isSelected = cat == _category;
                final label = locale.languageCode == 'ru' ? cat.labelRu : cat.labelEn;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
                    ),
                    child: Text(
                      '${cat.emoji} $label',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 14.h),

            // Status
            Text(l.goalStatus, style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Row(
              children: GoalStatus.values.map((s) {
                final isSelected = s == _status;
                final label = s == GoalStatus.todo
                    ? l.statusTodo
                    : s == GoalStatus.inProgress
                        ? l.statusInProgress
                        : l.statusCompleted;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _status = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.only(right: s != GoalStatus.completed ? 6.w : 0),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isSelected ? AppColors.primary : AppColors.textMuted,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 14.h),

            // Target date
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  builder: (context, child) => Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surfaceCard),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _targetDate = picked);
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
                    Expanded(
                      child: Text(
                        _targetDate != null
                            ? AppDateUtils.formatDate(_targetDate!, locale)
                            : l.goalTargetDate,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: _targetDate != null ? AppColors.textPrimary : AppColors.textMuted,
                        ),
                      ),
                    ),
                    if (_targetDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _targetDate = null),
                        child: Icon(Icons.close_rounded, color: AppColors.textMuted, size: 16.sp),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Save button
            GestureDetector(
              onTap: () {
                if (_titleController.text.trim().isEmpty) return;
                final desc = _descController.text.trim();
                final goal = widget.existing != null
                    ? widget.existing!.copyWith(
                        title: _titleController.text.trim(),
                        emoji: _emoji,
                        description: desc.isEmpty ? null : desc,
                        clearDescription: desc.isEmpty,
                        category: _category,
                        status: _status,
                        targetDate: _targetDate,
                        clearTargetDate: _targetDate == null,
                        completedAt: _status == GoalStatus.completed && widget.existing!.completedAt == null
                            ? DateTime.now()
                            : null,
                      )
                    : Goal.create(
                        title: _titleController.text.trim(),
                        emoji: _emoji,
                        description: desc.isEmpty ? null : desc,
                        category: _category,
                        status: _status,
                        targetDate: _targetDate,
                      );
                widget.onSave(goal);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Text(
                  l.save,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
        filled: true,
        fillColor: AppColors.surfaceCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
