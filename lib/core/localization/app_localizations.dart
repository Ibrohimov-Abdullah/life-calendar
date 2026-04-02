// lib/core/localization/app_localizations.dart
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ru'),
  ];

  Map<String, String> get _strings {
    switch (locale.languageCode) {
      case 'ru':
        return _ruStrings;
      default:
        return _enStrings;
    }
  }

  String get(String key) => _strings[key] ?? key;

  // Convenience getters
  String get appName => get('app_name');
  String get settings => get('settings');
  String get home => get('home');
  String get lifeCalendar => get('life_calendar');
  String get milestones => get('milestones');
  String get goals => get('goals');

  // Onboarding
  String get onboardingTitle1 => get('onboarding_title1');
  String get onboardingSubtitle1 => get('onboarding_subtitle1');
  String get onboardingTitle2 => get('onboarding_title2');
  String get onboardingSubtitle2 => get('onboarding_subtitle2');
  String get onboardingTitle3 => get('onboarding_title3');
  String get onboardingSubtitle3 => get('onboarding_subtitle3');
  String get enterBirthdate => get('enter_birthdate');
  String get birthdateOptional => get('birthdate_optional');
  String get skip => get('skip');
  String get next => get('next');
  String get getStarted => get('get_started');
  String get selectBirthdate => get('select_birthdate');
  String get weekStartsOn => get('week_starts_on');
  String get monday => get('monday');
  String get sunday => get('sunday');
  String get enableNotifications => get('enable_notifications');
  String get notificationDesc => get('notification_desc');
  String get notificationTime => get('notification_time');
  String get language => get('language');

  // Dashboard
  String get yearProgress => get('year_progress');
  String get monthProgress => get('month_progress');
  String get weekProgress => get('week_progress');
  String get lifeProgress => get('life_progress');
  String get daysLeft => get('days_left');
  String get daysGone => get('days_gone');
  String get weeksLived => get('weeks_lived');
  String get weeksLeft => get('weeks_left');
  String get dayOf => get('day_of');
  String get weekOf => get('week_of');
  String get today => get('today');
  String get thisYear => get('this_year');
  String get thisMonth => get('this_month');
  String get thisWeek => get('this_week');
  String get inYear => get('in_year');

  // Streak
  String get streakDays => get('streak_days');
  String get streakLabel => get('streak_label');
  String get streakDesc => get('streak_desc');
  String get quoteOfDay => get('quote_of_day');

  // Life Calendar
  String get lifeCalendarTitle => get('life_calendar_title');
  String get livedWeeks => get('lived_weeks');
  String get currentWeek => get('current_week');
  String get futureWeeks => get('future_weeks');
  String get age => get('age');
  String get ageYears => get('age_years');
  String get lifeExpectancy => get('life_expectancy');
  String get years => get('years');
  String get weeks => get('weeks');
  String get totalWeeks => get('total_weeks');
  String get youAre => get('you_are');
  String get throughLife => get('through_life');
  String get noBirthdateSet => get('no_birthdate_set');
  String get setBirthdate => get('set_birthdate');
  String get yearLabel => get('year_label');

  // Settings
  String get settingsTitle => get('settings_title');
  String get personalInfo => get('personal_info');
  String get birthdateLabel => get('birthdate_label');
  String get notSet => get('not_set');
  String get lifeExpectancyLabel => get('life_expectancy_label');
  String get notifications => get('notifications');
  String get dailyReminder => get('daily_reminder');
  String get reminderTime => get('reminder_time');
  String get appearance => get('appearance');
  String get general => get('general');
  String get save => get('save');
  String get cancel => get('cancel');
  String get done => get('done');
  String get edit => get('edit');
  String get delete => get('delete');
  String get confirm => get('confirm');
  String get deleteConfirm => get('delete_confirm');
  String get version => get('version');
  String get about => get('about');

  // Account / Firebase
  String get account => get('account');
  String get signInWithGoogle => get('sign_in_google');
  String get signOut => get('sign_out');
  String get syncToCloud => get('sync_to_cloud');
  String get syncSuccess => get('sync_success');
  String get syncError => get('sync_error');
  String get notSignedIn => get('not_signed_in');
  String get cloudBackup => get('cloud_backup');
  String get cloudBackupDesc => get('cloud_backup_desc');
  String get syncing => get('syncing');

  // Milestones
  String get addMilestone => get('add_milestone');
  String get milestoneName => get('milestone_name');
  String get milestoneDate => get('milestone_date');
  String get milestoneEmoji => get('milestone_emoji');
  String get noMilestones => get('no_milestones');
  String get noMilestonesDesc => get('no_milestones_desc');
  String get past => get('past');
  String get upcoming => get('upcoming');
  String get daysAgo => get('days_ago');
  String get daysFromNow => get('days_from_now');

  // Goals / Bucket List
  String get goalsTitle => get('goals_title');
  String get bucketList => get('bucket_list');
  String get addGoal => get('add_goal');
  String get noGoals => get('no_goals');
  String get noGoalsDesc => get('no_goals_desc');
  String get goalName => get('goal_name');
  String get goalCategory => get('goal_category');
  String get goalStatus => get('goal_status');
  String get goalTargetDate => get('goal_target_date');
  String get goalDescription => get('goal_description');
  String get statusTodo => get('status_todo');
  String get statusInProgress => get('status_in_progress');
  String get statusCompleted => get('status_completed');
  String get markComplete => get('mark_complete');
  String get allCategories => get('all_categories');
  String get categoryHealth => get('category_health');
  String get categoryCareer => get('category_career');
  String get categoryTravel => get('category_travel');
  String get categoryLearning => get('category_learning');
  String get categoryRelationships => get('category_relationships');
  String get categoryFinance => get('category_finance');
  String get categoryPersonal => get('category_personal');
  String get completedGoals => get('completed_goals');
  String get activeGoals => get('active_goals');
  String get targetDate => get('target_date');
  String get daysLeft2 => get('days_left2');
  String get overdue => get('overdue');

  // Share
  String get shareTitle => get('share_title');
  String get shareCard => get('share_card');
  String get shareProgress => get('share_progress');
  String get saving => get('saving');
  String get saved => get('saved');
  String get cardStyle => get('card_style');
  String get cardStyleSquare => get('card_style_square');
  String get cardStyleStory => get('card_style_story');

  // Errors & misc
  String get errorGeneric => get('error_generic');
  String get permissionRequired => get('permission_required');

  static const Map<String, String> _enStrings = {
    'app_name': 'Life Calendar',
    'settings': 'Settings',
    'home': 'Home',
    'life_calendar': 'Life Grid',
    'milestones': 'Milestones',
    'goals': 'Goals',

    // Onboarding
    'onboarding_title1': 'Your Time, Visualized',
    'onboarding_subtitle1':
        'See exactly where you are in the year, month, week — and your entire life.',
    'onboarding_title2': 'Track Every Moment',
    'onboarding_subtitle2':
        'Watch your progress in real-time. Every day counts.',
    'onboarding_title3': 'Set Up Your Profile',
    'onboarding_subtitle3':
        'Optionally add your birthdate to unlock the Life Grid.',
    'enter_birthdate': 'Enter your birthdate',
    'birthdate_optional': 'Optional — unlocks Life Calendar',
    'skip': 'Skip',
    'next': 'Next',
    'get_started': 'Get Started',
    'select_birthdate': 'Select Birthdate',
    'week_starts_on': 'Week starts on',
    'monday': 'Monday',
    'sunday': 'Sunday',
    'enable_notifications': 'Daily Reminders',
    'notification_desc': 'Get a daily nudge about your progress',
    'notification_time': 'Reminder time',
    'language': 'Language',

    // Dashboard
    'year_progress': 'Year Progress',
    'month_progress': 'Month Progress',
    'week_progress': 'Week Progress',
    'life_progress': 'Life Progress',
    'days_left': 'days left',
    'days_gone': 'days gone',
    'weeks_lived': 'weeks lived',
    'weeks_left': 'weeks left',
    'day_of': 'Day {current} of {total}',
    'week_of': 'Week {current} of {total}',
    'today': 'Today',
    'this_year': 'This Year',
    'this_month': 'This Month',
    'this_week': 'This Week',
    'in_year': 'in {year}',

    // Streak
    'streak_days': '{streak} day streak 🔥',
    'streak_label': 'Day Streak',
    'streak_desc': 'Keep the habit going!',
    'quote_of_day': 'Quote of the Day',

    // Life Calendar
    'life_calendar_title': 'Life in Weeks',
    'lived_weeks': 'Lived',
    'current_week': 'Current',
    'future_weeks': 'Future',
    'age': 'Age',
    'age_years': '{age} years old',
    'life_expectancy': 'Life Expectancy',
    'years': 'years',
    'weeks': 'weeks',
    'total_weeks': 'Total weeks',
    'you_are': 'You are',
    'through_life': 'through your expected life',
    'no_birthdate_set': 'No birthdate set',
    'set_birthdate': 'Set Birthdate',
    'year_label': 'Age {age}',

    // Settings
    'settings_title': 'Settings',
    'personal_info': 'Personal',
    'birthdate_label': 'Birthdate',
    'not_set': 'Not set',
    'life_expectancy_label': 'Life Expectancy',
    'notifications': 'Notifications',
    'daily_reminder': 'Daily Reminder',
    'reminder_time': 'Reminder Time',
    'appearance': 'Appearance',
    'general': 'General',
    'save': 'Save',
    'cancel': 'Cancel',
    'done': 'Done',
    'edit': 'Edit',
    'delete': 'Delete',
    'confirm': 'Confirm',
    'delete_confirm': 'Are you sure you want to delete this?',
    'version': 'Version',
    'about': 'About',

    // Account / Firebase
    'account': 'Account',
    'sign_in_google': 'Sign in with Google',
    'sign_out': 'Sign Out',
    'sync_to_cloud': 'Sync to Cloud',
    'sync_success': 'Synced successfully!',
    'sync_error': 'Sync failed. Try again.',
    'not_signed_in': 'Sign in to back up your data',
    'cloud_backup': 'Cloud Backup',
    'cloud_backup_desc': 'Keep your data safe across devices',
    'syncing': 'Syncing...',

    // Milestones
    'add_milestone': 'Add Milestone',
    'milestone_name': 'Title',
    'milestone_date': 'Date',
    'milestone_emoji': 'Emoji',
    'no_milestones': 'No milestones yet',
    'no_milestones_desc': 'Add life events to mark them on your timeline.',
    'past': 'Past',
    'upcoming': 'Upcoming',
    'days_ago': '{days} days ago',
    'days_from_now': 'in {days} days',

    // Goals
    'goals_title': 'Bucket List',
    'bucket_list': 'Bucket List',
    'add_goal': 'Add Goal',
    'no_goals': 'No goals yet',
    'no_goals_desc': 'Add life goals and dreams to your bucket list.',
    'goal_name': 'Goal Title',
    'goal_category': 'Category',
    'goal_status': 'Status',
    'goal_target_date': 'Target Date (optional)',
    'goal_description': 'Description (optional)',
    'status_todo': 'To Do',
    'status_in_progress': 'In Progress',
    'status_completed': 'Completed',
    'mark_complete': 'Mark as Done',
    'all_categories': 'All',
    'category_health': 'Health',
    'category_career': 'Career',
    'category_travel': 'Travel',
    'category_learning': 'Learning',
    'category_relationships': 'Relationships',
    'category_finance': 'Finance',
    'category_personal': 'Personal',
    'completed_goals': 'Completed',
    'active_goals': 'Active',
    'target_date': 'Target',
    'days_left2': '{days} days left',
    'overdue': 'Overdue',

    // Share
    'share_title': 'Share Your Progress',
    'share_card': 'Share',
    'share_progress': 'Share Progress',
    'saving': 'Saving...',
    'saved': 'Saved!',
    'card_style': 'Card Style',
    'card_style_square': 'Card',
    'card_style_story': 'Story',

    // Errors
    'error_generic': 'Something went wrong',
    'permission_required': 'Permission required',
  };

  static const Map<String, String> _ruStrings = {
    'app_name': 'Календарь Жизни',
    'settings': 'Настройки',
    'home': 'Главная',
    'life_calendar': 'Сетка жизни',
    'milestones': 'Вехи',
    'goals': 'Цели',

    // Onboarding
    'onboarding_title1': 'Ваше время наглядно',
    'onboarding_subtitle1':
        'Видите точно, где вы находитесь в году, месяце, неделе — и во всей жизни.',
    'onboarding_title2': 'Отслеживайте каждый момент',
    'onboarding_subtitle2':
        'Наблюдайте за своим прогрессом в режиме реального времени.',
    'onboarding_title3': 'Настройте профиль',
    'onboarding_subtitle3':
        'Добавьте дату рождения, чтобы разблокировать Сетку Жизни.',
    'enter_birthdate': 'Введите дату рождения',
    'birthdate_optional': 'Необязательно — разблокирует Сетку Жизни',
    'skip': 'Пропустить',
    'next': 'Далее',
    'get_started': 'Начать',
    'select_birthdate': 'Выбрать дату рождения',
    'week_starts_on': 'Неделя начинается с',
    'monday': 'Понедельника',
    'sunday': 'Воскресенья',
    'enable_notifications': 'Ежедневные напоминания',
    'notification_desc': 'Получайте ежедневное уведомление о вашем прогрессе',
    'notification_time': 'Время напоминания',
    'language': 'Язык',

    // Dashboard
    'year_progress': 'Прогресс года',
    'month_progress': 'Прогресс месяца',
    'week_progress': 'Прогресс недели',
    'life_progress': 'Прогресс жизни',
    'days_left': 'дней осталось',
    'days_gone': 'дней прошло',
    'weeks_lived': 'недель прожито',
    'weeks_left': 'недель осталось',
    'day_of': 'День {current} из {total}',
    'week_of': 'Неделя {current} из {total}',
    'today': 'Сегодня',
    'this_year': 'Этот год',
    'this_month': 'Этот месяц',
    'this_week': 'Эта неделя',
    'in_year': 'в {year}',

    // Streak
    'streak_days': 'Серия {streak} дней 🔥',
    'streak_label': 'Дней подряд',
    'streak_desc': 'Продолжай в том же духе!',
    'quote_of_day': 'Цитата дня',

    // Life Calendar
    'life_calendar_title': 'Жизнь в неделях',
    'lived_weeks': 'Прожито',
    'current_week': 'Сейчас',
    'future_weeks': 'Впереди',
    'age': 'Возраст',
    'age_years': '{age} лет',
    'life_expectancy': 'Ожидаемая продолжительность',
    'years': 'лет',
    'weeks': 'недель',
    'total_weeks': 'Всего недель',
    'you_are': 'Вы прожили',
    'through_life': 'ожидаемой жизни',
    'no_birthdate_set': 'Дата рождения не указана',
    'set_birthdate': 'Указать дату',
    'year_label': 'Возраст {age}',

    // Settings
    'settings_title': 'Настройки',
    'personal_info': 'Личное',
    'birthdate_label': 'Дата рождения',
    'not_set': 'Не указано',
    'life_expectancy_label': 'Ожидаемая продолжительность жизни',
    'notifications': 'Уведомления',
    'daily_reminder': 'Ежедневное напоминание',
    'reminder_time': 'Время напоминания',
    'appearance': 'Внешний вид',
    'general': 'Общее',
    'save': 'Сохранить',
    'cancel': 'Отмена',
    'done': 'Готово',
    'edit': 'Изменить',
    'delete': 'Удалить',
    'confirm': 'Подтвердить',
    'delete_confirm': 'Вы уверены, что хотите удалить это?',
    'version': 'Версия',
    'about': 'О приложении',

    // Account / Firebase
    'account': 'Аккаунт',
    'sign_in_google': 'Войти через Google',
    'sign_out': 'Выйти',
    'sync_to_cloud': 'Синхронизировать',
    'sync_success': 'Синхронизировано!',
    'sync_error': 'Ошибка синхронизации.',
    'not_signed_in': 'Войдите, чтобы сохранить данные',
    'cloud_backup': 'Облачный бэкап',
    'cloud_backup_desc': 'Ваши данные в безопасности на всех устройствах',
    'syncing': 'Синхронизация...',

    // Milestones
    'add_milestone': 'Добавить веху',
    'milestone_name': 'Название',
    'milestone_date': 'Дата',
    'milestone_emoji': 'Эмодзи',
    'no_milestones': 'Пока нет вех',
    'no_milestones_desc':
        'Добавьте важные события, чтобы отметить их на временной шкале.',
    'past': 'Прошлые',
    'upcoming': 'Предстоящие',
    'days_ago': '{days} дней назад',
    'days_from_now': 'через {days} дней',

    // Goals
    'goals_title': 'Список желаний',
    'bucket_list': 'Список желаний',
    'add_goal': 'Добавить цель',
    'no_goals': 'Целей пока нет',
    'no_goals_desc': 'Добавьте жизненные цели в свой список желаний.',
    'goal_name': 'Название цели',
    'goal_category': 'Категория',
    'goal_status': 'Статус',
    'goal_target_date': 'Целевая дата (необязательно)',
    'goal_description': 'Описание (необязательно)',
    'status_todo': 'Запланировано',
    'status_in_progress': 'В процессе',
    'status_completed': 'Выполнено',
    'mark_complete': 'Отметить как выполненное',
    'all_categories': 'Все',
    'category_health': 'Здоровье',
    'category_career': 'Карьера',
    'category_travel': 'Путешествия',
    'category_learning': 'Обучение',
    'category_relationships': 'Отношения',
    'category_finance': 'Финансы',
    'category_personal': 'Личное',
    'completed_goals': 'Выполненные',
    'active_goals': 'Активные',
    'target_date': 'Срок',
    'days_left2': 'Осталось {days} дней',
    'overdue': 'Просрочено',

    // Share
    'share_title': 'Поделиться прогрессом',
    'share_card': 'Поделиться',
    'share_progress': 'Поделиться',
    'saving': 'Сохранение...',
    'saved': 'Сохранено!',
    'card_style': 'Стиль карточки',
    'card_style_square': 'Карточка',
    'card_style_story': 'История',

    // Errors
    'error_generic': 'Что-то пошло не так',
    'permission_required': 'Необходимо разрешение',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ru'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
