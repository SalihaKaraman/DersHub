import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

// Core imports
import 'core/constants.dart';
import 'core/theme.dart';

// Service imports
import 'services/notification_service.dart';
import 'services/settings_service.dart';

// View imports
import 'firebase_options.dart';
import 'features/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Turkish date and time localizations
  await initializeDateFormatting('tr_TR', null);

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint(
      'Firebase has not been initialized. Running in Mock Database mode: $e',
    );
  }

  runApp(
    // Wrap application in ProviderScope to enable Riverpod
    const ProviderScope(child: DersHubApp()),
  );
}

class DersHubApp extends ConsumerStatefulWidget {
  const DersHubApp({super.key});

  @override
  ConsumerState<DersHubApp> createState() => _DersHubAppState();
}

class _DersHubAppState extends ConsumerState<DersHubApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize notifications only on mobile platforms
      if (!kIsWeb) {
        ref.read(notificationServiceProvider).initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr'), Locale('en')],
      home: const SplashScreen(),
    );
  }
}
