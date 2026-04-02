// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/utils/notification_service.dart';
import 'core/services/firebase_service.dart';
import 'data/providers/app_providers.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/milestones_repository.dart';
import 'data/repositories/goals_repository.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/home/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // System UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Init Hive
  await Hive.initFlutter();

  // Init repositories
  final settingsRepo = SettingsRepository();
  final milestonesRepo = MilestonesRepository();
  final goalsRepo = GoalsRepository();
  await Future.wait([
    settingsRepo.init(),
    milestonesRepo.init(),
    goalsRepo.init(),
  ]);

  // Init notifications
  await NotificationService().init();

  // Init Firebase (graceful fallback if not configured)
  await FirebaseService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        milestonesRepositoryProvider.overrideWithValue(milestonesRepo),
        goalsRepositoryProvider.overrideWithValue(goalsRepo),
      ],
      child: const LifeCalendarApp(),
    ),
  );
}

class LifeCalendarApp extends ConsumerStatefulWidget {
  const LifeCalendarApp({super.key});

  @override
  ConsumerState<LifeCalendarApp> createState() => _LifeCalendarAppState();
}

class _LifeCalendarAppState extends ConsumerState<LifeCalendarApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Record app open for streak tracking (after providers are ready)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsProvider.notifier).recordAppOpen();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(settingsProvider.notifier).recordAppOpen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/onboarding': (_) => const OnboardingScreen(),
          '/home': (_) => const AppShell(),
        },
      ),
    );
  }
}
