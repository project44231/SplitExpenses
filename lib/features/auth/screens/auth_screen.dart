import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _hasAutoRedirected = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App branding
              Image.asset(
                'images/app_icon.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 16),
              Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Split expenses with friends,\ntrack shared bills, and settle up easily',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTextSecondary,
                    ),
              ),
              const SizedBox(height: 64),

              // Show loading or button
              authState.when(
                data: (user) {
                  // Only auto-redirect if user is authenticated AND not guest
                  // This prevents redirecting guests who just logged out to sign in properly
                  if (user != null && !user.isGuest && !_hasAutoRedirected) {
                    _hasAutoRedirected = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        context.go(AppConstants.homeRoute);
                      }
                    });
                  }

                  // Guest mode button
                  return ElevatedButton(
                    onPressed: () async {
                      await ref.read(authNotifierProvider.notifier).signInAsGuest();
                      if (context.mounted) {
                        context.go(AppConstants.homeRoute);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Continue as Guest',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => ElevatedButton(
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).signInAsGuest();
                    if (context.mounted) {
                      context.go(AppConstants.homeRoute);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Continue as Guest',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              // Apple Sign In Button (per App Store guidelines, must be equally prominent as Google)
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await ref.read(authNotifierProvider.notifier).signInWithApple();
                    if (context.mounted) {
                      context.go(AppConstants.homeRoute);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sign in failed: ${e.toString()}'),
                          backgroundColor: AppTheme.errorColor,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.apple, size: 28, color: Colors.white),
                label: const Text(
                  'Sign in with Apple',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Google Sign In Button
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
                    if (context.mounted) {
                      context.go(AppConstants.homeRoute);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sign in failed: ${e.toString()}'),
                          backgroundColor: AppTheme.errorColor,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.g_mobiledata, size: 32, color: AppTheme.primaryColor),
                label: const Text(
                  'Sign in with Google',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Info text
              Text(
                'Guest mode: Limited features.\nSign in to sync across devices and share events with friends.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTextSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
