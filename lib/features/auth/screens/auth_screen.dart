import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const Icon(
                Icons.casino,
                size: 80,
                color: AppTheme.primaryColor,
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
                'Track poker games, manage buy-ins,\nand settle up instantly',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTextSecondary,
                    ),
              ),
              const SizedBox(height: 64),

              // Show loading or button
              authState.when(
                data: (user) {
                  // If user is already authenticated, navigate to active game
                  if (user != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.go('/game');
                    });
                  }

                  // Guest mode button
                  return ElevatedButton(
                    onPressed: () async {
                      await ref.read(authNotifierProvider.notifier).signInAsGuest();
                      if (context.mounted) {
                        context.go('/game');
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

              // Google Sign In Button
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
                    if (context.mounted) {
                      context.go('/game');
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
                icon: const Icon(Icons.g_mobiledata, size: 28, color: AppTheme.primaryColor),
                label: const Text('Sign in with Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: null, // TODO: Implement Apple Sign In
                icon: const Icon(Icons.apple, size: 24),
                label: const Text('Sign in with Apple'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: null, // TODO: Implement Email Sign In
                icon: const Icon(Icons.email, size: 20),
                label: const Text('Sign in with Email'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 32),

              // Info text
              Text(
                'Guest mode: Games are saved locally only.\nSign in to sync across devices and share results.',
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
