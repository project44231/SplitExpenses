import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'services/local_storage_service.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  final localStorage = LocalStorageService();
  await localStorage.initialize();

  // Initialize Firebase (with error handling for hot restart)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized (hot restart), ignore error
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        // Provide local storage service
        localStorageServiceProvider.overrideWithValue(localStorage),
      ],
      child: const SplitExpensesApp(),
    ),
  );
}

class SplitExpensesApp extends StatelessWidget {
  const SplitExpensesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
