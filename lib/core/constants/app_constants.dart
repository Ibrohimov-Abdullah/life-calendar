// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  static const String appName = 'Life Calendar';
  static const String hiveBoxSettings = 'settings_box';
  static const String hiveBoxMilestones = 'milestones_box';
  static const String hiveBoxGoals = 'goals_box';
  static const String settingsKey = 'user_settings';

  static const int defaultLifeExpectancy = 80;
  static const int notificationId = 1001;
  static const String notificationChannelId = 'life_calendar_daily';
  static const String notificationChannelName = 'Daily Reminder';

  static const double maxLifeExpectancy = 120;
  static const double minLifeExpectancy = 40;

  // Motivational quotes for share card & home screen
  static const List<String> motivationalQuotesEn = [
    "The present moment is where life lives.",
    "Time is the most valuable thing a man can spend.",
    "Don't count the days, make the days count.",
    "Every moment is a fresh beginning.",
    "Life is not measured by the number of breaths we take.",
    "The purpose of life is to live it.",
    "Make each day your masterpiece.",
    "Yesterday is history, tomorrow is a mystery, today is a gift.",
    "Time flies over us, but leaves its shadow behind.",
    "The key is in not spending time, but in investing it.",
    "You only live once, but if you do it right, once is enough.",
    "In the end, it's not the years in your life that count.",
    "Life is what happens when you're busy making other plans.",
    "The secret of getting ahead is getting started.",
    "It does not matter how slowly you go, as long as you do not stop.",
  ];

  static const List<String> motivationalQuotesRu = [
    "Настоящий момент — это там, где живёт жизнь.",
    "Время — самое ценное, что может потратить человек.",
    "Не считай дни, а делай так, чтобы они считались.",
    "Каждый момент — это новое начало.",
    "Жизнь измеряется не количеством вдохов.",
    "Цель жизни — прожить её.",
    "Делай каждый день своим шедевром.",
    "Вчера — история, завтра — тайна, сегодня — подарок.",
    "Время летит над нами, но оставляет свою тень.",
    "Главное — не тратить время, а инвестировать его.",
    "Жизнь даётся один раз, и прожить её надо так...",
    "В конце считаются не годы жизни, а жизнь в годах.",
    "Жизнь — это то, что происходит, пока ты строишь планы.",
    "Секрет движения вперёд — в том, чтобы начать.",
    "Неважно, как медленно ты идёшь, главное — не останавливаться.",
  ];
}
